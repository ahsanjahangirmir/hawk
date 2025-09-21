# HAWK — Natural Language → `awk` ⚡️

> **Developer‑friendly CLI to translate plain English into working `awk` one‑liners.**  
> Ask for what you want; get a safe, copy‑ready command — or run it immediately.

---

## Table of Contents
- [What is HAWK?](#what-is-hawk)
- [Key Features](#key-features)
- [Requirements](#requirements)
- [Quick Start](#quick-start)
- [Installing Ollama](#installing-ollama)
- [Running Ollama as a LaunchAgent (Recommended)](#running-ollama-as-a-launchagent-recommended)
- [Installing HAWK Globally (Symlink, no moving)](#installing-hawk-globally-symlink-no-moving)
- [Temporary (one‑session) Activation](#temporary-one-session-activation)
- [Usage & Examples](#usage--examples)
  - [Generate + copy](#generate--copy)
  - [Run immediately](#run-immediately)
  - [Dry run (preview only)](#dry-run-preview-only)
  - [Explanation inline](#explanation-inline)
  - [History & recall](#history--recall)
  - [Teach mode (reverse: explain an awk)](#teach-mode-reverse-explain-an-awk)
  - [Interactive REPL](#interactive-repl)
  - [Batch mode (file of prompts)](#batch-mode-file-of-prompts)
- [How HAWK Works](#how-hawk-works)
- [Troubleshooting](#troubleshooting)
- [Updating, Stopping, and Uninstalling](#updating-stopping-and-uninstalling)
- [Development Notes](#development-notes)
- [License](#license)

---

## What is HAWK?
**HAWK** turns natural language like:

> “make me a command that prints the distinct values in the second column of `file.csv`”

into a working `awk` command such as:

```bash
awk -F, '{print $2}' file.csv | sort -u
```

You can choose to **copy the command to the clipboard** or **run it immediately**.  
Built for speed and comfort on macOS with Apple Silicon (but works anywhere Ollama runs).

---

## Key Features
- **NL → `awk`**: Translate plain English into `awk` one‑liners.
- **Copy or Run**: `hawk "<prompt>"` copies; `hawk --run "<prompt>"` executes.
- **Explanations**: `--explain` adds a one‑line summary of what the command does.
- **Dry Run**: `--dry` previews the command without copying or running.
- **History & Recall**:
  - `hawk history [N]` shows the last *N* commands.
  - `hawk --1`, `hawk --2`, … copies the last / second last command.
  - `hawk history --search "<term>"` finds prior commands.
- **Teach Mode**: `hawk --teach "<awk cmd>"` explains an `awk` command in English.
- **Interactive REPL**: `hawk --interactive` for rapid iteration.
- **Batch Mode**: `hawk --file prompts.txt` processes many prompts at once.
- **Polished UX**: Colorized output, clear messaging, and helpful errors.

---

## Requirements
- **OS**: macOS (Apple Silicon recommended). Linux/Windows (with Ollama) also work.
- **Runtime**: Python 3.9+ (used by the `hawk` CLI), `pbcopy` on macOS for clipboard.
- **Ollama**: Local LLM runtime (listens on `http://localhost:11434`).
- **Model**: Small, code‑oriented model is sufficient:
  - `qwen2.5-coder:3b` (≈2 GB when quantized) → **fast & light** on Apple Silicon.
- **Hardware Guidance** (rules of thumb):
  - 3B–7B models run great on 8–16 GB RAM Apple Silicon.
  - Downloads require free disk space for models (a few GB per model).

> **Note:** HAWK expects Ollama to be running. If it’s not, HAWK will print a friendly error and exit.

---

## Quick Start

```bash
# 1) Ensure hawk is executable
chmod +x ~/playground/hawk/hawk

# 2) (Recommended) Install with a global symlink (see section below)
ln -s ~/playground/hawk/hawk /opt/homebrew/bin/hawk

# 3) Install and start Ollama + pull the model
brew install ollama
ollama serve &> ~/ollama.log &            # temporary background
ollama pull qwen2.5-coder:3b
ollama run qwen2.5-coder:3b "print hello world"  # sanity check

# 4) Try HAWK
hawk "make me a command that prints the distinct values in the second column of file.csv"
```

---

## Installing Ollama

```bash
brew install ollama
```

Pull a suitable model:

```bash
ollama pull qwen2.5-coder:3b
```

Quick test (should respond instantly):

```bash
ollama run qwen2.5-coder:3b "print hello world"
```

If you plan to use HAWK regularly, run Ollama as a background service (next section).

---

## Running Ollama as a LaunchAgent (Recommended)

Create the LaunchAgent file at:
```
~/Library/LaunchAgents/com.user.ollama.serve.plist
```

Paste the following (Apple Silicon Homebrew path shown):

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
 "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
  <dict>
    <key>Label</key>
    <string>com.user.ollama.serve</string>

    <key>ProgramArguments</key>
    <array>
      <string>/opt/homebrew/bin/ollama</string>
      <string>serve</string>
    </array>

    <key>RunAtLoad</key>
    <true/>

    <key>KeepAlive</key>
    <true/>

    <key>StandardOutPath</key>
    <string>/Users/USERNAME/ollama.log</string>

    <key>StandardErrorPath</key>
    <string>/Users/USERNAME/ollama.err</string>
  </dict>
</plist>
```

> Replace `USERNAME` with your macOS username.

Load/unload and control:

```bash
launchctl unload ~/Library/LaunchAgents/com.user.ollama.serve.plist
launchctl load   ~/Library/LaunchAgents/com.user.ollama.serve.plist
launchctl list | grep ollama
launchctl stop   com.user.ollama.serve
launchctl start  com.user.ollama.serve
```

**Debug triple‑check** (handy one‑liner):

```bash
launchctl list | grep ollama && ps aux | grep ollama && curl http://localhost:11434/api/tags
```

**Expected output** (example):

```
67050  0  com.user.ollama.serve
newuser 67050  ...  /opt/homebrew/bin/ollama serve
{"models":[{"name":"qwen2.5-coder:3b", ... }]}
```

---

## Installing HAWK Globally (Symlink, no moving)

Keep your repo in place, but expose the CLI globally:

```bash
chmod +x ~/playground/hawk/hawk
ln -s ~/playground/hawk/hawk /opt/homebrew/bin/hawk
which hawk
# -> /opt/homebrew/bin/hawk
```

To update or relink later:

```bash
rm /opt/homebrew/bin/hawk
ln -s ~/playground/hawk/hawk /opt/homebrew/bin/hawk
```

---

## Temporary (one‑session) Activation

```bash
export PATH="$HOME/playground/hawk:$PATH"
```

This only affects the current shell session.

---

## Usage & Examples

### Generate + copy
```bash
hawk "make me a command that prints the distinct values in the second column of file.csv"
# copies to clipboard, prints confirmation
```

### Run immediately
```bash
hawk --run "sum the last column in data.csv"
# executes the command
```

### Dry run (preview only)
```bash
hawk --dry "print rows where third column > 100 in data.csv"
# shows the command, does not copy or run
```

### Explanation inline
```bash
hawk --explain "sum the third column in payroll.csv"
# copies + prints a one-line explanation
```

### History & recall
```bash
hawk history           # show last 10
hawk history 50        # show last 50
hawk history --search sum   # fuzzy search
hawk --1               # copy the last command
hawk --2               # copy the second last
```

### Teach mode (reverse: explain an awk)
```bash
hawk --teach "awk -F, '{sum+=$3} END {print sum}' payroll.csv"
# prints a plain-English explanation of the provided awk command
```

### Interactive REPL
```bash
hawk --interactive
# type natural language prompts repeatedly; 'exit' to quit
```

### Batch mode (file of prompts)
Create a `prompts.txt` (one prompt per line) then:

```bash
hawk --file prompts.txt
# prints "<prompt> → <generated awk>", and records history
```

---

## How HAWK Works

- HAWK sends your prompt to **Ollama** (`/api/generate` on `localhost:11434`).
- The system prompt **forces JSON output** like:
  ```json
  { "cmd": "awk -F, '{print $2}' file.csv | sort -u", "explain": "Print unique values in column 2." }
  ```
- HAWK extracts and:
  - **Copies** it (default),
  - **Runs** it (`--run`),
  - **Shows** it (`--dry`),
  - **Logs** it to `~/.hawk_history`.

> HAWK asks the model to prefer **`sort -u`** over `sort | uniq`, default file name to `file.csv` when none is given, and avoid non‑awk tools.

---

## Troubleshooting

### “command not found: hawk”
- Ensure the symlink exists and is executable:
  ```bash
  which hawk
  ls -l /opt/homebrew/bin/hawk
  chmod +x ~/playground/hawk/hawk
  rm /opt/homebrew/bin/hawk && ln -s ~/playground/hawk/hawk /opt/homebrew/bin/hawk
  ```

### HAWK prints an Ollama error
- **Friendly error**:  
  ```
  ⚠️  Ollama is not running or failed to respond.
     Start it with: ollama serve (or check LaunchAgent).
  ```
- Fix by ensuring the service is live:
  ```bash
  curl http://localhost:11434/api/tags         # should return JSON
  launchctl list | grep ollama                 # service listed?
  tail -n 50 ~/ollama.err                      # check errors
  ```
- Verify the LaunchAgent path points to: `/opt/homebrew/bin/ollama` (Apple Silicon).  
  Intel Macs often use `/usr/local/bin/ollama`.

### HTTP 404 from Ollama
- Make sure HAWK posts to `/api/generate` (not a custom path).

### Connection refused / port closed
- Ollama not running:
  ```bash
  ollama serve > ~/ollama.log 2>&1 &
  ```
- Or (LaunchAgent):
  ```bash
  launchctl unload ~/Library/LaunchAgents/com.user.ollama.serve.plist
  launchctl load   ~/Library/LaunchAgents/com.user.ollama.serve.plist
  ```

### Permission denied
- Ensure executable bit:
  ```bash
  chmod +x ~/playground/hawk/hawk
  ```

### Clipboard didn’t change
- macOS uses `pbcopy`. Confirm:
  ```bash
  command -v pbcopy
  ```

### Model download is slow / large
- Prefer `qwen2.5-coder:3b` for small size and speed.
- Ensure stable internet; free space for model blobs.
- You can remove models later with:
  ```bash
  ollama rm qwen2.5-coder:3b
  ```

---

## Updating, Stopping, and Uninstalling

### Update HAWK (symlink install)
```bash
# if already linked, no action needed — edits in your repo apply immediately
# to relink:
rm /opt/homebrew/bin/hawk
ln -s ~/playground/hawk/hawk /opt/homebrew/bin/hawk
```

### Stop/Start the LaunchAgent
```bash
launchctl stop  com.user.ollama.serve
launchctl start com.user.ollama.serve
launchctl unload ~/Library/LaunchAgents/com.user.ollama.serve.plist
launchctl load   ~/Library/LaunchAgents/com.user.ollama.serve.plist
```

### Uninstall HAWK completely
```bash
# 1) Remove global command (symlink)
rm /opt/homebrew/bin/hawk

# 2) Remove history & logs
rm -f ~/.hawk_history ~/ollama.log ~/ollama.err

# 3) Unload and delete LaunchAgent
launchctl unload ~/Library/LaunchAgents/com.user.ollama.serve.plist
rm -f ~/Library/LaunchAgents/com.user.ollama.serve.plist

# 4) (Optional) Remove model(s) and Ollama itself
ollama rm qwen2.5-coder:3b
brew uninstall ollama
# You may also remove ~/.ollama if you want to clear cached models:
rm -rf ~/.ollama
```

---

## Development Notes
- **History file**: `~/.hawk_history`. Clear it with `> ~/.hawk_history`.
- **Colors**: ANSI colors are set in the script (`GREEN`, `YELLOW`, `RED`, `CYAN`).  
  If your terminal doesn’t like colors, you can strip them in the script.
- **Model choice**: Default is `qwen2.5-coder:3b`. You can change it in code.
- **Safety**: Current version does not enforce a pipeline whitelist when `--run`. Use caution when running generated commands.

---