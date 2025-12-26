#!/bin/bash
set -euo pipefail

# Git Worktree Manager
# Unified script for managing git worktrees with local .worktrees/ storage

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Get repository root
get_repo_root() {
    git rev-parse --show-toplevel 2>/dev/null || {
        echo -e "${RED}Error: Not in a git repository${NC}" >&2
        exit 1
    }
}

# Get main branch name
# Priority: DEFAULT_BRANCH env var > config files > git detection
get_main_branch() {
    # 1. Check environment variable (set by caller via /majestic:config)
    if [ -n "${DEFAULT_BRANCH:-}" ]; then
        echo "$DEFAULT_BRANCH"
        return
    fi

    local repo_root
    repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
    local main_branch=""

    # 2. Check config files (fallback for direct CLI usage)
    if [ -n "$repo_root" ]; then
        if [ -f "$repo_root/.agents.local.yml" ]; then
            main_branch=$(grep "^default_branch:" "$repo_root/.agents.local.yml" 2>/dev/null | head -1 | awk '{print $2}')
        fi
        if [ -z "$main_branch" ] && [ -f "$repo_root/.agents.yml" ]; then
            main_branch=$(grep "^default_branch:" "$repo_root/.agents.yml" 2>/dev/null | head -1 | awk '{print $2}')
        fi
    fi

    # 3. Fallback to git detection
    if [ -z "$main_branch" ]; then
        main_branch=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@')
    fi
    if [ -z "$main_branch" ]; then
        if git show-ref --verify --quiet refs/heads/main; then
            main_branch="main"
        elif git show-ref --verify --quiet refs/heads/master; then
            main_branch="master"
        else
            main_branch="main"
        fi
    fi
    echo "$main_branch"
}

# Ensure .worktrees is in .gitignore
ensure_gitignore() {
    local repo_root="$1"
    local gitignore="$repo_root/.gitignore"

    # Check if .worktrees/ already exists (handles trailing whitespace/CRLF)
    if [ -f "$gitignore" ] && grep -qE "^\.worktrees/?[[:space:]]*$" "$gitignore" 2>/dev/null; then
        return 0  # Already present, skip
    fi
    echo ".worktrees/" >> "$gitignore"
    echo -e "${BLUE}Added .worktrees/ to .gitignore${NC}"
}

# Copy .env files to worktree (excludes .env.example)
copy_env_files() {
    local source_dir="$1"
    local target_dir="$2"

    local env_files
    env_files=$(find "$source_dir" -maxdepth 1 -name ".env*" -type f ! -name ".env.example" 2>/dev/null)

    if [ -z "$env_files" ]; then
        return 0
    fi

    echo ""
    echo -e "${BLUE}Copying environment files...${NC}"

    while IFS= read -r env_file; do
        local filename
        filename=$(basename "$env_file")
        local target_file="$target_dir/$filename"

        if [ -f "$target_file" ]; then
            cp "$target_file" "$target_file.backup"
            echo -e "  ${YELLOW}↺${NC} $filename (backed up existing)"
        else
            echo -e "  ${GREEN}✓${NC} $filename"
        fi
        cp "$env_file" "$target_file"
    done <<< "$env_files"
}

