---
title: "Choosing a terminal emulator in 2026: Ghostty, iTerm2, Kitty, Alacritty, WezTerm"
date: 2026-04-02 12:00:00
categories:
- Mac
tags:
- Terminal
- Ghostty
- iTerm2
- Kitty
- Alacritty
- WezTerm
- Warp
- CLI
---

A detailed comparison of every major terminal emulator in 2026 -- performance, features, configuration, platform support, and which one fits your workflow.

<!-- more -->

## Why your terminal matters

Developers spend hours a day in a terminal. The difference between a slow, limited terminal and a fast, well-configured one compounds over time. Modern terminals offer GPU-accelerated rendering, built-in multiplexing, scriptable configuration, inline images, and more -- features that were unthinkable a decade ago.

This guide covers 8 terminals across 3 categories:

| Category | Options | Best for |
|----------|---------|----------|
| **GPU-native, feature-rich** | Ghostty, iTerm2, Kitty, WezTerm | Developers who want speed + features |
| **GPU-native, minimal** | Alacritty | Developers who use tmux and want raw speed |
| **Alternative approaches** | Warp, Hyper | AI-assisted or web-based workflows |

Terminal.app (macOS built-in) is included in tables as a baseline but doesn't get its own section -- it works, but every option above is a meaningful upgrade.

---

## Quick comparison

### Core features

| Feature | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **GPU accelerated** | Metal | Metal (opt-in) | OpenGL | OpenGL/Metal | OpenGL/Metal | Metal | No (Electron) | No |
| **Tabs** | Yes | Yes | Yes | No | Yes | Yes | Yes | Yes |
| **Splits/panes** | Yes | Yes | Yes (layouts) | No | Yes | Yes | Yes | No |
| **Ligatures** | Yes | Yes | Yes | No | Yes | Yes | Yes | No |
| **Inline images** | Yes | Yes (imgcat) | Yes (protocol) | No | Yes (multi) | Yes | No | No |
| **tmux integration** | No | Native control mode | No | No | No | No | No | No |
| **Shell integration** | Deep | Deep | Basic | No | Basic | Deep | No | No |
| **Session save/restore** | Yes | Yes | Session files | No | No | Yes | No | Yes (window groups) |
| **Undo close tab** | Yes | Yes | No | -- | No | Yes | No | No |

### Configuration and extensibility

| Feature | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|---------|---------|--------|-------|-----------|---------|------|-------|-------------|
| **Config format** | key=value | GUI | key=value | TOML | Lua | GUI + YAML | JS | GUI |
| **Config location** | `~/.config/ghostty/config` | Preferences UI | `~/.config/kitty/kitty.conf` | `~/.config/alacritty/alacritty.toml` | `~/.config/wezterm/wezterm.lua` | `~/.warp/` | `~/.hyper.js` | Preferences UI |
| **Live reload** | Keybind | N/A (GUI) | `ctrl+shift+f5` | Yes | Yes | N/A | Yes | N/A |
| **Scripting** | AppleScript (macOS) | Python API | Python (kittens) | No | Lua (full) | No | JS plugins (npm) | No |
| **Profiles** | No | Yes (extensive) | No | No | Domains | Yes | No | Yes |
| **Config complexity** | Very low | Low (GUI) | Low | Low | Medium-High | Low (GUI) | Medium | Very low |

### Performance

| Metric | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|--------|---------|--------|-------|-----------|---------|------|-------|-------------|
| **Rendering speed** | Excellent | Good | Excellent | Best | Good | Good | Poor | Adequate |
| **Input latency** | Very low | Low | Very low | Lowest | Low | Low | High | Medium |
| **Memory baseline** | ~30 MB | ~80-120 MB | ~30 MB | ~20 MB | ~80-150 MB | ~150 MB | ~200 MB | ~40 MB |
| **Startup time** | Fast | Moderate | Fast | Fastest | Moderate | Slow | Slow | Instant |
| **Heavy output (`cat` large file)** | Excellent | Good | Excellent | Excellent | Good | Good | Poor | Slow |

{% note info %}
**Memory numbers are approximate** and vary by OS, tab count, scrollback size, and configuration. Measured with a single tab, default scrollback, on macOS.
{% endnote %}

### Platform support

| Platform | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|----------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **macOS** | Yes | Yes | Yes | Yes | Yes | Yes | Yes | Yes |
| **Linux** | Yes | No | Yes | Yes | Yes | Yes | Yes | No |
| **Windows** | No | No | No (WSL) | Yes | Yes | No | Yes | No |
| **Native feel (macOS)** | Excellent | Excellent | Native chrome | Custom chrome | Custom chrome | Custom chrome | Custom chrome | Native |

