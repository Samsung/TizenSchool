import { defineConfig } from "astro/config";

// https://astro.build/config
import tailwind from "@astrojs/tailwind";

// https://astro.build/config
import svelte from "@astrojs/svelte";

// https://astro.build/config
export default defineConfig({
  integrations: [tailwind(), svelte()],
  site: "https://tizenschool.org/",
  base: "/",
  markdown: {
    shikiConfig: {
      theme: {
        colors: { "editor.background": "#f5f2f0" },
        settings: [
          {
            scope: [
              "variable",
              "meta.object-literal.key",
              "source.c",
              "entity.name.type",
              "entity.name.variable",
            ],
            settings: { foreground: "#000" },
          },
          {
            scope: "comment",
            settings: { foreground: "#708090" },
          },
          {
            scope: [
              "keyword",
              "storage.type",
              "storage.modifier",
              "string.quoted.double.xml",
              "constant.language.null.js",
            ],
            settings: { foreground: "#07a" },
          },
          {
            scope: ["string", "entity.other.attribute-name", "constant"],
            settings: { foreground: "#690" },
          },
          {
            scope: "string.regexp",
            settings: { foreground: "#e90" },
          },
          {
            scope: "entity.name.function",
            settings: { foreground: "#dd4a68" },
          },
          {
            scope: "keyword.operator",
            settings: { foreground: "#a67f59" },
          },
          {
            scope: "punctuation",
            settings: { foreground: "#999" },
          },
          {
            scope: "meta.brace.round",
            settings: { foreground: "#999" },
          },
          {
            scope: ["entity.name.tag", "constant.numeric", "constant.language"],
            settings: { foreground: "#905" },
          },
          {
            scope: "entity.other.attribute-name.namespace",
            settings: { foreground: "#669900b3" },
          },
        ],
      },
    },
  },
});
