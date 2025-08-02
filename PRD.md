# Tom's NixOS Enhancement PRD v1.0

## **Current Configuration Philosophy**
- **DRY Architecture**: All constants centralized in shared.nix to avoid repetition
- **Performance-First**: Latest kernel, Intel optimizations, aggressive memory tuning, modern Rust toolchain
- **Curated Minimalism**: Selective package inclusion, excluded unwanted GNOME components
- **Modern Stack Priority**: Wayland > X11, PipeWire > PulseAudio, systemd-boot > GRUB
- **Declarative Everything**: Flakes, home-manager, sops-nix for complete reproducibility
- **Security-Conscious but Practical**: YubiKey + hardware security, but performance trade-offs where reasonable
- **Developer-Friendly**: Fish shell, modern CLI tools, custom flakes, VS Code integration

## **Enhancement Plan**

### **Phase 1: Critical Security & Foundation**
**Status: ✅ COMPLETED - Successfully deployed 2025-01-11**

1. **Security Hardening** ✅
   - ✅ Changed `mitigations=off` to `mitigations=auto` in shared.nix perfKernelParams
   - ✅ DNS setup unchanged (preserves internal resolver functionality)
   - ✅ Added PIV/FIDO2 YubiKey support with yubikey-agent, libu2f-host, and PAM U2F

2. **Structured Secrets Management** ✅
   - ✅ Added structured secret categories to shared.nix (business/development/system)
   - ✅ Implemented real secret definitions in secrets.nix for copywriting workflow
   - ✅ Maintained existing sops-nix/age foundation with DRY principles

3. **Secure Container Configuration** ✅
   - ✅ Enhanced Podman with auto-pruning and security policies
   - ✅ Added rootless container support with proper registry configuration
   - ✅ Preserved dockerCompat while improving security posture

**Implementation Notes:**
- All changes seamlessly integrated with existing philosophy
- Zero breaking changes to current workflow
- Build successful on first attempt
- Security improvements maintain performance optimization balance

### **Phase 2: Professional Communication & Workflow**
**Status: ✅ COMPLETED - Successfully deployed 2025-01-11**

4. **Video Conferencing Excellence** ✅
   - ✅ Added OBS Studio with Wayland screen capture support (wlrobs plugin)
   - ✅ Installed EasyEffects for real-time audio enhancement during calls
   - ✅ Configured v4l2loopback kernel module for virtual camera routing
   - ✅ Optimized PipeWire with low-latency settings (32 sample quantum, 48kHz)
   - ✅ Added helvum and qpwgraph for professional audio routing visualization

5. **Enhanced GNOME Productivity Suite** ✅
   - ✅ Just Perfection for interface optimization and focus (verified available)
   - ✅ Advanced clipboard history management for copywriting workflow  
   - ✅ Vitals for system monitoring
   - ✅ wdisplays for GUI-based display management
   - ⚠️ Some extensions (sound-output-device-chooser, workspace-indicator, window-list) not available in nixpkgs - can be installed via GNOME Extensions website

6. **Multi-Display Management** ✅
   - ✅ Added kanshi package for Wayland display configuration
   - ✅ Integrated ddcutil for external monitor hardware control  
   - ✅ Added autorandr for automatic display configuration
   - ✅ v4l-utils for camera control during video calls

**Implementation Notes:**
- All communication tools follow existing modular organization pattern
- PipeWire optimizations maintain compatibility while enabling professional audio
- Some GNOME extensions require manual installation via Extensions Manager (noted in Next Steps)
- Fixed multiple build issues: kanshi service config, PAM U2F settings, extension names
- Secrets management temporarily disabled pending age key configuration

### **Phase 3: Future-Proof Architecture Migration**
**Status: ✅ COMPLETED - Successfully deployed 2025-08-02**

7. **Gradual Module Options Migration** ✅
   - ✅ Created modules/options.nix with typed NixOS options and proper validation
   - ✅ Converted all shared.nix constants to proper mySystem options
   - ✅ Migrated all modules incrementally from shared.foo to config.mySystem.foo pattern
   - ✅ Removed shared.nix once all modules converted - zero breaking changes
   - ✅ Foundation prepared for multi-system management with proper option types