Alacritty and Kitty also support BSD.

### Appearance and theming

| Feature | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|---------|---------|--------|-------|-----------|---------|------|-------|-------------|
| **Bundled themes** | 300+ | ~10 (200+ community) | Community (`kitten themes`) | Community (TOML) | 700+ | Built-in | Community (npm) | ~10 |
| **Background image** | Yes | Yes | Yes | No | Yes (Lua) | No | Yes (CSS) | No |
| **Tab bar customization** | Native macOS | Extensive | Extensive | -- | Extensive | Custom | CSS | Native macOS |

All terminals support background opacity, font fallback chains, colored bold, and block/beam/underline cursor styles.

### Developer-facing features

| Feature | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|---------|:---:|:---:|:---:|:---:|:---:|:---:|:---:|:---:|
| **Vi mode (scrollback)** | No | Yes (copy mode) | Pager-based | Yes | Yes | No | No | No |
| **Regex triggers** | No | Yes | No | Yes (hints) | No | No | No | No |
| **Broadcast to panes** | No | Yes | Yes | No | No | No | No | No |
| **Paste history** | No | Yes | No | No | No | No | No | No |
| **SSH multiplexing** | No | Yes (tmux) | SSH kitten | No | Built-in | No | No | No |
| **Command palette** | Yes | No | No | No | Yes | Yes | No | No |
| **AI integration** | No | No | No | No | No | Yes (built-in) | No | No |
| **Block-based output** | No | No | No | No | No | Yes | No | No |

### Project info

| Detail | Ghostty | iTerm2 | Kitty | Alacritty | WezTerm | Warp | Hyper | Terminal.app |
|--------|---------|--------|-------|-----------|---------|------|-------|-------------|
| **Language** | Zig + Swift | Obj-C/Swift | C + Python | Rust | Rust | Rust | Electron (JS) | Obj-C (Apple) |
| **License** | MIT | GPLv2 | GPLv3 | Apache 2.0 | MIT | Proprietary | MIT | Proprietary |
| **First release** | 2024 | 2010 | 2017 | 2017 | 2018 | 2022 | 2016 | 2001 |
| **Account required** | No | No | No | No | No | Yes | No | No |
| **Telemetry** | No | No | No | No | No | Yes | No | Yes (Apple) |
| **Install** | Homebrew / .dmg | Homebrew / .dmg | Homebrew / installer | Homebrew / cargo | Homebrew / .dmg | .dmg | Homebrew / .dmg | Pre-installed |

---

## Detailed breakdown

### Ghostty

Created by Mitchell Hashimoto (HashiCorp co-founder). Written in Zig (with Swift/AppKit for macOS GUI), GPU-accelerated via Metal (macOS) and OpenGL (Linux).

**What makes it different**: Ghostty is the only GPU-native terminal that uses real platform UI. On macOS, it renders with AppKit -- native title bar, native tabs, native menus. It doesn't look like a cross-platform app pretending to be a Mac app. It looks like a Mac app.

The config format is the simplest of any terminal in this list -- flat key=value pairs, no nesting:

```
font-family = FiraCode Nerd Font
font-size = 14
theme = catppuccin-mocha
window-padding-x = 8
window-padding-y = 4
keybind = super+d=new_split:right
keybind = super+shift+d=new_split:down
```

**Strengths:**
- Exceptional rendering performance on par with Alacritty
- Native macOS experience (AppKit, not custom chrome)
- Simplest config format -- easy to learn, easy to share
- Built-in splits without tmux
- Large bundled theme collection
- Active, rapid development

**Weaknesses:**
- No Windows support
- No profiles (one global config)
- Younger than alternatives -- some edge cases may not be handled yet

**Best for**: macOS developers who want speed without sacrificing native UX. If you care about your terminal feeling like a "real Mac app" and want sub-millisecond rendering, this is the one.

---

### iTerm2

The long-standing default upgrade from Terminal.app. Built by George Nachman, maintained for over 15 years.

**What makes it different**: Feature density. iTerm2 has more features than any other terminal, period. The tmux integration alone (where remote tmux sessions render as native iTerm2 tabs and splits) is unique across all terminals. The Python scripting API lets you automate anything.

```python
# iTerm2 Python API example: auto-switch profile by hostname
import iterm2

async def main(connection):
    async with iterm2.SessionTerminationMonitor(connection) as mon:
        while True:
            session = await mon.async_get()
            if "production" in session.name:
                await session.async_set_profile("Production")
```

**Strengths:**
- Most feature-complete terminal on any platform
- tmux control mode -- remote tmux sessions as native tabs
- Python scripting API for automation
- Instant replay (rewind terminal output like a DVR)
- Triggers (regex-based actions on output)
- Paste history, autocomplete, smart selection
- GUI preferences -- no config file needed
- Inline images (imgcat)

