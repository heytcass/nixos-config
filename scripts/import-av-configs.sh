#!/usr/bin/env bash
# Import Audio/Video Configuration Script
# Automatically imports EasyEffects presets and sets up basic OBS configuration

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIGS_DIR="$(dirname "$SCRIPT_DIR")/configs"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Import EasyEffects preset
import_easyeffects_preset() {
    log_info "Importing EasyEffects professional preset..."
    
    # Create EasyEffects config directory if it doesn't exist
    mkdir -p ~/.config/easyeffects/input
    mkdir -p ~/.config/easyeffects/output
    
    # Copy the professional preset
    if [ -f "$CONFIGS_DIR/easyeffects-professional-calls.json" ]; then
        cp "$CONFIGS_DIR/easyeffects-professional-calls.json" ~/.config/easyeffects/input/Professional\ Calls\ Input.json
        log_success "EasyEffects preset 'Professional Calls Input' imported"
        
        # Set as default preset
        cat > ~/.config/easyeffects/settings.json << EOF
{
  "input": {
    "last_loaded_preset": "Professional Calls Input",
    "process_all_inputs": true,
    "use_default_input": true
  },
  "output": {
    "last_loaded_preset": "",
    "process_all_outputs": true,
    "use_default_output": true
  }
}
EOF
        log_success "Set 'Professional Calls Input' as default preset"
    else
        log_error "EasyEffects preset file not found: $CONFIGS_DIR/easyeffects-professional-calls.json"
        return 1
    fi
}

# Create basic OBS scene collection
create_obs_scene() {
    log_info "Creating basic OBS scene collection..."
    
    # Create OBS config directory
    mkdir -p ~/.config/obs-studio/basic/scenes
    
    # Create basic scene collection with video call scene
    cat > ~/.config/obs-studio/basic/scenes/Professional\ Calls.json << 'EOF'
{
    "current_scene": "Video Call Scene",
    "current_program_scene": "Video Call Scene",
    "scene_order": [
        {
            "name": "Video Call Scene"
        }
    ],
    "name": "Video Call Scene",
    "sources": [
        {
            "balance": 0.5,
            "deinterlace_field_order": 0,
            "deinterlace_mode": 0,
            "enabled": true,
            "flags": 0,
            "hotkeys": {},
            "id": "v4l2_input",
            "mixers": 255,
            "monitoring_type": 0,
            "muted": false,
            "name": "Camera",
            "prev_ver": 469762048,
            "private_settings": {},
            "push-to-mute": false,
            "push-to-mute-delay": 0,
            "push-to-talk": false,
            "push-to-talk-delay": 0,
            "settings": {
                "device_id": "/dev/video1",
                "input": 0,
                "input_format": 0,
                "resolution": "1280x720",
                "framerate": "30",
                "pixel_format": "MJPEG",
                "color_range": 1,
                "buffering": true,
                "auto_reset": true,
                "timeout": 0
            },
            "sync": 0,
            "versioned_id": "v4l2_input",
            "volume": 1.0
        }
    ]
}
EOF
    
    log_success "Created OBS 'Professional Calls' scene collection"
    log_info "Scene includes basic camera source - you can modify device_id in OBS settings"
}

# Set up automatic startup applications
setup_autostart() {
    log_info "Setting up automatic startup for A/V applications..."
    
    mkdir -p ~/.config/autostart
    
    # EasyEffects autostart
    cat > ~/.config/autostart/easyeffects.desktop << EOF
[Desktop Entry]
Type=Application
Name=EasyEffects
Comment=Audio effects for PipeWire
Exec=easyeffects --gapplication-service
Icon=easyeffects
StartupNotify=false
Terminal=false
Categories=AudioVideo;Audio;
Keywords=equalizer;audio;effect;
X-GNOME-Autostart-enabled=true
EOF
    
    log_success "EasyEffects will auto-start on login"
    
    log_info "Note: OBS auto-start not configured to avoid resource usage when not needed"
    log_info "Launch OBS manually and start virtual camera when needed for calls"
}

# Main execution
main() {
    log_info "Importing Audio/Video configurations..."
    
    import_easyeffects_preset || log_error "EasyEffects import failed"
    create_obs_scene || log_error "OBS scene creation failed"
    setup_autostart || log_error "Autostart setup failed"
    
    log_success "Audio/Video configuration import completed!"
    log_info ""
    log_info "Next steps:"
    log_info "1. Launch EasyEffects and verify 'Professional Calls Input' preset is loaded"
    log_info "2. Launch OBS and load 'Professional Calls' scene collection"
    log_info "3. In OBS, adjust camera device if needed (built-in: /dev/video1, Logitech: /dev/video5)"
    log_info "4. Start OBS Virtual Camera for video calls"
    log_info "5. Use 'EasyEffects Source' as microphone in video call apps"
}

main "$@"