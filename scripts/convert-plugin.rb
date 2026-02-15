#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'pathname'
require 'time'

require_relative 'convert_plugin/parser'
require_relative 'convert_plugin/loader'
require_relative 'convert_plugin/converter'

def copy_directory(source, destination)
  FileUtils.rm_rf(destination) if destination.exist?
  FileUtils.cp_r(source, destination)
end

def write_text(path, content)
  path.parent.mkpath
  path.write(content)
end

def backup_file(path)
  return nil unless path.exist?

  timestamp = Time.now.strftime('%Y%m%d-%H%M%S')
  backup_path = path.parent / "#{path.basename}.bak.#{timestamp}"
  FileUtils.cp(path, backup_path)
  backup_path
end

def ensure_dir(path)
  path.mkpath
end

def write_opencode_bundle(output_root, bundle)
  config_path = output_root / 'opencode.json'

  existing_config = {}
  if config_path.file?
    begin
      loaded = JSON.parse(config_path.read)
      existing_config = loaded if loaded.is_a?(Hash)
    rescue StandardError
      existing_config = {}
    end
  end

  if existing_config['command'] && bundle['config']['command']
    merged = existing_config.fetch('command', {}).dup
    merged.merge!(bundle['config']['command'])
    bundle['config']['command'] = merged
  end

  %w[tools permission].each do |key|
    bundle['config'][key] = existing_config[key] if existing_config.key?(key) && !bundle['config'].key?(key)
  end

  unless bundle['config'].empty?
    backup_file(config_path)
    write_text(config_path, JSON.pretty_generate(bundle['config']) + "\n")
  end

  agents_root = output_root / 'agents'
  ensure_dir(agents_root)
  bundle['agents'].each do |agent|
    write_text(agents_root / "#{agent['name']}.md", agent['content'].to_s.rstrip + "\n")
  end

  plugins_root = output_root / 'plugins'
  ensure_dir(plugins_root)
  bundle['plugins'].each do |plugin|
    plugin_path = plugins_root / plugin['name']
    write_text(plugin_path, plugin['content'].to_s.rstrip + "\n")
  end

  skills_root = output_root / 'skills'
  ensure_dir(skills_root)
  bundle['skillDirs'].each do |entry|
    source = Pathname.new(entry['sourceDir'])
    destination = skills_root / entry['name'].to_s
    copy_directory(source, destination)
  end
end

def write_codex_bundle(output_root, bundle)
  prompts_root = output_root / 'prompts'
  ensure_dir(prompts_root)
  bundle['prompts'].each do |prompt|
    write_text(prompts_root / "#{prompt['name']}.md", prompt['content'])
  end

  skills_root = output_root / 'skills'
  ensure_dir(skills_root)
  bundle['skillDirs'].each do |skill|
    copy_directory(Pathname.new(skill['sourceDir']), skills_root / skill['name'].to_s)
  end

  bundle['generatedSkills'].each do |generated|
    target = skills_root / generated['name'].to_s / 'SKILL.md'
    write_text(target, generated['content'])
  end

  return unless bundle['mcpServers']

  config_text = ConvertPlugin::Converter.render_codex_mcp_toml(bundle['mcpServers'])
  return if config_text.empty?

  config_path = output_root / 'config.toml'
  backup_file(config_path)
  write_text(config_path, config_text.rstrip + "\n")
end

def main
  args = ConvertPlugin::Parser.parse_args
  plugin_path = Pathname.new(args[:plugin]).expand_path
  plugin = ConvertPlugin::Loader.load_plugin(plugin_path)

  output_root = if args[:output]
                  Pathname.new(args[:output]).expand_path
                else
                  ConvertPlugin::Parser.default_output_root(args[:target])
                end
  ensure_dir(output_root)

  if args[:target] == 'codex'
    bundle = ConvertPlugin::Converter.convert_to_codex(plugin)
    write_codex_bundle(output_root, bundle)
  elsif args[:target] == 'opencode'
    bundle = ConvertPlugin::Converter.convert_to_opencode(
      plugin,
      agent_mode: args[:agent_mode],
      infer_temperature: args[:infer_temperature],
      permissions: args[:permissions]
    )
    write_opencode_bundle(output_root, bundle)
  else
    raise "Unsupported target: #{args[:target]}"
  end

  puts "Installed #{plugin.manifest.fetch('name', plugin.root.basename)} to #{output_root}"
  0
end

exit(main) if __FILE__ == $0
