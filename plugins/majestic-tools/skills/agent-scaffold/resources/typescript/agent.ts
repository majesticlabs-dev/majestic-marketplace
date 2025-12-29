import { Agent } from '@anthropic-ai/claude-agent-sdk';

// Configure allowed tools based on user selection
const allowedTools = {{tools_array}};

const agent = new Agent({
  model: 'claude-sonnet-4-20250514',
  allowedTools,
  systemPrompt: `{{system_prompt}}`,
});

async function main() {
  const result = await agent.run({
    prompt: process.argv[2] || 'Hello, what can you help me with?',
  });

  console.log(result.output);
}

main().catch(console.error);
