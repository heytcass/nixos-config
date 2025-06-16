# ISO-specific package optimizations
# Reduces package sizes without removing functionality
# Based on wimpysworld's selective optimization approach

final: prev: {
  # Optimize GNOME components for ISO builds
  gnome = prev.gnome.overrideScope' (gfinal: gprev: {
    # Remove heavy optional components that aren't essential for live environment
    gnome-photos = null;
    gnome-music = null;
    gnome-games = null;
    
    # Keep essential GNOME components but optimize them
    nautilus = gprev.nautilus.override {
      # Disable tracker indexing for live environment
      withTracker = false;
    };
    
    # Optimize GNOME Shell extensions
    gnome-shell-extensions = gprev.gnome-shell-extensions.override {
      # Keep only essential extensions for live environment
    };
  });
  
  # Optimize multimedia packages (similar to wimpysworld's espeak optimization)
  espeak = prev.espeak.override {
    # Disable mbrola support to save ~650MB (wimpysworld technique)
    mbrolaSupport = false;
  };
  
  # Optimize Firefox for ISO (if included via GNOME)
  firefox = prev.firefox.override {
    # Reduce language packs for ISO
    extraPolicies = {
      DisableFirefoxStudies = true;
      DisableTelemetry = true;
      DisablePocket = true;
    };
  };
  
  # Optimize LibreOffice (if included via GNOME)
  libreoffice = prev.libreoffice.override {
    # Reduce language packs
    langs = [ "en-US" ];
  };
  
  # Optimize GStreamer plugins
  gst_all_1 = prev.gst_all_1 // {
    gst-plugins-bad = prev.gst_all_1.gst-plugins-bad.override {
      # Disable heavy optional features for ISO
      enableZbar = false;
      enableOpus = false;
    };
  };
  
  # Optimize font packages
  noto-fonts = prev.noto-fonts.override {
    # Reduce font variants for ISO
    variants = [ "NotoSans" "NotoSerif" "NotoMono" ];
  };
  
  # Optimize development tools for ISO
  git = prev.git.override {
    # Disable GUI tools for minimal ISO
    withManual = false;
    pythonSupport = false;
  };
  
  # Optimize archive tools
  p7zip = prev.p7zip.override {
    # Keep essential functionality only
    enableUnfree = false;
  };
}