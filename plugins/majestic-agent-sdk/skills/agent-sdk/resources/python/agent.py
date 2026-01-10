import sys
from claude_agent_sdk import Agent

# Configure allowed tools based on user selection
ALLOWED_TOOLS = {{tools_list}}

agent = Agent(
    model="claude-sonnet-4-20250514",
    allowed_tools=ALLOWED_TOOLS,
    system_prompt="""{{system_prompt}}""",
)


def main():
    prompt = sys.argv[1] if len(sys.argv) > 1 else "Hello, what can you help me with?"
    result = agent.run(prompt=prompt)
    print(result.output)


if __name__ == "__main__":
    main()