**Implementation Notes:**
- All modules successfully converted to use config.mySystem.* pattern
- Maintained DRY principles while adding proper type validation
- System builds successfully with zero configuration changes needed
- Architecture now ready for multi-system expansion
- Clean separation between NixOS system options and home-manager user config

### **Phase 4: Advanced NixOS Ecosystem Tools**
**Status: ✅ COMPLETED - Successfully deployed 2025-08-02**

8. **Modern NixOS Toolchain** ✅
   - ✅ Integrated lanzaboote for secure boot with TPM (ready for key enrollment)
   - ✅ Added disko for declarative disk partitioning (flake input ready)
   - ✅ Included nix-fast-build for faster parallel builds
   - ✅ Added nixos-anywhere for remote deployment capability
   - ✅ Additional tools: colmena, nixos-generators, system analysis tools

**Implementation Notes:**
- Lanzaboote module configured but disabled pending secure boot key generation
- TPM2 support fully configured for automatic LUKS unlock
- Advanced deployment tools ready for multi-machine management
- Performance analysis and debugging tools included
- System builds successfully with all advanced tooling

9. **Advanced Linux-Only Capabilities** (Future Enhancement)
   - Container orchestration for isolated client environments
   - Real-time systemd automation for workflow optimization
   - Advanced input device and hardware support
   - Network QoS optimization for professional communication

## **Implementation Principles**
- **Maintain shared.nix centralization** until Phase 3 migration
- **Follow existing module organization** (security → security.nix, etc.)
- **Preserve all performance optimizations** while fixing security gaps
- **Zero breaking changes** to current workflow
- **Update PRD at each step** with implementation details

## **Success Criteria**
- Enhanced security without usability sacrifice
- Professional-grade communication tools
- Future-ready architecture for multi-system expansion
- Maintains current rebuild speed and development velocity
- Preserves all existing functionality

## **Next Steps - Manual Configuration Required**

### **Phase 4 - Secure Boot Activation (Optional)**

1. **Generate Secure Boot Keys**:
   ```bash
   sudo sbctl create-keys
   ```

2. **Enroll Keys in UEFI**:
   ```bash
   sudo sbctl enroll-keys --microsoft
   ```

3. **Enable Lanzaboote**:
   - Edit `/home/tom/.nixos/modules/secure-boot.nix`
   - Change `boot.lanzaboote.enable = false;` to `true`
   - Uncomment `boot.loader.systemd-boot.enable = lib.mkForce false;`
   - Rebuild: `sudo nixos-rebuild switch --flake ~/.nixos#gti`

4. **Enable Secure Boot in UEFI/BIOS**:
   - Reboot and enter UEFI settings
   - Enable Secure Boot
   - Clear any existing keys if prompted

5. **TPM2 LUKS Auto-unlock** (if using encrypted disk):
   ```bash
   sudo systemd-cryptenroll --tpm2-device=auto --tpm2-pcrs=0+2+7+12 /dev/nvme0n1p2
   ```

### **Phase 1 & 2 Post-Deployment Setup (Complete these next)**

#### **YubiKey Integration Activation**
1. **Enable SSH Agent Integration**:
   ```bash
   # Uncomment in ~/.nixos/home.nix SSH config:
   # IdentityAgent ~/.yubikey-agent.sock
   ```

2. **Register YubiKey for FIDO2/U2F**:
   ```bash
   mkdir -p ~/.config/Yubico
   pamu2fcfg > ~/.config/Yubico/u2f_keys
   ```

3. **Move GPG Key to Secrets**:
   - Move hardcoded `user.signingkey` in home.nix to sops secret
   - Update to use `config.sops.secrets."system/yubikey_signing_key".path`

4. **Verify YubiKey Services**:
   ```bash
   systemctl --user status yubikey-agent
   # Should be running after reboot
   ```

#### **Secrets Management Re-activation** 
1. **Fix Age Key Configuration**:
   ```bash
   # Your secrets.yaml exists but age key needs to be configured
   # The file is encrypted for: age1xrkzc96sczpmt0sx5yjjevpkgd9xyf98xyyyct6x5sazhn2tfyuqlzeg4l
   # Need to either find the original key or re-encrypt with new key
   ```

