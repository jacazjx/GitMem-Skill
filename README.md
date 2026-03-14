# GitMem Safe Editing

A skill for AI code agents that provides safe, traceable, and reversible file editing using a separate `.gitmem` repository as an edit safety layer.

## The Problem

AI code agents (Claude, ChatGPT, Cursor, etc.) often fall into destructive edit loops:

```
edit → break → fix → break → fix → break → ...
```

Each edit overwrites the previous state, making it impossible to:
- See what changed and when
- Roll back to a working version
- Compare different iterations
- Recover from accumulated damage

## The Solution

GitMem creates a **separate git repository** (`.gitmem/`) that tracks every agent edit independently from your main project's git history.

```
your-project/
├── .git/          # Your main repository (untouched)
├── .gitmem/       # Agent edit safety layer
│   └── .git/
├── src/
└── ...
```

**Key benefits:**
- 🔄 **Every edit is committed** - Full history of agent changes
- ⏪ **Easy rollback** - Restore any file to any previous state
- 🔍 **Diff and compare** - See exactly what changed between versions
- 🏷️ **Checkpoints** - Mark stable states before risky changes
- 🚫 **No pollution** - Your main git history stays clean
- 📦 **Zero dependencies** - Pure git, no databases or external services

## Installation

### Claude Code

1. **Clone or download** this repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/gitmem-safe-editing.git
   ```

2. **Install to Claude Code**:
   ```bash
   # Method 1: Copy to Claude's skills directory
   cp -r gitmem-safe-editing ~/.claude/skills/

   # Method 2: Create a symlink (recommended for updates)
   ln -s $(pwd)/gitmem-safe-editing ~/.claude/skills/gitmem-safe-editing
   ```

3. **Restart Claude Code** or start a new session.

### Codex / OpenAI

1. **Clone or download** this repository.

2. **Copy to Codex skills directory**:
   ```bash
   cp -r gitmem-safe-editing ~/.codex/skills/
   ```

3. **Or use the provided agent config**:
   The `agents/openai.yaml` file contains configuration for OpenAI-compatible agents.

### Install CLI Tools (Optional)

For command-line access to GitMem operations:

```bash
cd gitmem-safe-editing/scripts
./install.sh

# Add to PATH if needed
export PATH="$HOME/.local/bin:$PATH"
```

## Usage

### Basic Workflow

When you ask the AI to edit files, GitMem automatically:
1. Records each edit in `.gitmem`
2. Makes changes traceable and reversible
3. Warns about edit loops

**Example prompts that trigger GitMem:**
- "Edit my config.yaml and make sure I can undo if something goes wrong"
- "Refactor the authentication module but keep a checkpoint"
- "The last edit broke the tests, show me what changed"
- "Go back to the version from 3 edits ago"

### CLI Commands

| Command | Description |
|---------|-------------|
| `gitmem init` | Initialize .gitmem repository |
| `gitmem commit <file> [reason]` | Commit a single file |
| `gitmem history [file]` | Show edit history |
| `gitmem diff <file>` | Diff between last two versions |
| `gitmem rollback <file> [commit]` | Roll back a file |
| `gitmem undo` | Undo last gitmem change |
| `gitmem checkpoint <name>` | Create a checkpoint tag |
| `gitmem status` | Show gitmem status |
| `gitmem watch` | Auto-monitor file changes |
| `gitmem check-loop <file>` | Check for edit loop warning |

### Auto-Watch Mode

Automatically commit every file change to GitMem:

```bash
gitmem watch
```

Options:
- `--debounce SECONDS` - Wait before committing (default: 2)
- `--exclude PATTERN` - Additional exclude pattern
- `--dry-run` - Show what would be committed

## Project Structure

```
gitmem-safe-editing/
├── SKILL.md                 # Main skill definition
├── agents/
│   └── openai.yaml          # OpenAI/Codex agent config
├── scripts/
│   ├── gitmem               # Main CLI command
│   ├── gitmem-init          # Initialization helper
│   ├── gitmem-watch         # File watcher for auto-commit
│   └── install.sh           # Installation script
├── references/
│   └── command-recipes.md   # Git command reference
├── evals/
│   └── evals.json           # Behavior test cases
└── README.md                # This file
```

## Core Operations

### 1. Edit with Auto-Commit
After editing any file, immediately commit to GitMem:
```bash
git --git-dir=.gitmem/.git --work-tree=. add -- <file>
git --git-dir=.gitmem/.git --work-tree=. commit -m "agent(edit): <file>

reason: <why>"
```

### 2. View File History
```bash
git --git-dir=.gitmem/.git --work-tree=. log -- <file>
```

### 3. Compare Versions
```bash
git --git-dir=.gitmem/.git --work-tree=. diff <commit_a> <commit_b> -- <file>
```

### 4. Rollback a File
```bash
git --git-dir=.gitmem/.git --work-tree=. checkout <commit> -- <file>
```

### 5. Create Checkpoint
```bash
git --git-dir=.gitmem/.git --work-tree=. tag gitmem-checkpoint-<name>
```

### 6. Undo Last Change
```bash
git --git-dir=.gitmem/.git --work-tree=. reset --hard HEAD~1
```

## Loop Guard

GitMem detects when a file has been edited repeatedly without reaching a stable state:

- Warns when a file appears in 5+ recent commits without a checkpoint
- Recommends rollback or checkpointing
- Prevents infinite edit-fix-break cycles

## Error Handling

The skill includes comprehensive error handling for:
- GitMem not initialized
- Corrupted repository
- File conflicts between .git and .gitmem
- No history found for file
- Merge conflicts
- Disk space concerns

See `SKILL.md` for detailed recovery procedures.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## License

MIT License - see LICENSE file for details.

---

**Made with ❤️ for safer AI-assisted coding**