# frozen_string_literal: true

require 'set'

require_relative 'types'
require_relative 'parser'
require_relative 'loader'

module ConvertPlugin
  module Converter
    module_function

    def convert_codex_task_reference(body)
      result = body

      task_re = /^(\s*-?\s*)Task\s+([a-z][a-z0-9-]*)\(([^)]+)\)/m
      result = result.gsub(task_re) do |_match|
        prefix = Regexp.last_match(1)
        agent_name = Parser.normalize_name(Regexp.last_match(2))
        args = Regexp.last_match(3).strip
        "#{prefix}Use the $#{agent_name} skill to: #{args}"
      end

      slash_re = %r{(^|[^A-Za-z0-9_])/([a-z][a-z0-9_:-]*?)(?=(\s|\.|,|:|"|'|\)|\]|\}|$))}i
      result = result.gsub(slash_re) do
        prefix = Regexp.last_match(1).to_s
        command_name = Regexp.last_match(2)

        if command_name.include?('/')
          "#{prefix}#{command_name}"
        elsif %w[dev tmp etc usr var bin home].include?(command_name)
          "#{prefix}#{command_name}"
        else
          "#{prefix}/prompts:#{Parser.normalize_name(command_name)}"
        end
      end

      result = result.gsub('~/.claude/', '~/.codex/').gsub('.claude/', '.codex/')

      agent_ref = /@([a-z][a-z0-9-]*-(?:agent|reviewer|researcher|analyst|specialist|oracle|sentinel|guardian|strategist))/i
      result.gsub(agent_ref) do
        match = Regexp.last_match(1)
        "$#{Parser.normalize_name(match)} skill"
      end
    end

    def format_yaml_line(key, value)
      if value.is_a?(TrueClass) || value.is_a?(FalseClass)
        return "#{key}: #{value ? 'true' : 'false'}"
      end

      return "#{key}: #{value}" if value.is_a?(Integer) || value.is_a?(Float)

      if value.is_a?(Array)
        return "#{key}: []" if value.empty?

        serialized = value.map { |item| item.to_json }
        return "#{key}: [#{serialized.join(', ')}]"
      end

      text = value.to_s
      needs_quote = text.include?(' ') || text.include?(':') || text.start_with?('{') || text.start_with?('[')
      formatted = needs_quote ? text.to_json : text
      "#{key}: #{formatted}"
    end

    def codex_skill_frontmatter(fields, body)
      lines = []
      fields.each do |key, value|
        next if value.nil?

        lines << format_yaml_line(key, value)
      end

      return "#{body}\n" if lines.empty?

      "---\n#{lines.join("\n")}\n---\n\n#{body}\n"
    end

    def convert_to_codex(plugin)
      used_names = plugin.skills.map { |skill| Parser.normalize_name(skill.name) }.to_set

      prompts = []
      generated_skills = []

      plugin.commands.each do |command|
        skill_name = Parser.unique_name(Parser.normalize_name(command.name), used_names)
        skill_description = Parser.sanitize_description(command.description || "Converted from Claude command #{command.name}")
        skill_sections = []
        skill_sections << "## Arguments\n#{command.argument_hint}" if command.argument_hint

        if command.allowed_tools
          skill_sections << "## Allowed tools\n" + command.allowed_tools.map { |tool| "- #{tool}" }.join("\n")
        end

        transformed = convert_codex_task_reference(command.body)
        skill_sections << transformed

        generated_skills << {
          'name' => skill_name,
          'content' => codex_skill_frontmatter(
            {
              'name' => skill_name,
              'description' => skill_description
            },
            skill_sections.map(&:strip).reject(&:empty?).join("\n\n")
          )
        }

        prompt_name = Parser.unique_name(Parser.normalize_name(command.name), used_names)
        prompt_body = codex_skill_frontmatter(
          {
            'description' => command.description,
            'argument-hint' => command.argument_hint
          },
          "Use the $#{skill_name} skill for this command and follow its instructions.\n\n" +
            convert_codex_task_reference(command.body)
        )
        prompts << { 'name' => prompt_name, 'content' => prompt_body }
      end

      plugin.agents.each do |agent|
        name = Parser.unique_name(Parser.normalize_name(agent.name), used_names)
        description = Parser.sanitize_description(agent.description || "Converted from Claude agent #{agent.name}")
        body_sections = [convert_codex_task_reference(agent.body)]

        if agent.capabilities.any?
          caps = agent.capabilities.map { |item| "- #{item}" }.join("\n")
          body_sections.unshift("## Capabilities\n#{caps}")
        end

        body = body_sections.map(&:strip).reject(&:empty?).join("\n\n")
        body = "Instructions converted from the #{agent.name} agent." if body.empty?

        generated_skills << {
          'name' => name,
          'content' => codex_skill_frontmatter(
            {
              'name' => name,
              'description' => description
            },
            body
          )
        }
      end

      {
        'prompts' => prompts,
        'skillDirs' => plugin.skills.map { |skill| { 'name' => skill.name, 'sourceDir' => skill.source_dir.to_s } },
        'generatedSkills' => generated_skills,
        'mcpServers' => plugin.mcp_servers || {}
      }
    end

    def convert_to_opencode(
      plugin,
      agent_mode: 'subagent',
      infer_temperature: true,
      permissions: 'broad'
    )
      command_map = {}
      plugin.commands.each do |command|
        entry = {
          'description' => command.description,
          'template' => Loader.rewrite_claude_paths(command.body)
        }
        model = command.model
        entry['model'] = normalize_model(model) if model && model != 'inherit'
        command_map[command.name] = entry
      end

      agents = []
      plugin.agents.each do |agent|
        frontmatter = {
          'description' => agent.description,
          'mode' => agent_mode
        }

        model = agent.model
        frontmatter['model'] = normalize_model(model) if model && model != 'inherit'

        if infer_temperature
          temperature = infer_agent_temperature(agent)
          frontmatter['temperature'] = temperature unless temperature.nil?
        end

        agents << {
          'name' => agent.name,
          'content' => codex_skill_frontmatter(frontmatter, Loader.rewrite_claude_paths(agent.body))
        }
      end

      config = { '$schema' => 'https://opencode.ai/config.json' }
      config['command'] = command_map unless command_map.empty?

      if plugin.mcp_servers
        converted = convert_mcp_servers(plugin.mcp_servers)
        config['mcp'] = converted unless converted.empty?
      end

      apply_permissions(config, plugin.commands, permissions)

      plugins = []
      plugins << { 'name' => 'converted-hooks.ts', 'content' => convert_hooks_to_plugin(plugin.hooks) } if plugin.hooks

      {
        'config' => config,
        'agents' => agents,
        'plugins' => plugins,
        'skillDirs' => plugin.skills.map { |skill| { 'name' => skill.name, 'sourceDir' => skill.source_dir.to_s } }
      }
    end

    def convert_hooks_to_plugin(hooks)
      known = hooks.fetch('hooks', {}).keys.map { |key| "- #{key}" }.join("\n")
      body = [
        'import type { Plugin } from "@opencode-ai/plugin"',
        '',
        'export const ConvertedHooks: Plugin = async ({ $ }) => {',
        '  return {',
        '    // Unmapped hook events from Claude hooks:',
        "    // #{known}",
        '    // Add explicit mappings here if this plugin uses Claude hooks.',
        '  }',
        '}',
        '',
        'export default ConvertedHooks'
      ]
      body.join("\n")
    end

    def convert_mcp_servers(servers)
      converted = {}
      servers.each do |name, server|
        next unless server.is_a?(Hash)

        if server.key?('command')
          args = server['args']
          args_list = args.is_a?(Array) ? args.map(&:to_s) : []
          converted[name] = {
            'type' => 'local',
            'command' => [server['command'].to_s] + args_list,
            'environment' => server['env'] || nil,
            'enabled' => true
          }
          converted[name].delete('environment') if converted[name]['environment'] == {}
          next
        end

        next unless server['url']

        converted[name] = {
          'type' => 'remote',
          'url' => server['url'].to_s,
          'headers' => server['headers'] || nil,
          'enabled' => true
        }
        converted[name].delete('headers') if converted[name]['headers'] == {}
      end

      converted
    end

    def parse_tool_spec(raw)
      text = raw.to_s.strip
      return [nil, nil] if text.empty?

      if text.include?('(') && text.end_with?(')')
        tool, pattern = text.split('(', 2)
        return [normalize_tool_name(tool.strip), pattern[0...-1].strip]
      end

      [normalize_tool_name(text), nil]
    end

    def normalize_tool_name(value)
      tool_map = {
        'bash' => 'bash',
        'read' => 'read',
        'write' => 'write',
        'edit' => 'edit',
        'grep' => 'grep',
        'glob' => 'glob',
        'list' => 'list',
        'webfetch' => 'webfetch',
        'skill' => 'skill',
        'patch' => 'patch',
        'task' => 'task',
        'question' => 'question',
        'todowrite' => 'todowrite',
        'todoread' => 'todoread'
      }

      tool_map[value.to_s.downcase]
    end

    def infer_agent_temperature(agent)
      sample = [agent.name, agent.description].compact.join(' ').downcase

      return 0.1 if sample =~ /(review|audit|security|sentinel|oracle|lint|verification|guardian)/
      return 0.2 if sample =~ /(plan|planning|architecture|strategist|analysis|research)/
      return 0.3 if sample =~ /(doc|readme|changelog|editor|writer)/
      return 0.6 if sample =~ /(brainstorm|creative|ideate|design|concept)/

      0.3
    end

    def apply_permissions(config, commands, mode)
      return if mode == 'none'

      tools_enabled = {}
      permissions = {}
      KNOWN_OPENCODE_TOOLS.each do |tool|
        tools_enabled[tool] = false
        permissions[tool] = 'deny'
      end

      if mode == 'broad'
        KNOWN_OPENCODE_TOOLS.each do |tool|
          tools_enabled[tool] = true
          permissions[tool] = 'allow'
        end
      else
        explicit_tools = Set.new
        patterns = Hash.new { |hash, key| hash[key] = Set.new }

        commands.each do |command|
          next if command.allowed_tools.nil?

          command.allowed_tools.each do |raw|
            tool, pattern = parse_tool_spec(raw)
            next if tool.nil?

            explicit_tools.add(tool)
            patterns[tool].add(pattern) if pattern
          end
        end

        explicit_tools.each do |tool|
          tools_enabled[tool] = true
          permission = permissions[tool]
          permissions[tool] = permission if permission.is_a?(String)
        end

        patterns.each do |tool, tool_patterns|
          next if tool_patterns.empty?

          policy = { '*' => 'deny' }
          tool_patterns.each do |pattern|
            normalized = pattern.gsub(':', ' ').strip
            policy[normalized] = 'allow'
          end
          permissions[tool] = policy
        end

        if patterns.key?('write') || patterns.key?('edit')
          merged = Set.new
          merged.merge(patterns['write'])
          merged.merge(patterns['edit'])

          unless merged.empty?
            policy = { '*' => 'deny' }
            merged.each do |pattern|
              policy[pattern.gsub(':', ' ').strip] = 'allow'
            end
            permissions['write'] = policy
            permissions['edit'] = policy
          end
        end
      end

      config['tools'] = tools_enabled
      config['permission'] = permissions
    end

    def normalize_model(model)
      return model if model.include?('/')

      aliases = {
        'haiku' => 'anthropic/claude-haiku-4-5',
        'sonnet' => 'anthropic/claude-sonnet-4-5',
        'opus' => 'anthropic/claude-opus-4-6'
      }

      lowered = model.downcase
      return aliases[lowered] if aliases.key?(lowered)
      return "anthropic/#{lowered}" if lowered.start_with?('claude-')
      if lowered.start_with?('gpt-') || lowered.start_with?('o1-') || lowered.start_with?('o3-')
        return "openai/#{lowered}"
      end
      return "google/#{lowered}" if lowered.start_with?('gemini-')

      "anthropic/#{lowered}"
    end

    def format_toml_value(value)
      value.to_json
    end

    def format_toml_key(value)
      return value if value.match?(/^[A-Za-z0-9_-]+$/)

      format_toml_value(value)
    end

    def render_codex_mcp_toml(mcp_servers)
      return '' if mcp_servers.empty?

      lines = ['# Generated by scripts/convert-plugin.rb', '']

      mcp_servers.each do |name, server|
        next unless server.is_a?(Hash)

        key = format_toml_key(name.to_s)
        lines << "[mcp_servers.#{key}]"

        if server['command']
          lines << "command = #{format_toml_value(server['command'].to_s)}"
          args = server['args'] || []
          unless args.empty?
            rendered_args = args.map { |arg| format_toml_value(arg.to_s) }.join(', ')
            lines << "args = [#{rendered_args}]"
          end

          env = server['env'] || server['environment']
          if env
            lines << ''
            lines << "[mcp_servers.#{key}.env]"
            env.each do |env_key, env_value|
              lines << "#{format_toml_key(env_key.to_s)} = #{format_toml_value(env_value.to_s)}"
            end
          end
        elsif server['url']
          lines << "url = #{format_toml_value(server['url'].to_s)}"
          headers = server['headers']
          if headers && !headers.empty?
            env = headers.map do |hkey, hval|
              "#{format_toml_key(hkey.to_s)} = #{format_toml_value(hval.to_s)}"
            end.join(', ')
            lines << "http_headers = { #{env} }"
          end
        end

        lines << ''
      end

      lines.join("\n")
    end
  end
end
