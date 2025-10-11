export default {
  mounted() {
    setTimeout(() => {
      this.el.style.transition = "opacity 0.5s";
      this.el.style.opacity = "0";
      setTimeout(() => this.el.remove(), 500);
    }, 5000); // Wait 5 seconds before starting to fade out
  },
};