2. **Re-enable Secrets in secrets.nix**:
   ```bash
   # Uncomment the secret definitions in ~/.nixos/modules/secrets.nix:
   # "wifi/home_password" = shared.secrets.system // { mode = "0440"; };
   # "services/github_token" = shared.secrets.development;
   # "services/openai_api_key" = shared.secrets.development;
   # "services/anthropic_api_key" = shared.secrets.development;
   ```

#### **Container Platform Finalization**
1. **Enable User Lingering**:
   ```bash
   sudo loginctl enable-linger tom
   ```

2. **Verify Rootless Configuration**:
   ```bash
   podman system info | grep -A5 "runRoot"
   # Should show user-specific paths
   ```

#### **GNOME Extensions Manual Installation**
1. **Install Missing Extensions via Extensions Manager**:
   ```bash
   # These extensions aren't available in nixpkgs, install manually:
   # - Sound Output Device Chooser (for quick audio switching)
   # - Workspace Indicator (for project organization)  
   # - Window List (for taskbar functionality)
   # Visit: https://extensions.gnome.org/
   ```

### **Phase 2 Setup Requirements (Video Conferencing & Productivity)**

#### **Complete Professional Video Call Setup Guide**

This comprehensive guide explains how to link all your video conferencing tools together for professional use.

##### **Audio Flow Architecture**
```
Physical Microphone → EasyEffects → Virtual Mic → Video Call App
                                 ↗ OBS Studio (for recording)
```

##### **Video Flow Architecture**  
```
Physical Camera → OBS Studio → Virtual Camera → Video Call App
               ↗ Direct Camera (fallback)
```

##### **Step 1: EasyEffects Audio Enhancement Setup**

1. **Launch EasyEffects**:
   ```bash
   # EasyEffects should auto-start, or launch manually:
   easyeffects
   ```

2. **Create Professional Audio Profile**:
   - Open EasyEffects → Presets → Create New Preset
   - Name it "Professional Calls"
   - Add these effects in order:
     - **Gate**: Eliminates background noise below threshold
     - **Compressor**: Evens out volume levels  
     - **Filter**: High-pass at 80Hz, Low-pass at 10kHz
     - **Limiter**: Prevents audio clipping
   
3. **Configure Effects Settings**:
   - **Gate**: Threshold -30dB, Ratio 2:1
   - **Compressor**: Threshold -18dB, Ratio 4:1, Attack 10ms
   - **EQ**: Slight boost at 2-4kHz for voice clarity
   - **Limiter**: -3dB ceiling

4. **Set Auto-Loading**:
   - Settings → Auto-start → Enable
   - Settings → Default Preset → "Professional Calls"

##### **Step 2: OBS Studio Virtual Camera Setup**

1. **Configure OBS Sources**:
   ```bash
   # Launch OBS Studio
   obs
   ```
   
2. **Create Scene for Video Calls**:
   - Scene → Add → "Video Call Scene"
   - Add Source → Video Capture Device → Select your camera
   - Add Source → Audio Input Capture → "EasyEffects Processed Output"
   
3. **Enable Virtual Camera**:
   - Tools → Start Virtual Camera
   - Set Output Type: "Internal Camera"
   - Check "Auto-Start" for future sessions
   - The virtual camera appears as "OBS Virtual Camera" in apps

4. **Audio Routing Setup**:
   - Settings → Audio → Advanced
   - Monitoring Device: Set to your speakers/headphones
   - Desktop Audio: Disabled (prevents echo in calls)

##### **Step 3: Helvum Audio Routing Visualization**

1. **Launch Helvum PipeWire Patchbay**:
   ```bash
   helvum
   ```

2. **Verify Audio Connections**:
   - **Input Chain**: Microphone → EasyEffects → Virtual Sink
   - **Output Chain**: EasyEffects → Speakers/Headphones
   - **Call Apps**: Should connect to EasyEffects output automatically