# Create worktree
cmd_create() {
    local branch_name="$1"
    local source_branch="${2:-$(get_main_branch)}"

    if [ -z "$branch_name" ]; then
        echo -e "${RED}Error: Please provide a branch name${NC}"
        echo "Usage: worktree-manager.sh create <branch-name> [source-branch]"
        exit 1
    fi

    local repo_root
    repo_root=$(get_repo_root)
    local worktree_base="$repo_root/.worktrees"
    local worktree_path="$worktree_base/$branch_name"

    # Ensure .worktrees is gitignored
    ensure_gitignore "$repo_root"

    # Create base directory
    mkdir -p "$worktree_base"

    # Check if worktree already exists
    if [ -d "$worktree_path" ]; then
        echo -e "${YELLOW}Worktree already exists at: $worktree_path${NC}"
        echo "To switch to it: cd $worktree_path"
        exit 0
    fi

    echo -e "${BLUE}Creating worktree: $branch_name${NC}"

    # Check if branch exists locally
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "Using existing branch: $branch_name"
        git worktree add "$worktree_path" "$branch_name"
    elif git ls-remote --heads origin "$branch_name" 2>/dev/null | grep -q .; then
        echo "Checking out remote branch: origin/$branch_name"
        git worktree add "$worktree_path" -b "$branch_name" "origin/$branch_name"
    else
        echo "Creating new branch from $source_branch: $branch_name"
        git fetch origin "$source_branch" 2>/dev/null || true
        git worktree add "$worktree_path" -b "$branch_name" "origin/$source_branch" 2>/dev/null || \
            git worktree add "$worktree_path" -b "$branch_name" "$source_branch"
    fi

    # Copy environment files
    copy_env_files "$repo_root" "$worktree_path"

    echo ""
    echo -e "${GREEN}Worktree created successfully!${NC}"
    echo -e "Location: $worktree_path"
    echo ""
    echo "To switch to the worktree:"
    echo "  cd $worktree_path"
}

# List worktrees
cmd_list() {
    local repo_root
    repo_root=$(get_repo_root)
    local repo_name
    repo_name=$(basename "$repo_root")
    local current_worktree
    current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)

    echo -e "${BLUE}Git Worktrees for: $repo_name${NC}"
    echo "════════════════════════════════════════════════════════"
    echo ""

    git worktree list --porcelain | while IFS= read -r line; do
        if [[ $line == worktree* ]]; then
            worktree_path="${line#worktree }"
            is_current=""
            if [ "$worktree_path" = "$current_worktree" ]; then
                is_current=" (current)"
            fi
        elif [[ $line == HEAD* ]]; then
            commit="${line#HEAD }"
            commit_short="${commit:0:7}"
        elif [[ $line == branch* ]]; then
            branch="${line#branch refs/heads/}"

            # Get status
            if [ -d "$worktree_path" ]; then
                cd "$worktree_path" 2>/dev/null
                if [ $? -eq 0 ]; then
                    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                        status="${RED}dirty${NC}"
                    else
                        status="${GREEN}clean${NC}"
                    fi
                else
                    status="${YELLOW}inaccessible${NC}"
                fi
            else
                status="${RED}missing${NC}"
            fi

            echo -e "📁 $worktree_path$is_current"
            echo -e "   Branch: $branch"
            echo -e "   Commit: $commit_short"
            echo -e "   Status: $status"
            echo ""
        elif [[ $line == detached ]]; then
            echo -e "📁 $worktree_path$is_current"
            echo "   Branch: (detached HEAD)"
            echo -e "   Commit: $commit_short"
            echo -e "   Status: ${YELLOW}detached${NC}"
            echo ""
        fi
    done
}