**Weaknesses:**
- Heavier resource usage than GPU-native terminals
- macOS only
- Startup is slower than lightweight alternatives
- Can feel bloated if you only need basics

**Best for**: Power users who want everything in one terminal. If you SSH into servers frequently, use tmux, need per-host profiles, or want a scripting API, iTerm2 is hard to beat.

---

### Kitty

Written in C and Python by Kovid Goyal. GPU-rendered from the ground up.

**What makes it different**: Kittens. Kitty's extension system lets you write Python scripts that run inside the terminal process, with access to screen content, terminal state, and input. Built-in kittens include `icat` (inline images), `diff` (side-by-side diffs), `hints` (clickable URLs/paths), and `ssh` (auto-copy terminfo to remote hosts). The Kitty graphics protocol is becoming a de facto standard adopted by other tools.

```bash
# Display an image inline
kitty +kitten icat photo.jpg

# Side-by-side diff
kitty +kitten diff file1.py file2.py

# Copy terminfo + shell integration to a remote host
kitty +kitten ssh user@host
```

Kitty's built-in layouts replace basic tmux usage:

```conf
# kitty.conf -- tiling layouts
enabled_layouts tall:bias=70,fat,grid,splits,stack
map ctrl+shift+l next_layout
map ctrl+shift+enter new_window
```

**Strengths:**
- Kittens extension system -- deeply programmable
- Graphics protocol becoming an industry standard
- Excellent tiling layouts without tmux
- SSH kitten (auto-copies terminfo, shell integration)
- Scrollback via configurable pager (vim, less, etc.)
- Broadcast input to all panes

**Weaknesses:**
- Requires configuration to feel native on macOS
- Community friction (author has strong opinions in issue tracker)
- No GUI settings
- Kitten API has a learning curve

**Best for**: Developers who want a programmable terminal. If you write custom tools, display images/charts in the terminal, or want deep control without tmux, Kitty's extensibility is unmatched.

---

### Alacritty

Famously billed as the "fastest terminal emulator in existence." Written in Rust, GPU-accelerated.

**What makes it different**: Radical minimalism. Alacritty deliberately omits tabs, splits, ligatures, and inline images. The philosophy: the terminal should render text fast and nothing else. Use tmux or your window manager for multiplexing. This means less code, fewer bugs, and the absolute best performance.

```toml
# alacritty.toml -- that's really all you need
[font]
normal.family = "FiraCode Nerd Font"
size = 14.0

[window]
opacity = 0.95
padding = { x = 8, y = 4 }

[colors.primary]
background = "#1e1e2e"
foreground = "#cdd6f4"
```

**Strengths:**
- Fastest and lightest terminal available -- the performance benchmark
- Rock solid stability -- minimal code means minimal bugs
- Broadest platform support (macOS, Linux, Windows, BSD)
- TOML config -- clean, well-documented
- Vi mode for scrollback navigation
- Consistent behavior across all platforms

**Weaknesses:**
- No tabs or splits (by design -- use tmux)
- No ligature support (long-standing, intentional decision)
- No inline images
- No scripting or plugins

**Best for**: tmux users who want the fastest possible rendering layer. If tmux is already your multiplexer and you don't need ligatures or inline images, Alacritty is pure speed with zero bloat.

---

### WezTerm

Written in Rust by Wez Furlong. GPU-accelerated with a Lua configuration engine.

**What makes it different**: Lua. Your config isn't a static file -- it's a program. You can write conditionals, functions, import modules, and react to events. WezTerm also has the best built-in multiplexer of any terminal: tabs, splits, and workspaces that can genuinely replace tmux. The built-in SSH client with multiplexing means you get your full WezTerm experience on remote servers without installing anything.

```lua
-- wezterm.lua -- conditional config based on hostname
local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.font = wezterm.font('FiraCode Nerd Font')
config.font_size = 14.0

-- Different theme on work vs personal machine
if wezterm.hostname() == 'work-laptop' then
  config.color_scheme = 'Catppuccin Latte'
else
  config.color_scheme = 'Catppuccin Mocha'
end

-- Custom status bar
wezterm.on('update-status', function(window)
  local date = wezterm.strftime('%H:%M')
  window:set_right_status(date)
end)

return config
```

**Strengths:**
- Lua config -- full programming language, not just key=value
- Best built-in multiplexer (can genuinely replace tmux)
- SSH multiplexing (remote tabs/splits without tmux on server)
- Supports all three inline image protocols (iTerm2, Kitty, Sixel)
- Excellent native Windows support
- Serial port support (embedded development)