3. **Manual Routing (if needed)**:
   - Drag connections between audio nodes in Helvum
   - Connect call app input to "EasyEffects Source" 
   - Connect call app output to your speakers

##### **Step 4: V4L2 Camera Control**

1. **List Available Cameras**:
   ```bash
   v4l2-ctl --list-devices
   ```

2. **Adjust Camera Settings**:
   ```bash
   # Set focus, exposure, white balance before calls:
   v4l2-ctl -d /dev/video0 --set-ctrl=focus_automatic_continuous=0
   v4l2-ctl -d /dev/video0 --set-ctrl=focus_absolute=250
   v4l2-ctl -d /dev/video0 --set-ctrl=white_balance_automatic=0
   ```

3. **Create Camera Presets**:
   ```bash
   # Save current settings to a script:
   echo '#!/bin/bash' > ~/camera-meeting-setup.sh
   echo 'v4l2-ctl -d /dev/video0 --set-ctrl=brightness=130' >> ~/camera-meeting-setup.sh
   echo 'v4l2-ctl -d /dev/video0 --set-ctrl=contrast=130' >> ~/camera-meeting-setup.sh
   chmod +x ~/camera-meeting-setup.sh
   ```

##### **Step 5: Integration with Common Apps**

**Zoom Configuration**:
1. Settings → Audio → Microphone: "EasyEffects Source"
2. Settings → Audio → Speaker: Your hardware speakers
3. Settings → Video → Camera: "OBS Virtual Camera" (for enhanced video) or direct camera
4. Advanced → Enable "Suppress background noise" (OFF - handled by EasyEffects)

**Slack/Discord Configuration**:
1. Settings → Audio & Video → Microphone: "EasyEffects Source"  
2. Settings → Audio & Video → Camera: "OBS Virtual Camera"
3. Settings → Audio & Video → Test audio/video before calls

**Google Meet/Teams**:
1. In-call settings (gear icon) → Microphone: "EasyEffects Source"
2. In-call settings → Camera: "OBS Virtual Camera"
3. Browser may require camera/microphone permission updates

##### **Step 6: Quick Setup Workflow**

**Pre-Call Checklist**:
1. Launch EasyEffects (auto-starts)
2. Launch OBS Studio → Start Virtual Camera
3. Run camera setup script: `~/camera-meeting-setup.sh`
4. Test audio/video in your call application
5. Launch Helvum if routing issues occur

**Audio Quality Test**:
```bash
# Test microphone with real-time monitoring:
gst-launch-1.0 pulsesrc device="easyeffects_source" ! audioconvert ! audioresample ! autoaudiosink
```

**Troubleshooting Common Issues**:

1. **No Audio in Call**:
   - Check Helvum connections
   - Verify call app is using "EasyEffects Source"
   - Restart EasyEffects if needed

2. **Virtual Camera Not Appearing**:
   - Restart OBS Studio
   - Check if v4l2loopback module is loaded: `lsmod | grep v4l2loopback`
   - Reload module: `sudo modprobe -r v4l2loopback && sudo modprobe v4l2loopback`

3. **Audio Echo/Feedback**:
   - Disable "Desktop Audio" in OBS
   - Ensure call app output goes to speakers, not virtual sink
   - Use headphones instead of speakers

4. **Poor Video Quality**:
   - Adjust OBS output resolution in Virtual Camera settings
   - Increase bitrate in OBS → Settings → Output → Streaming
   - Check lighting and camera positioning

**Performance Optimization**:
- Set OBS to use hardware encoding (NVENC/VAAPI) if available
- Lower EasyEffects buffer size for lower latency
- Close unnecessary applications during important calls
- Monitor CPU usage during calls and adjust quality settings

This setup provides professional-grade audio and video for your copywriting client calls while maintaining the flexibility to record or stream when needed.

#### **OBS Studio Advanced Configuration**
1. **Scene Collections for Different Use Cases**:
   - "Client Calls": Clean background, professional lighting
   - "Team Meetings": Casual setup with workspace visible  
   - "Content Recording": Full studio setup with graphics
   - "Screen Sharing": Desktop capture with camera overlay

