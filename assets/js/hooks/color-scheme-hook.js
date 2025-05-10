/**
 * Enhanced Color Scheme Hook
 * Handles theme switching and applies template colors to CSS variables
 */
const ColorSchemeHook = {
  mounted() {
    this.init();

    // Listen for theme-change events from LiveView
    window.addEventListener("phx:theme-change", (e) => {
      const { theme, primary_color, accent_color, background_color } = e.detail;

      localStorage.setItem("theme", theme);
      localStorage.setItem("primary_color", primary_color);
      localStorage.setItem("accent_color", accent_color);

      // Apply dark or light mode
      window.applyScheme(theme);

      // Apply primary and accent colors to CSS variables
      if (primary_color) {
        document.documentElement.style.setProperty(
          "--color-primary",
          primary_color
        );

        // Generate color shades automatically
        this.generateColorShades(primary_color, "primary");
      }

      if (accent_color) {
        document.documentElement.style.setProperty(
          "--color-accent",
          accent_color
        );

        // Generate color shades automatically
        this.generateColorShades(accent_color, "accent");
      }

      if (background_color) {
        document.documentElement.style.setProperty(
          "--color-background",
          background_color
        );
      }
    });
  },

  updated() {
    this.init();

    this.loadSavedTheme();

    const primaryColor = localStorage.getItem("primary_color");
    const accentColor = localStorage.getItem("accent_color");
    const theme = localStorage.getItem("theme");

    if (primaryColor && accentColor) {
      this.pushEvent("sync_theme", {
        primary_color: primaryColor,
        accent_color: accentColor,
        theme: theme,
      });
    }
  },

  init() {
    initScheme();
    this.el.addEventListener("click", window.toggleScheme);
  },

  loadSavedTheme() {
    const theme = localStorage.getItem("theme");
    const primaryColor = localStorage.getItem("primary_color");
    const accentColor = localStorage.getItem("accent_color");

    // If there's a saved theme, apply it
    if (theme) {
      window.applyScheme(theme);
    }

    // If there's a saved primary color, apply it
    if (primaryColor) {
      document.documentElement.style.setProperty(
        "--color-primary",
        primaryColor
      );
      this.generateColorShades(primaryColor, "primary");
    }

    if (accentColor) {
      document.documentElement.style.setProperty("--color-accent", accentColor);
      this.generateColorShades(accentColor, "accent");
    }
  },

  /**
   * Generates different shades of a color and sets CSS variables
   * @param {string} baseColor - Hex color code (e.g. #FF5500)
   * @param {string} name - Base name for the CSS variable (e.g. "primary")
   */
  generateColorShades(baseColor, name) {
    if (!baseColor || !baseColor.startsWith("#")) return;

    // Convert hex to RGB
    const r = parseInt(baseColor.slice(1, 3), 16);
    const g = parseInt(baseColor.slice(3, 5), 16);
    const b = parseInt(baseColor.slice(5, 7), 16);

    // Generate shades: 50, 100, 200, ..., 900, 950
    const shades = {
      50: this.lighten(r, g, b, 0.85),
      100: this.lighten(r, g, b, 0.75),
      200: this.lighten(r, g, b, 0.55),
      300: this.lighten(r, g, b, 0.35),
      400: this.lighten(r, g, b, 0.15),
      500: baseColor,
      600: this.darken(r, g, b, 0.15),
      700: this.darken(r, g, b, 0.35),
      800: this.darken(r, g, b, 0.55),
      900: this.darken(r, g, b, 0.75),
      950: this.darken(r, g, b, 0.85),
    };

    // Define CSS variables
    Object.entries(shades).forEach(([shade, color]) => {
      // Define the theme variable
      document.documentElement.style.setProperty(
        `--theme-${name}-${shade}`,
        color
      );

      // Define the color variable
      document.documentElement.style.setProperty(
        `--color-${name}-${shade}`,
        color
      );
    });
  },

  /**
   * Lightens a color by the given amount
   */
  lighten(r, g, b, amount) {
    const light = (c) => Math.round(c + (255 - c) * amount);
    return `#${this.toHex(light(r))}${this.toHex(light(g))}${this.toHex(
      light(b)
    )}`;
  },

  /**
   * Darkens a color by the given amount
   */
  darken(r, g, b, amount) {
    const dark = (c) => Math.round(c * (1 - amount));
    return `#${this.toHex(dark(r))}${this.toHex(dark(g))}${this.toHex(
      dark(b)
    )}`;
  },

  /**
   * Converts a number to a 2-digit hex string
   */
  toHex(value) {
    const hex = Math.max(0, Math.min(255, value)).toString(16);
    return hex.length === 1 ? "0" + hex : hex;
  },
};

export default ColorSchemeHook;
