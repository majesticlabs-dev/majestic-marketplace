#!/usr/bin/env python3
"""Improve a skill description based on eval results.

Uses claude -p with a carefully crafted prompt to generate improved descriptions.
No external dependencies — stdlib only.
"""

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path

from utils import parse_skill_md


def improve_description(
    skill_name: str,
    skill_content: str,
    current_description: str,
    eval_results: dict,
    history: list[dict],
    model: str | None = None,
) -> str:
    """Call claude -p to improve the description based on eval results."""
    failed_triggers = [
        r for r in eval_results["results"]
        if r["should_trigger"] and not r["pass"]
    ]
    false_triggers = [
        r for r in eval_results["results"]
        if not r["should_trigger"] and not r["pass"]
    ]

    train_score = f"{eval_results['summary']['passed']}/{eval_results['summary']['total']}"

    prompt = f"""You are optimizing a skill description for a Claude Code skill called "{skill_name}".

The description appears in Claude's "available_skills" list. When a user sends a query, Claude decides whether to invoke the skill based solely on the name and description. Your goal: trigger for relevant queries, don't trigger for irrelevant ones.

Current description:
"{current_description}"

Current score ({train_score}):
"""
    if failed_triggers:
        prompt += "FAILED TO TRIGGER (should have but didn't):\n"
        for r in failed_triggers:
            prompt += f'  - "{r["query"]}" (triggered {r["triggers"]}/{r["runs"]} times)\n'
        prompt += "\n"

    if false_triggers:
        prompt += "FALSE TRIGGERS (triggered but shouldn't have):\n"
        for r in false_triggers:
            prompt += f'  - "{r["query"]}" (triggered {r["triggers"]}/{r["runs"]} times)\n'
        prompt += "\n"

    if history:
        prompt += "PREVIOUS ATTEMPTS (try something structurally different):\n\n"
        for h in history:
            train_s = f"{h.get('train_passed', h.get('passed', 0))}/{h.get('train_total', h.get('total', 0))}"
            prompt += f'Score: {train_s}\n'
            prompt += f'Description: "{h["description"]}"\n'
            if "results" in h:
                for r in h["results"]:
                    status = "PASS" if r["pass"] else "FAIL"
                    prompt += f'  [{status}] "{r["query"][:80]}" (triggered {r["triggers"]}/{r["runs"]})\n'
            prompt += "\n"

    prompt += f"""
Skill content (for context):
{skill_content[:2000]}

Write a new description that triggers more accurately. Guidelines:
- Use imperative: "Use this skill for..." not "this skill does..."
- Focus on user intent, not implementation details
- Don't enumerate specific queries — generalize to categories
- Keep under 200 words (hard limit: 1024 chars)
- Be creative — try different phrasings if previous attempts failed

Respond with ONLY the new description text, nothing else."""

    cmd = ["claude", "-p", prompt, "--output-format", "text"]
    if model:
        cmd.extend(["--model", model])

    env = {k: v for k, v in os.environ.items() if k != "CLAUDECODE"}

    result = subprocess.run(
        cmd,
        capture_output=True,
        text=True,
        env=env,
        timeout=120,
    )

    if result.returncode != 0:
        print(f"Warning: claude -p failed: {result.stderr}", file=sys.stderr)
        return current_description

    description = result.stdout.strip().strip('"')

    # If over 1024 chars, ask to shorten
    if len(description) > 1024:
        shorten_cmd = [
            "claude", "-p",
            f"Rewrite this skill description to be under 1024 characters while preserving the key trigger words:\n\n{description}\n\nRespond with ONLY the shortened description.",
            "--output-format", "text",
        ]
        if model:
            shorten_cmd.extend(["--model", model])

        shorten_result = subprocess.run(
            shorten_cmd,
            capture_output=True,
            text=True,
            env=env,
            timeout=60,
        )
        if shorten_result.returncode == 0:
            description = shorten_result.stdout.strip().strip('"')

    return description


def main():
    parser = argparse.ArgumentParser(description="Improve a skill description based on eval results")
    parser.add_argument("--eval-results", required=True, help="Path to eval results JSON")
    parser.add_argument("--skill-path", required=True, help="Path to skill directory")
    parser.add_argument("--history", default=None, help="Path to history JSON")
    parser.add_argument("--model", default=None, help="Model for improvement")
    parser.add_argument("--verbose", action="store_true")
    args = parser.parse_args()

    skill_path = Path(args.skill_path)
    if not (skill_path / "SKILL.md").exists():
        print(f"Error: No SKILL.md found at {skill_path}", file=sys.stderr)
        sys.exit(1)

    eval_results = json.loads(Path(args.eval_results).read_text())
    history = json.loads(Path(args.history).read_text()) if args.history else []

    name, _, content = parse_skill_md(skill_path)
    current_description = eval_results["description"]

    if args.verbose:
        print(f"Current: {current_description}", file=sys.stderr)
        print(f"Score: {eval_results['summary']['passed']}/{eval_results['summary']['total']}", file=sys.stderr)

    new_description = improve_description(
        skill_name=name,
        skill_content=content,
        current_description=current_description,
        eval_results=eval_results,
        history=history,
        model=args.model,
    )

    if args.verbose:
        print(f"Improved: {new_description}", file=sys.stderr)

    output = {
        "description": new_description,
        "history": history + [{
            "description": current_description,
            "passed": eval_results["summary"]["passed"],
            "failed": eval_results["summary"]["failed"],
            "total": eval_results["summary"]["total"],
            "results": eval_results["results"],
        }],
    }
    print(json.dumps(output, indent=2))


if __name__ == "__main__":
    main()
