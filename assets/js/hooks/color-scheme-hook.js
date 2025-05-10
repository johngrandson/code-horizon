// Requires window.initScheme() and window.toggleScheme() functions defined (see `_head.html.heex`)
const ColorSchemeHook = {
  mounted() {
    this.init();

    window.addEventListener("phx:theme-change", (e) => {
      const { theme, primary_color, accent_color } = e.detail;
      window.applyScheme(theme);

      // TODO: Update root color variables
      // if (primary_color) {
      //   document.documentElement.style.setProperty(
      //     "--color-primary",
      //     primary_color
      //   );
      // }
      // if (accent_color) {
      //   document.documentElement.style.setProperty(
      //     "--color-accent",
      //     accent_color
      //   );
      // }
    });
  },
  updated() {
    this.init();
  },
  init() {
    initScheme();
    this.el.addEventListener("click", window.toggleScheme);
  },
};

export default ColorSchemeHook;