**Weaknesses:**
- Lua config is overkill for simple setups
- Heavier than Alacritty/Ghostty
- Non-native window chrome on macOS
- Documentation can be hard to navigate
- Development pace has slowed in 2025-2026

**Best for**: Power users who want maximum programmability and cross-platform consistency. If you work on macOS + Linux + Windows, or want to replace tmux entirely, WezTerm is the most capable all-in-one option.

---

### Warp

Rust-based, GPU-accelerated, with a fundamentally different UX model.

**What makes it different**: Warp treats the terminal like an IDE. Output is grouped into collapsible blocks per command. There's a persistent input area at the bottom (like a text editor, with cursor navigation). AI is built in -- describe what you want in natural language, and Warp suggests the command. Workflows (saved command templates with parameters) let you share complex commands with your team.

**Strengths:**
- AI command suggestions -- natural language to shell
- Block-based output -- collapse, copy, or share individual commands
- Modern text editing in the input area (multi-cursor, select, undo)
- Workflows -- parameterized command templates
- Team features (shared workflows, team themes)
- Polished, approachable UI

**Weaknesses:**
- **Account required** -- you must sign up to use a terminal (controversial)
- **Proprietary** -- closed source
- **Telemetry** -- sends usage data
- macOS and Linux only (no Windows)
- Heavier memory footprint (~150 MB)
- Non-standard UX can clash with existing muscle memory

**Best for**: Developers new to the terminal who want guidance, or teams that benefit from shared workflows. If the account requirement and closed source don't bother you, the UX is genuinely innovative.

---

### Hyper

Built on Electron by Vercel (the Next.js company). HTML, CSS, and JavaScript all the way down. Themes are CSS, plugins are npm packages. Beautiful out of the box, but Electron means significantly slower rendering (~200 MB memory, noticeable input latency). Development has slowed considerably. **Best for** web developers who want CSS/JS customization and don't mind the performance trade-off. Not recommended for heavy CLI workloads.

---

## Decision guide

| What you want | Best pick | Runner-up |
|---------------|-----------|-----------|
| **Raw speed** | **Alacritty** -- minimal code, maximum performance | Ghostty |
| **macOS native feel** | **Ghostty** -- real AppKit UI, not custom chrome | iTerm2 |
| **Most features** | **iTerm2** -- 15 years of feature accumulation | WezTerm |
| **Drop tmux entirely** | **WezTerm** -- best built-in multiplexer | Kitty |
| **tmux power user** | **Alacritty** -- fastest rendering layer | Ghostty |
| **SSH to many servers** | **iTerm2** -- native tmux control mode | WezTerm (SSH mux) |
| **Extensibility** | **Kitty** (Python kittens) or **WezTerm** (Lua) | -- |
| **Cross-platform (incl. Windows)** | **WezTerm** or **Alacritty** | -- |
| **Simplest config** | **Ghostty** -- flat key=value, no nesting | Alacritty (TOML) |
| **New to the terminal** | **Warp** -- AI guidance, IDE-like UX | iTerm2 (GUI) |
| **Privacy / no telemetry** | **Alacritty**, **Ghostty**, or **Kitty** | -- |
| **Team collaboration** | **Warp** -- shared workflows | -- |

### Migration path from Terminal.app

Most macOS developers follow this progression:

```
Terminal.app → iTerm2 → (split here)
                          ├→ Ghostty (want native + fast)
                          ├→ Alacritty + tmux (want minimal + fast)
                          ├→ Kitty (want extensible)
                          └→ WezTerm (want all-in-one)
```

---

## Installing

All terminals are available via Homebrew:

```bash
brew install --cask ghostty
brew install --cask iterm2
brew install --cask kitty
brew install --cask alacritty
brew install --cask wezterm
brew install --cask warp
brew install --cask hyper
```

---

## Verdict

There's no single "best" terminal -- it depends on what you value. But here's how I'd summarize the landscape in 2026:

- **Ghostty** is the new default recommendation for macOS. Native feel, excellent performance, simple config. It's what Terminal.app would be if Apple rebuilt it today.
- **iTerm2** remains king for feature completeness. If you need a specific capability, iTerm2 probably has it.
- **Kitty** is the hacker's terminal. Kittens and the graphics protocol give you capabilities no other terminal offers.
- **Alacritty** is the purist's choice. Fastest, lightest, most stable -- if you're already married to tmux.
- **WezTerm** is the Swiss Army knife. Does everything, runs everywhere, configured with a real programming language.
- **Warp** is genuinely innovative but the account requirement and closed source are dealbreakers for many developers.

Pick one, configure it, and move on. The best terminal is the one you stop thinking about.
