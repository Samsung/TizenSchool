<script lang="ts">
  import { tick } from "svelte";
  import PageBar from "./PageBar.svelte";
  import Toc from "./Toc.svelte";

  export let pageCount: number;
  export let toc: {
    page: { title: string }[];
    chapter: string;
  }[];

  let page = 0;
  let pageBar: HTMLDivElement;

  function scrollToTop(_page: number) {
    if (pageBar) {
      tick().then(() => pageBar?.scrollIntoView({ behavior: "smooth" }));
    }
  }

  $: scrollToTop(page);

  function visibleTutorial(node: HTMLDivElement, page: number) {
    let tutorialContainer = node.children[0].children[0];

    /// @ts-ignore (styles is assignable, even tho ts says it's not)
    tutorialContainer.children[page].style = "";

    return {
      update(newPage: number) {
        /// @ts-ignore (same here)
        tutorialContainer.children[page].style = "display: none;";
        page = newPage;
        /// @ts-ignore (same here)
        tutorialContainer.children[page].style = "";
      },
    };
  }

  function onPontentialCopyClick({ target }: Event) {
    if (target instanceof HTMLDivElement && target.className === "copy-btn") {
      navigator.clipboard.writeText(
        target.parentNode!.parentNode!.children[1]!.textContent ?? ""
      );

      target.className = "copy-btn copy-btn-done";
      setTimeout(() => (target.className = "copy-btn"), 2000);
    }
  }
</script>

<svelte:window on:click={onPontentialCopyClick} />

<div
  class="flex justify-center h-12 shadow-[0_2px_10px_#cfcfcf] bg-stone-100 my-[40px]"
>
  <div
    bind:this={pageBar}
    class="flex flex-grow justify-center relative items-center max-w-6xl"
  >
    <Toc bind:currentPageIdx={page} {toc} />
    <PageBar bind:page {pageCount} />
  </div>
</div>
<div
  use:visibleTutorial={page}
  class="max-w-6xl min-h-[400px] mx-auto text-tutorial"
>
  <slot />
</div>
<div class="flex justify-center items-center h-12">
  <PageBar bind:page {pageCount} />
</div>
