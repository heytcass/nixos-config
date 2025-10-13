{ pkgs, ... }:

{
  # System-wide font configuration
  fonts = {
    # Enable font configuration
    fontconfig = {
      enable = true;
      # Use improved font rendering
      antialias = true;
      hinting = {
        enable = true;
        style = "slight";
      };
      subpixel = {
        rgba = "rgb";
        lcdfilter = "default";
      };
      # Default fonts for common families
      defaultFonts = {
        serif = [ "Noto Serif" "Liberation Serif" "DejaVu Serif" ];
        sansSerif = [ "Noto Sans" "Liberation Sans" "DejaVu Sans" ];
        monospace = [ "Noto Sans Mono" "Liberation Mono" "DejaVu Sans Mono" ];
        emoji = [ "Noto Color Emoji" ];
      };

      # Local configuration for better web font fallbacks
      localConf = ''
        <?xml version="1.0"?>
        <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
        <fontconfig>
          <!-- Disable slashed zero in Noto Sans -->
          <match target="font">
            <test name="family" compare="eq">
              <string>Noto Sans</string>
            </test>
            <edit name="fontfeatures" mode="append">
              <string>zero off</string>
            </edit>
          </match>

          <!-- Force common web fonts to use Noto Sans -->
          <match target="pattern">
            <test name="family" compare="eq">
              <string>AvertaStd</string>
            </test>
            <edit name="family" mode="prepend" binding="strong">
              <string>Noto Sans</string>
            </edit>
          </match>

          <!-- Generic substitutions for common missing fonts -->
          <alias>
            <family>Helvetica</family>
            <prefer><family>Noto Sans</family></prefer>
          </alias>
          <alias>
            <family>Arial</family>
            <prefer><family>Noto Sans</family></prefer>
          </alias>

          <!-- Ensure sans-serif always prefers Noto Sans first -->
          <alias>
            <family>sans-serif</family>
            <prefer>
              <family>Noto Sans</family>
              <family>Liberation Sans</family>
              <family>DejaVu Sans</family>
            </prefer>
          </alias>

          <!-- Prevent DejaVu Sans from being used before Noto -->
          <selectfont>
            <rejectfont>
              <pattern>
                <patelt name="family">
                  <string>DejaVu Sans Mono</string>
                </patelt>
              </pattern>
            </rejectfont>
          </selectfont>
        </fontconfig>
      '';
    };

    # Enable a basic set of fonts providing good coverage
    enableDefaultPackages = true;

    # Install additional fonts
    packages = with pkgs; [
      # Core fonts - Noto family (comprehensive, modern)
      noto-fonts          # Google's font family with great Unicode support
      noto-fonts-cjk-sans # Chinese, Japanese, Korean
      noto-fonts-emoji    # Emoji support

      # Fallback fonts
      liberation_ttf      # Microsoft font alternatives (Arial, Times New Roman, Courier)

      # Professional fonts
      source-sans         # Adobe's open source sans-serif
      source-serif        # Adobe's open source serif

      # Microsoft core fonts (for web compatibility)
      corefonts          # Arial, Times New Roman, etc.
    ];
  };
}