# Switch to worktree
cmd_switch() {
    local search="$1"
    local repo_root
    repo_root=$(get_repo_root)
    local worktree_base="$repo_root/.worktrees"

    if [ -z "$search" ]; then
        echo -e "${RED}Error: Please provide a branch name or worktree path${NC}"
        echo "Usage: worktree-manager.sh switch <branch-name|path>"
        echo ""
        echo "Available worktrees:"
        git worktree list | while IFS= read -r line; do
            path_part=$(echo "$line" | awk '{print $1}')
            branch_part=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
            if [ -n "$branch_part" ]; then
                echo "  • $branch_part → $path_part"
            fi
        done
        exit 1
    fi

    local worktree_path=""

    # Check if it's a direct path
    if [ -d "$search" ] && [ -f "$search/.git" ]; then
        worktree_path="$search"
    # Check in .worktrees directory
    elif [ -d "$worktree_base/$search" ]; then
        worktree_path="$worktree_base/$search"
    else
        # Search by branch name
        worktree_path=$(git worktree list --porcelain | awk -v search="$search" '
            /^worktree/ {path=$2}
            /^branch/ && $0 ~ search {print path; exit}
        ')
    fi

    if [ -z "$worktree_path" ] || [ ! -d "$worktree_path" ]; then
        echo -e "${RED}Worktree not found: $search${NC}"
        echo ""
        echo "Available worktrees:"
        git worktree list | while IFS= read -r line; do
            path_part=$(echo "$line" | awk '{print $1}')
            branch_part=$(echo "$line" | sed -n 's/.*\[\(.*\)\].*/\1/p')
            if [ -n "$branch_part" ]; then
                echo "  • $branch_part → $path_part"
            fi
        done
        exit 1
    fi

    # Get branch info
    cd "$worktree_path"
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    if [ -z "$branch" ]; then
        branch="(detached HEAD)"
    fi

    # Get status
    local status changes
    if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
        status="${RED}Uncommitted changes${NC}"
        changes=$(git status --short | wc -l | tr -d ' ')
    else
        status="${GREEN}Clean working tree${NC}"
        changes="0"
    fi

    echo -e "${GREEN}Switched to worktree${NC}"
    echo ""
    echo "📁 Path: $worktree_path"
    echo "🌿 Branch: $branch"
    echo -e "📊 Status: $status ($changes files)"
    echo ""
    echo "💡 To continue working here: cd $worktree_path"
}

# Cleanup worktrees
cmd_cleanup() {
    local force_mode=false
    if [ "${1:-}" = "--force" ]; then
        force_mode=true
    fi

    local repo_root
    repo_root=$(get_repo_root)
    local repo_name
    repo_name=$(basename "$repo_root")
    local main_branch
    main_branch=$(get_main_branch)
    local current_worktree
    current_worktree=$(git rev-parse --show-toplevel 2>/dev/null)
    local original_dir
    original_dir=$(pwd)

    echo -e "${BLUE}Git Worktree Cleanup for: $repo_name${NC}"
    echo "════════════════════════════════════════════════════════"
    echo ""

    declare -a removable_worktrees=()
    local total_count=0
    local safe_count=0

    # Analyze worktrees
    while IFS= read -r line; do
        if [[ $line == worktree* ]]; then
            worktree_path="${line#worktree }"
        elif [[ $line == branch* ]]; then
            branch="${line#branch refs/heads/}"
            ((total_count++))

            # Skip current worktree
            if [ "$worktree_path" = "$current_worktree" ]; then
                echo -e "🔒 Current: $worktree_path (branch: $branch)"
                ((safe_count++))
                continue
            fi

            # Check if directory exists
            if [ ! -d "$worktree_path" ]; then
                echo -e "❌ Missing: $worktree_path (branch: $branch)"
                removable_worktrees+=("$worktree_path|$branch|missing")
                continue
            fi

            # Check for uncommitted changes
            cd "$worktree_path" 2>/dev/null
            if [ $? -eq 0 ]; then
                if [ -n "$(git status --porcelain 2>/dev/null)" ]; then
                    echo -e "⚠️  Has changes: $worktree_path (branch: $branch)"
                    ((safe_count++))
                    cd "$original_dir"
                    continue
                fi

                # Check if merged
                git fetch origin 2>/dev/null || true
                local is_merged
                is_merged=$(git branch -r --merged "origin/$main_branch" 2>/dev/null | grep -c "origin/$branch" 2>/dev/null || echo "0")

                if [ "$is_merged" -gt 0 ]; then
                    echo -e "✅ Merged: $worktree_path (branch: $branch)"
                    removable_worktrees+=("$worktree_path|$branch|merged")
                elif ! git ls-remote --heads origin "$branch" 2>/dev/null | grep -q .; then
                    echo -e "🗑️  Remote deleted: $worktree_path (branch: $branch)"
                    removable_worktrees+=("$worktree_path|$branch|deleted")
                else
                    echo -e "🔄 Active: $worktree_path (branch: $branch)"
                    ((safe_count++))
                fi
                cd "$original_dir"
            fi
        elif [[ $line == detached ]]; then
            ((total_count++))
            if [ "$worktree_path" != "$current_worktree" ]; then
                echo -e "⚠️  Detached: $worktree_path"
                removable_worktrees+=("$worktree_path|detached|detached")
            fi
        fi
    done < <(git worktree list --porcelain)

    echo ""
    echo "────────────────────────────────────────────────────────"
    echo "Summary:"
    echo "  • Total: $total_count worktrees"
    echo "  • Removable: ${#removable_worktrees[@]} worktrees"
    echo "  • Safe/Active: $safe_count worktrees"
    echo ""

    if [ ${#removable_worktrees[@]} -eq 0 ]; then
        echo -e "${GREEN}No worktrees to clean up!${NC}"
        exit 0
    fi

    echo "The following worktrees will be removed:"
    for info in "${removable_worktrees[@]}"; do
        IFS='|' read -r path branch status <<< "$info"
        echo "  • $path ($branch - $status)"
    done
    echo ""

    # Confirm unless force mode
    if [ "$force_mode" = false ]; then
        echo -n "Proceed with cleanup? (y/N): "
        read -r confirm
        if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
            echo "Cleanup cancelled."
            exit 0
        fi
    fi

    echo ""
    echo "Removing worktrees..."

    for info in "${removable_worktrees[@]}"; do
        IFS='|' read -r path branch status <<< "$info"
        echo -n "  Removing $path... "

        git worktree remove "$path" --force 2>/dev/null
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓${NC}"
            if [ "$status" = "merged" ] || [ "$status" = "deleted" ]; then
                git branch -d "$branch" 2>/dev/null || true
            fi
        else
            echo -e "${RED}✗${NC}"
        fi
    done

    echo ""
    echo "Pruning worktree references..."
    git worktree prune

    echo ""
    echo -e "${GREEN}Cleanup complete!${NC}"
}

# Copy env files to worktree
cmd_copy_env() {
    local worktree_path="${1:-}"
    local repo_root
    repo_root=$(get_repo_root)

    # Auto-detect current worktree if not specified
    if [ -z "$worktree_path" ]; then
        local current_dir
        current_dir=$(pwd)
        if [ "$current_dir" != "$repo_root" ] && [ -f "$current_dir/.git" ]; then
            worktree_path="$current_dir"
        else
            echo -e "${RED}Error: Not in a worktree. Specify worktree path or branch name.${NC}"
            echo "Usage: worktree-manager.sh copy-env [worktree-path|branch-name]"
            exit 1
        fi
    elif [ ! -d "$worktree_path" ]; then
        # Try resolving as branch name
        worktree_path="$repo_root/.worktrees/$worktree_path"
        if [ ! -d "$worktree_path" ]; then
            echo -e "${RED}Error: Worktree not found: $1${NC}"
            exit 1
        fi
    fi

    copy_env_files "$repo_root" "$worktree_path"
    echo ""
    echo -e "${GREEN}Environment files copied to: $worktree_path${NC}"
}

# Show help
cmd_help() {
    echo "Git Worktree Manager"
    echo ""
    echo "Usage: worktree-manager.sh <command> [options]"
    echo ""
    echo "Commands:"
    echo "  create <branch> [source]   Create new worktree"
    echo "  list                       List all worktrees"
    echo "  switch <branch|path>       Switch to worktree"
    echo "  cleanup [--force]          Remove merged/unused worktrees"
    echo "  copy-env [worktree]        Copy .env files to worktree"
    echo "  help                       Show this help"
    echo ""
    echo "Worktrees are stored in .worktrees/ within the repository."
}

# Main
main() {
    local command="${1:-help}"
    shift || true

    case "$command" in
        create)
            cmd_create "${1:-}" "${2:-}"
            ;;
        list|ls)
            cmd_list
            ;;
        switch|go)
            cmd_switch "${1:-}"
            ;;
        cleanup|clean)
            cmd_cleanup "${1:-}"
            ;;
        copy-env|env)
            cmd_copy_env "${1:-}"
            ;;
        help|--help|-h)
            cmd_help
            ;;
        *)
            echo -e "${RED}Unknown command: $command${NC}"
            cmd_help
            exit 1
            ;;
    esac
}

main "$@"
