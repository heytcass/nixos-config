# ISO-specific package optimizations
# Reduces package sizes without removing functionality
# Based on wimpysworld's selective optimization approach

_final: prev: {
  # Optimize multimedia packages (wimpysworld's proven technique)
  espeak = prev.espeak.override {
    # Disable mbrola support to save ~650MB
    mbrolaSupport = false;
  };

  # Optimize development tools for ISO
  git = prev.git.override {
    # Disable GUI tools and docs for minimal ISO
    withManual = false;
    pythonSupport = false;
  };

  # Optimize GStreamer plugins (conservative approach)
  gst_all_1 = prev.gst_all_1 // {
    gst-plugins-bad = prev.gst_all_1.gst-plugins-bad.override {
      # Disable heavy optional features for ISO
      enableZbar = false;
    };
  };
}
