# frozen_string_literal: true

require 'json'
require 'set'

require_relative 'types'
require_relative 'parser'

module ConvertPlugin
  module Loader
    module_function

    def rewrite_claude_paths(body)
      body.gsub('~/.claude/', '~/.config/opencode/').gsub('.claude/', '.opencode/')
    end

    def load_plugin(plugin_path)
      plugin_path = Pathname.new(plugin_path)
      plugin_manifest_path = plugin_path / '.claude-plugin' / 'plugin.json'
      raise "Missing plugin manifest: #{plugin_manifest_path}" unless plugin_manifest_path.file?

      manifest = JSON.parse(plugin_manifest_path.read)

      agents = []
      Parser.walk_markdown_files(plugin_path / 'agents').each do |file|
        frontmatter = Parser.parse_frontmatter(file.read)
        data = frontmatter.data
        body = frontmatter.body.strip

        capabilities = []
        if data['capabilities'].is_a?(Array)
          capabilities = data['capabilities'].select { |item| item.is_a?(String) || item.is_a?(Numeric) }.map(&:to_s)
        end

        agents << Agent.new(
          data['name'] ? data['name'].to_s : file.basename.to_s.delete_suffix(file.extname),
          data['description'].is_a?(String) ? data['description'] : nil,
          capabilities,
          data['model'].is_a?(String) ? data['model'] : nil,
          body
        )
      end

      commands = []
      Parser.walk_markdown_files(plugin_path / 'commands').each do |file|
        frontmatter = Parser.parse_frontmatter(file.read)
        data = frontmatter.data
        body = frontmatter.body.strip
        disabled = data['disable-model-invocation'].is_a?(TrueClass)

        commands << Command.new(
          data['name'] ? data['name'].to_s : file.basename.to_s.delete_suffix(file.extname),
          data['description'].is_a?(String) ? data['description'] : nil,
          data['argument-hint'].is_a?(String) ? data['argument-hint'] : nil,
          data['model'].is_a?(String) ? data['model'] : nil,
          Parser.parse_allowed_tools(data['allowed-tools']),
          disabled,
          body
        )
      end

      skill_files = Set.new
      Dir.glob(plugin_path.join('**/SKILL.md')).each do |path|
        file = Pathname.new(path)
        if file.file? && file.basename.to_s == 'SKILL.md' && file.to_s.split(File::SEPARATOR).include?('skills')
          skill_files.add(file)
        end
      end

      skills = []
      skill_files.to_a.sort.each do |file|
        source_dir = file.dirname
        skills << SkillRef.new(source_dir.basename.to_s, source_dir)
      end

      hooks = nil
      hooks_path = plugin_path / 'hooks' / 'hooks.json'
      hooks = JSON.parse(hooks_path.read) if hooks_path.file?

      mcp_servers = nil
      if manifest.key?('mcpServers') && manifest['mcpServers'].is_a?(Hash)
        mcp_servers = manifest['mcpServers']
      else
        legacy_mcp = plugin_path / '.mcp.json'
        if legacy_mcp.file?
          loaded = JSON.parse(legacy_mcp.read)
          mcp_servers = loaded if loaded.is_a?(Hash) && !loaded.empty?
        end
      end

      ClaudePlugin.new(plugin_path, manifest, agents, commands, skills, hooks, mcp_servers)
    end
  end
end