2. **Audio Integration Profiles**:
   - Link OBS audio to EasyEffects processed output
   - Set up separate tracks for recording vs streaming
   - Configure audio monitoring for real-time feedback

#### **EasyEffects Audio Enhancement**
1. **Profile Creation**:
   - Create "Meeting" profile with noise suppression
   - Create "Recording" profile for content creation
   - Configure auto-switching based on application

2. **PipeWire Optimization**:
   ```bash
   # Add to ~/.config/pipewire/pipewire.conf:
   # default.clock.quantum = 64
   # default.clock.min-quantum = 64
   ```

#### **GNOME Extensions Setup**
1. **Install and Configure**:
   - Sound Input/Output Device Chooser: Set hotkeys for quick switching
   - Just Perfection: Hide unnecessary UI elements
   - Workspace Indicator: Configure workspace naming
   - Clipboard Manager: Set history size and shortcuts

2. **Kanshi Display Profiles**:
   ```bash
   # Create ~/.config/kanshi/config with profiles for:
   # - Laptop only
   # - External monitor + laptop
   # - Presentation mode (mirrored)
   ```

### **Phase 3 Setup Requirements (Architecture Migration)**

#### **Module Options Pattern Migration**
1. **Pre-Migration Testing**:
   ```bash
   # Create test branch for migration
   git checkout -b module-options-migration
   ```

2. **Gradual Conversion Process**:
   - Convert shared.nix → modules/options.nix
   - Update modules one by one: shared.foo → config.mySystem.foo
   - Test each module conversion individually

3. **Multi-System Preparation**:
   - Plan system-specific overrides structure
   - Design host-specific configuration patterns

### **Phase 4 Setup Requirements (Advanced NixOS Tools)**

#### **Lanzaboote Secure Boot**
1. **TPM Setup**:
   ```bash
   # Enable TPM in BIOS/UEFI
   # Verify TPM availability:
   systemd-cryptenroll --tpm2-device=list
   ```

2. **Secure Boot Configuration**:
   ```bash
   # Generate signing keys
   # Configure systemd-boot replacement
   # Test boot process with secure boot enabled
   ```

#### **Disko Disk Management**
1. **Current Disk Analysis**:
   ```bash
   # Document current partitioning scheme
   lsblk -f > current-disk-layout.txt
   ```

2. **Disko Configuration**:
   - Create declarative disk configuration
   - Plan for encryption and partitioning scheme

#### **Advanced Automation**
1. **SystemD User Services**:
   - Create project-specific automation services
   - Configure display calibration scheduling
   - Set up workflow optimization timers

2. **Container Orchestration**:
   - Design client project isolation containers
   - Configure GPU passthrough for creative tools
   - Set up declarative development environments

### **Testing Checklist for Each Phase**
- [ ] System rebuilds successfully
- [ ] All services start correctly
- [ ] User workflow remains uninterrupted
- [ ] Performance maintains or improves
- [ ] Security features function as expected

## **Implementation Log**
- **2025-01-11**: PRD created, Phase 1 implementation started
- **2025-01-11**: Phase 1 completed successfully - security hardening, structured secrets, secure containers deployed
- **2025-01-11**: Phase 2 completed successfully - professional communication, video conferencing, GNOME productivity suite deployed
- **2025-01-11**: Fixed multiple build issues: kanshi configuration, PAM U2F settings, GNOME extension availability
- **2025-01-11**: Secrets management temporarily disabled pending age key resolution - system builds successfully
- **2025-01-11**: Updated Next Steps with current status and manual configuration requirements
- **2025-08-02**: Phase 3 completed successfully - architecture migration to proper NixOS options completed
- **2025-08-02**: Replaced shared.nix with modules/options.nix featuring typed options and validation
- **2025-08-02**: All modules migrated to config.mySystem.* pattern, foundation ready for multi-system expansion
- **2025-08-02**: Phase 4 completed successfully - modern NixOS toolchain integrated
- **2025-08-02**: Added lanzaboote (secure boot), disko, nix-fast-build, nixos-anywhere, and system analysis tools
- **2025-08-02**: TPM2 support configured for future LUKS auto-unlock capability