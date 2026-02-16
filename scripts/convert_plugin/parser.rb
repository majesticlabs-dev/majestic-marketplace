# frozen_string_literal: true

require 'optparse'
require 'pathname'

require_relative 'types'

module ConvertPlugin
  module Parser
    module_function

    def parse_args
      options = {
        output: nil,
        target: nil,
        agent_mode: 'subagent',
        permissions: 'broad',
        infer_temperature: true
      }

      parser = OptionParser.new do |parser|
        parser.banner = 'Convert a local Claude plugin to opencode or codex'

        parser.on('--plugin PATH', 'Path to plugin directory') do |value|
          options[:plugin] = value
        end

        parser.on('--target TARGET', 'Target format: opencode|codex') do |value|
          options[:target] = value
        end

        parser.on('--output OUTPUT', 'Output root') do |value|
          options[:output] = value
        end

        parser.on('--agent-mode MODE', 'Mode for opencode agents: primary|subagent') do |value|
          options[:agent_mode] = value
        end

        parser.on('--permissions MODE', 'Permission model: none|broad|from-commands') do |value|
          options[:permissions] = value
        end

        parser.on('--infer-temperature', 'Infer opencode agent temperature') do
          options[:infer_temperature] = true
        end

        parser.on('-h', '--help', 'Show this help') do
          puts parser
          exit 0
        end
      end

      parser.parse!(ARGV)

      if options[:plugin].nil? || options[:plugin].to_s.strip.empty?
        warn parser
        warn 'Error: --plugin is required'
        exit 1
      end

      if options[:target].nil? || options[:target].to_s.strip.empty?
        warn parser
        warn 'Error: --target is required'
        exit 1
      end

      unless %w[opencode codex].include?(options[:target])
        warn "Error: unsupported target '#{options[:target]}'"
        exit 1
      end

      unless %w[primary subagent].include?(options[:agent_mode])
        warn "Error: unsupported agent-mode '#{options[:agent_mode]}'"
        exit 1
      end

      unless %w[none broad from-commands].include?(options[:permissions])
        warn "Error: unsupported permissions '#{options[:permissions]}'"
        exit 1
      end

      options
    end

    def default_output_root(target)
      return Pathname.new(Dir.home) / '.codex' if target == 'codex'

      Pathname.new(Dir.home) / '.config' / 'opencode'
    end

    def parse_scalar(raw)
      value = raw.strip
      return '' if value.empty?

      if (value.start_with?('"') && value.end_with?('"')) || (value.start_with?("'") && value.end_with?("'"))
        return value[1...-1]
      end

      low = value.downcase
      return true if low == 'true'
      return false if low == 'false'
      return nil if %w[null none].include?(low)

      if value.start_with?('[') && value.end_with?(']')
        inner = value[1...-1].strip
        return [] if inner.empty?

        parts = inner.split(',').map do |entry|
          cleaned = entry.strip
          cleaned = cleaned.delete_prefix('"').delete_suffix('"')
          cleaned = cleaned.delete_prefix("'").delete_suffix("'")
          cleaned
        end
        return parts.map(&:strip).reject(&:empty?)
      end

      return value.to_i if value.match?(/^-?\d+$/)

      return value.to_f if value.match?(/^-?\d+\.\d+$/)

      value
    end

    def parse_frontmatter(raw)
      lines = raw.split("\n")
      return ParsedFrontmatter.new({}, raw) if lines.empty? || lines[0].strip != '---'

      end_index = nil
      (1...lines.length).each do |index|
        if lines[index].strip == '---'
          end_index = index
          break
        end
      end

      return ParsedFrontmatter.new({}, raw) if end_index.nil?

      fm_lines = lines[1...end_index]
      data = {}
      body = lines[(end_index + 1)..]&.join("\n")&.sub(/\A\n+/, '') || ''

      i = 0
      while i < fm_lines.length
        line = fm_lines[i]
        if line.strip.empty? || line[0]&.match?(/\s/)
          i += 1
          next
        end

        next unless line.include?(':')

        key, raw_value = line.split(':', 2)
        key = key&.strip.to_s
        raw_value = raw_value.to_s.strip

        if raw_value.empty?
          list_items = []
          j = i + 1

          while j < fm_lines.length
            candidate = fm_lines[j]
            if candidate.match?(/^\s{2,}-\s+/)
              stripped = candidate.strip
              list_items << stripped[2..-1].to_s
              j += 1
              next
            end

            if candidate.start_with?(' ') || candidate.start_with?("\t")
              j += 1
              next
            end

            break
          end

          if list_items.any?
            data[key] = list_items
            i = j
            next
          end

          data[key] = ''
          i += 1
          next
        end

        data[key] = parse_scalar(raw_value)
        i += 1
      end

      ParsedFrontmatter.new(data, body)
    end

    def normalize_name(value)
      normalized = value.to_s.strip.downcase
      return 'item' if normalized.empty?

      normalized = normalized.tr('/', '-')
      normalized = normalized.tr(' ', '-')
      normalized = normalized.gsub(/[^a-z0-9_-]+/, '-')
      normalized = normalized.gsub(/-+/, '-')
      normalized = normalized.gsub(/\A-+|-+$/, '')

      normalized.empty? ? 'item' : normalized
    end

    def unique_name(base, used)
      current = base
      index = 2
      while used.include?(current)
        current = "#{base}-#{index}"
        index += 1
      end
      used.add(current)
      current
    end

    def sanitize_description(value, max_length = 1024)
      return nil if value.nil?

      compact = value.to_s.gsub(/\s+/, ' ').strip
      return compact if compact.length <= max_length

      compact[0...(max_length - 3)].rstrip + '...'
    end

    def parse_allowed_tools(value)
      return nil if value.nil?
      return value.map { |item| item.to_s.strip }.reject(&:empty?) if value.is_a?(Array)
      return nil unless value.is_a?(String)

      cleaned = value.strip
      return nil if cleaned.empty?

      cleaned.split(',').map(&:strip).reject(&:empty?)
    end

    def walk_markdown_files(root)
      return [] unless root.directory?

      Dir.glob(root.join('**/*.md')).select { |path| File.file?(path) }.sort.map { |path| Pathname.new(path) }
    end
  end
end
