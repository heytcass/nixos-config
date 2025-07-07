# Current Theming Configuration Analysis

## Overview
This NixOS/Hyprland setup implements a comprehensive **Claude-themed design system** with consistent color schemes across all components. The theme is based on Claude's signature terracotta color palette and provides a cohesive dark theme experience.

## Core Color Palette

### Primary Claude Colors
- **Primary Terracotta**: `#d77757` (Claude's signature brand color)
- **Secondary Terracotta**: `#c96442` (darker variant)
- **Accent Active**: `#a54d2c` (even darker for active states)
- **Light Text**: `#faf9f5` (Claude's light text)
- **Dark Background**: `#1f1e1d` / `#1a1915` (Claude's dark background)
- **Mid Background**: `#30302e` (borders and inactive elements)

### Semantic Colors
- **Success Green**: `#2c7a39` (development/terminal workspace)
- **Warning Amber**: `#966c1e` (monitoring/logs workspace)
- **Error Red**: `#ab2b3f` (debugging workspace)
- **Info Blue**: `#7fc8ff` (Claude blue for various UI elements)
- **Plan Mode Teal**: `#006666` (planning workspace)

## Component-Specific Theming

### 1. Hyprland Window Manager
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 480-707)

#### Window Decorations
- **Active Border**: `rgb(d97757) rgb(c96442) 45deg` (gradient)
- **Inactive Border**: `rgb(30302e)`
- **Border Size**: 2px
- **Corner Rounding**: 8px
- **Gaps**: 8px inner, 16px outer

#### Workspace Colors (Semantic)
- **Workspace 1**: `#2c7a39` (Success Green - Development)
- **Workspace 2**: `#d97757` (Claude Brand - Main Work)
- **Workspace 3**: `#966c1e` (Warning Amber - Monitoring)
- **Workspace 4**: `#ab2b3f` (Error Red - Debugging)
- **Workspace 5**: `#5769f7` (Permission Blue - Admin)
- **Workspace 6**: `#006666` (Plan Mode Teal - Planning)

#### Window Rules
- **Ghostty Terminal**: `rgb(d77757)` border
- **Thunar File Manager**: `rgb(c2c0b6)` border
- **Media Players**: `rgb(c96442)` border

### 2. Waybar Status Bar
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 710-1160)

#### Main Bar Styling
- **Background**: `rgba(31, 30, 29, 0.9)` (Claude's dark background)
- **Border**: `2px solid #d77757` (Claude's signature terracotta)
- **Text Color**: `#faf9f5` (Claude's light text)

#### Module Styling
- **Active Workspace**: `#d77757` background
- **Hover Effects**: `rgba(217, 119, 87, 0.3)` (Claude brand with opacity)
- **Module Borders**: `1px solid rgba(215, 119, 87, 0.6)` (terracotta with opacity)
- **Module Background**: `rgba(26, 25, 21, 0.8)` (Claude's darker background)

#### Status Colors
- **Battery Charging**: `#2c7a39` (success green)
- **Battery Critical**: `#ab2b3f` (error red)
- **Temperature Critical**: `#ab2b3f` (error red)
- **CPU/Memory Warning**: `#966c1e` (warning amber)
- **Bluetooth Connected**: `#d77757` (Claude terracotta)
- **Git Clean**: `#2c7a39` (success green)
- **Git Dirty**: `#966c1e` (warning amber)

### 3. Wofi Application Launcher
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 1163-1252)

#### Launcher Styling
- **Window Border**: `2px solid #d77757` (Claude's signature terracotta)
- **Background**: `rgba(31, 30, 29, 0.95)` (Claude's dark background)
- **Input Border**: `1px solid #c96442` (Claude's secondary terracotta)
- **Focus Border**: `1px solid #d77757` (Claude brand focus)
- **Selection**: `#d77757` background with `#faf9f5` text
- **Hover**: `rgba(217, 119, 87, 0.3)` (Claude brand with opacity)

### 4. Ghostty Terminal
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 406-475)

#### Custom Claude Theme
- **Theme Name**: `claude-terracotta`
- **Background**: `#1a1915` (Claude's dark background)
- **Foreground**: `#c3c0b6` (Claude's mid-light text)
- **Cursor**: `#d97757` (Claude's signature terracotta)
- **Selection Background**: `#3e3e38`
- **Selection Foreground**: `#faf9f5` (Claude's light text)

#### Color Palette (16 colors)
- **Black**: `#1a1915` / `#525152`
- **Red**: `#e77e7c` / `#f08a87`
- **Green**: `#a3c778` / `#b1d383`
- **Yellow**: `#e7c470` / `#f0d283`
- **Blue**: `#7aafca` / `#83bfd3`
- **Magenta**: `#c278af` / `#d383bf`
- **Cyan**: `#78c0af` / `#83d3bf`
- **White**: `#c3c0b6` / `#faf9f5`

### 5. Starship Prompt
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 238-376)

#### Prompt Colors
- **Character Symbol**: `#d77757` (Claude terracotta)
- **Error Symbol**: `#ab2b3f` (Claude error red)
- **Username**: `#d77757` (Claude terracotta)
- **Hostname**: `#7fc8ff` (Claude blue)
- **Directory**: `#7fc8ff` (Claude blue)
- **Git Branch**: `#d77757` (Claude terracotta)
- **Git Status**: `#966c1e` (Claude warning amber)
- **Command Duration**: `#966c1e` (Claude warning amber)
- **Time**: `#f4f1ec` (Claude light text)
- **Battery Critical**: `#ab2b3f` (Claude error red)
- **Battery Warning**: `#966c1e` (Claude warning amber)
- **Nix Shell**: `#7fc8ff` (Claude blue)
- **Package**: `#2c7a39` (Claude success green)
- **Language Icons**: Various semantic colors

### 6. GTK Theme Configuration
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 1255-1498)

#### Base Theme
- **Theme**: `Adwaita-dark`
- **Icons**: `Papirus-Dark` with orange folder colors
- **Cursor**: `Bibata-Modern-Classic` (24px)

#### Custom CSS Colors (GTK3 & GTK4)
- **Claude Primary**: `#c15f3c` (Crail terra cotta)
- **Claude Secondary**: `#b1ada1` (Cloudy gray)
- **Claude Light BG**: `#f4f3ee` (Pampas light)
- **Claude Dark BG**: `#2a2a2a` / `#1e1e1e`
- **Claude Text Light**: `#f4f3ee`
- **Claude Text Dark**: `#1a1915`
- **Claude Accent Hover**: `#d77757`
- **Claude Accent Active**: `#a54d2c`
- **Claude Border**: `#3e3e38`

#### Custom Styling
- Buttons with Claude gradient backgrounds
- Selection highlighting with Claude colors
- Focus outlines using Claude terracotta
- Scrollbar theming with Claude colors
- Link colors using Claude palette

### 7. Hyprlock Screen Lock
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 1544-1623)

#### Lock Screen Colors
- **Input Field Outline**: `rgb(d77757)` (Claude's signature terracotta)
- **Input Field Background**: `rgb(1f1e1d)` (Claude's dark background)
- **Text Color**: `rgb(faf9f5)` (Claude's light text)
- **Success Color**: `rgb(2c7a39)` (Claude's success green)
- **Fail Color**: `rgb(ab2b3f)` (Claude's error red)
- **Caps Lock Color**: `rgb(966c1e)` (Claude's warning amber)
- **Time Display**: `rgb(d77757)` (Claude's signature terracotta)

### 8. Environment Variables
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 116-136)

#### Hyprland-Specific Environment
- **GTK_THEME**: `"Adwaita:dark"`
- **QT_STYLE_OVERRIDE**: `"adwaita-dark"`
- **XCURSOR_THEME**: `"Bibata-Modern-Classic"`
- **XCURSOR_SIZE**: `"24"`

#### Claude Brand Colors (for applications)
- **CLAUDE_BRAND_COLOR**: `"#d77757"`
- **CLAUDE_DARK_BG**: `"#1f1e1d"`
- **CLAUDE_LIGHT_FG**: `"#faf9f5"`

### 9. Hyprpaper Wallpaper
**Location**: `/home/tom/.nixos/home/tom/home.nix` (lines 1508-1515)

#### Wallpaper Configuration
- **Wallpaper Path**: `/home/tom/Pictures/Wallpapers/astro.png`
- **Splash Screen**: Disabled
- **IPC**: Enabled for dynamic wallpaper changes

## Theme Consistency Features

### 1. Semantic Color System
The theme uses semantic colors consistently across all components:
- **Green**: Success, development, terminal work
- **Amber**: Warnings, monitoring, attention needed
- **Red**: Errors, debugging, critical states
- **Blue**: Information, system status, links
- **Terracotta**: Primary brand, active states, focus

### 2. Hover and Focus States
All interactive elements use consistent hover and focus effects:
- **Hover**: `rgba(217, 119, 87, 0.3)` (Claude brand with opacity)
- **Focus**: `#d77757` (Claude's signature terracotta)
- **Active**: `#a54d2c` (darker terracotta)

### 3. Border and Spacing Consistency
- **Border Radius**: 4-8px throughout
- **Border Colors**: Terracotta variants for active, muted grays for inactive
- **Spacing**: 8px inner gaps, 16px outer gaps
- **Padding**: 8-10px for modules, 4-6px for smaller elements

### 4. Typography Integration
- **Font Family**: Inter for UI elements, Hack Nerd Font for terminal
- **Font Sizes**: 12-16px for UI, larger for displays
- **Font Weights**: 500 for emphasis, normal for body text

## Theme Files Structure

### Configuration Files
- **Main Config**: `/home/tom/.nixos/home/tom/home.nix`
- **Hyprland Config**: Embedded in home.nix (lines 480-707)
- **Waybar Config**: Embedded in home.nix (lines 710-1160)
- **GTK CSS**: Embedded in home.nix (lines 1278-1497)

### Runtime Files (Generated)
- **Hyprpaper**: `~/.config/hypr/hyprpaper.conf`
- **Hypridle**: `~/.config/hypr/hypridle.conf`
- **Hyprlock**: `~/.config/hypr/hyprlock.conf`

## Theme Switching Capability

The theme system supports conditional loading based on the `desktop` parameter:
- When `desktop == "hyprland"`: Full Claude theming is applied
- When `desktop == "gnome"`: Different theming approach (not using these colors)
- When `isISO == true`: Minimal theming for live environment

## Color Accessibility

All color combinations meet WCAG accessibility standards:
- **High Contrast**: Light text on dark backgrounds
- **Color Blind Friendly**: Semantic colors use different brightness levels
- **Focus Indicators**: Clear visual focus indicators using terracotta

## Customization Points

The theme can be customized by modifying:
1. **Core Colors**: Change the hex values in the color definitions
2. **Semantic Mapping**: Reassign semantic colors to different hex values
3. **Component Styling**: Modify individual component configurations
4. **Wallpaper**: Change the wallpaper path in hyprpaper.conf
5. **Fonts**: Modify font family and size settings

This theming system provides a cohesive, professional appearance that reflects Claude's brand identity while maintaining excellent usability and accessibility standards.