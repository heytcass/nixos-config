# Hyprland Keybinding Cheat Sheet

A comprehensive guide to all configured keybindings in your Claude-themed Hyprland desktop environment.

## Legend
- `$mod` = Super key (Windows/Cmd key)
- `Print` = Print Screen key
- `Return` = Enter key

---

## 🚀 Application Launchers

| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Space` | Launch Application Menu | Opens wofi launcher with Claude theme |
| `$mod + Return` | Terminal | Opens Ghostty terminal |
| `$mod + E` | File Manager | Opens Thunar file manager |

---

## 🪟 Window Management

### Basic Controls
| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Q` | Kill Active Window | Closes the focused window |
| `$mod + M` | Exit Hyprland | Logs out of the session |
| `$mod + V` | Toggle Floating | Makes window float/unfloat |
| `$mod + P` | Pseudo-tile | Enables pseudo-tiling mode |
| `$mod + J` | Toggle Split | Changes split direction |
| `$mod + F` | Fullscreen | Toggles fullscreen mode |

### Window Focus (Arrow Keys)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Left` | Focus Left | Move focus to left window |
| `$mod + Right` | Focus Right | Move focus to right window |
| `$mod + Up` | Focus Up | Move focus to upper window |
| `$mod + Down` | Focus Down | Move focus to lower window |

### Move Windows (Shift + Arrow Keys)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Shift + Left` | Move Window Left | Move active window left |
| `$mod + Shift + Right` | Move Window Right | Move active window right |
| `$mod + Shift + Up` | Move Window Up | Move active window up |
| `$mod + Shift + Down` | Move Window Down | Move active window down |

### Mouse Window Actions
| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Left Click` | Move Window | Drag to move floating windows |
| `$mod + Right Click` | Resize Window | Drag to resize windows |

---

## 🏢 Workspaces (Claude Semantic System)

### Switch to Workspace
| Keybinding | Workspace | Theme | Description |
|------------|-----------|-------|-------------|
| `$mod + 1` | Workspace 1 | 🟢 Success Green | Development/Terminal |
| `$mod + 2` | Workspace 2 | 🧡 Claude Brand | Main Work |
| `$mod + 3` | Workspace 3 | 🟡 Warning Amber | Monitoring/Logs |
| `$mod + 4` | Workspace 4 | 🔴 Error Red | Debugging |
| `$mod + 5` | Workspace 5 | 🔵 Permission Blue | Admin Tasks |
| `$mod + 6` | Workspace 6 | 🟦 Plan Mode Teal | Planning/Design |
| `$mod + 7-0` | Workspaces 7-10 | Default | General purpose |

### Move Window to Workspace
| Keybinding | Action | Description |
|------------|--------|-------------|
| `$mod + Shift + 1-0` | Move to Workspace | Moves active window to specified workspace |

---

## 📸 Screenshots

### Save to File (`~/Pictures/Screenshots/`)
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Print` | Area Screenshot | Select area and save to file |
| `$mod + Print` | Full Screenshot | Capture entire screen to file |

### Copy to Clipboard
| Keybinding | Action | Description |
|------------|--------|-------------|
| `Shift + Print` | Area to Clipboard | Select area and copy to clipboard |
| `$mod + Shift + Print` | Full to Clipboard | Copy entire screen to clipboard |

**File Format:** `screenshot-YYYYMMDD_HHMMSS.png`
**Save Location:** `~/Pictures/Screenshots/`

---

## 🔊 Media Controls

### Audio
| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86AudioRaiseVolume` | Volume Up | Increase volume by 5% |
| `XF86AudioLowerVolume` | Volume Down | Decrease volume by 5% |
| `XF86AudioMute` | Mute Toggle | Toggle audio mute |

### Media Playback
| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86AudioPlay` | Play/Pause | Toggle media playback |
| `XF86AudioNext` | Next Track | Skip to next track |
| `XF86AudioPrev` | Previous Track | Go to previous track |

### System
| Keybinding | Action | Description |
|------------|--------|-------------|
| `XF86MonBrightnessUp` | Brightness Up | Increase screen brightness |
| `XF86MonBrightnessDown` | Brightness Down | Decrease screen brightness |

---

## 🎨 Claude Theme Features

### Workspace Color Coding
Each workspace has a semantic color theme that matches Claude's design system:

- **Workspace 1** (🟢): Success Green (`#2c7a39`) - For development and terminal work
- **Workspace 2** (🧡): Claude Brand (`#d77757`) - For main productivity tasks
- **Workspace 3** (🟡): Warning Amber (`#966c1e`) - For monitoring and system logs
- **Workspace 4** (🔴): Error Red (`#ab2b3f`) - For debugging and troubleshooting
- **Workspace 5** (🔵): Permission Blue (`#5769f7`) - For administrative tasks
- **Workspace 6** (🟦): Plan Mode Teal (`#006666`) - For planning and design work

### Application-Specific Theming
- **Ghostty Terminal**: Claude brand terracotta borders
- **Thunar File Manager**: Claude secondary colors
- **Media Applications**: Claude accent colors
- **Wofi Launcher**: Full Claude color scheme with terracotta highlights
- **Waybar**: Claude-themed status bar with semantic workspace indicators

---

## 🔧 Pro Tips

1. **Workspace Organization**: Use the semantic workspace system to organize your workflow
2. **Screenshot Workflow**: Use `Print` for files, `Shift + Print` for quick clipboard sharing
3. **Window Management**: Master the arrow key combinations for efficient window navigation
4. **Application Access**: `$mod + Space` is your main application launcher
5. **Quick File Access**: `$mod + E` opens the file manager instantly

---

## 🆘 Emergency Commands

| Keybinding | Action | When to Use |
|------------|--------|-------------|
| `$mod + M` | Exit Hyprland | If system becomes unresponsive |
| `Ctrl + Alt + F1-F6` | Switch to TTY | If GUI completely fails |
| `$mod + Q` | Close Window | If application is frozen |

---

**Theme:** Claude Dark with Terracotta Accents
**Generated:** $(date)
**Configuration:** NixOS with Home Manager
**Desktop:** Hyprland with Claude Custom Theme
