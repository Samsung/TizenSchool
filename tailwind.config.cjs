/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{astro,html,js,jsx,md,mdx,svelte,ts,tsx,vue}"],
  safelist: [
    "absolute",
    "inset-x-0",
    "bg-slate-700",
    " mb-5",
    "mt-2",
    "h-12",
    "h-96",
  ],
  theme: {
    extend: {
      fontFamily: {
        sans: ["BreezeSans", "sans-serif"],
      },
      width: {
        "icon-profile": "17px",
      },
      height: {
        "icon-profile": "30px",
      },
      backgroundImage: {
        "icon-profile-mobile":
          "url('/TizenSchool/assets/images/icon_mobile.png')",
        "icon-profile-wearable":
          "url('/TizenSchool/assets/images/icon_wearable.png')",
        "icon-profile-iot": "url('/TizenSchool/assets/images/icon_iot.png')",
        "icon-profile-tv": "url('/TizenSchool/assets/images/icon_tv.png')",
        "toc-arrow": "url(/assets/images/toc-arrow-down.png)",
        "arrow-grey": "url(/assets/images/caret-icon-grey.svg)",
        search: "url(/assets/images/search-icon.svg)",
        "search-hover": "url(/assets/images/search-icon-hover.svg)",
        arrow: "url(/assets/images/arrow_pagination_white.svg)",
        "arrow-page-grey": "url(/assets/images/arrow_pagination_grey.svg)",
      },
      borderColor: {
        default: "#dcdcdc",
      },
      colors: {
        default: "#5f6368",
        tutorial: "#848484",
        primary: "#4cccc8",
        toc: "#4ca2a0",
      },
    },
  },
  plugins: [require("tailwind-clip-path")],
};
