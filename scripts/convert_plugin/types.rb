# frozen_string_literal: true

require 'pathname'

module ConvertPlugin
  KNOWN_OPENCODE_TOOLS = %w[
    read
    write
    edit
    bash
    grep
    glob
    list
    webfetch
    skill
    patch
    task
    question
    todowrite
    todoread
  ].freeze

  ParsedFrontmatter = Struct.new(:data, :body)
  Agent = Struct.new(:name, :description, :capabilities, :model, :body)
  Command = Struct.new(:name, :description, :argument_hint, :model, :allowed_tools, :disable_model_invocation, :body)
  SkillRef = Struct.new(:name, :source_dir)
  ClaudePlugin = Struct.new(:root, :manifest, :agents, :commands, :skills, :hooks, :mcp_servers)
end
