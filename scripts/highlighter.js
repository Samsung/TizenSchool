import { parse, serialize, serializeOuter } from "parse5";

export function applyHighlights(content) {
  let parsed = parse(content).childNodes[0].childNodes[1];
  let header;
  let chapters = [];
  let chapter;
  let highlight;

  for (let node of parsed.childNodes) {
    if (node.tagName === "p" && node?.childNodes[0].tagName === "highlight") {
      highlight = node.childNodes[0].childNodes[0].value
        .split(",")
        .map((highlight) => {
          let [start, end] = highlight.split("-");
          --start;
          return {
            start,
            length: end ? end - start : 1,
          };
        });
    } else if (node.tagName === "h1") {
      header = node;
    } else if (node.tagName === "h2") {
      chapter = parse(`<div class="chapter" style="display: none;"><div/>`)
        .childNodes[0].childNodes[1].childNodes[0];
      chapters.push(chapter);
      chapter.childNodes.push(header, node);
    } else {
      if (node.tagName === "pre") {
        Object.assign(
          node,
          parse(
            `<div class="mt-2 mb-5">
              <div class="h-12 code-block-bar">
                <div class="copy-btn" ></div>
              </div>
              <div class="relative">
                ${
                  highlight
                    ?.map(({ start, length }) => {
                      let top = 28 * start;
                      let height = 28 * length;
                      return `
                        <div
                          style="height: ${height}px; top: ${top}px"
                          class="absolute inset-x-0 code-highlight"
                        ></div>`;
                    })
                    .join("") ?? ""
                }
                ${serializeOuter(node)}
              <div/>
            </div>`
          ).childNodes[0].childNodes[1]
        );

        highlight = null;
      }
      chapter?.childNodes.push(node);
    }
  }
  parsed.childNodes = chapters;

  return serialize(parsed);
}
