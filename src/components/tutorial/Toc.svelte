<script lang="ts">
  import TocChapter from "./TocChapter.svelte";

  export let currentPageIdx: number;

  export let toc: {
    page: { title: string }[];
    chapter: string;
  }[];

  let index = 0;
  let indexedToc = toc.map(({ page, chapter }) => ({
    page: page.map(({ title }) => ({ title, index: index++ })),
    chapter,
  }));

  let isOpen = false;
  let openTocChapterIdx: number | null = 0;

  $: openTocChapterIdx = indexedToc.findIndex((chapter) =>
    chapter.page.some((page) => page.index == currentPageIdx)
  );

  const evtMarker = Symbol();

  type Event = MouseEvent & { [evtMarker]?: boolean };

  function onClickOutside(evt: Event) {
    if (!evt[evtMarker]) {
      isOpen = false;
    }
  }

  function markEvent(evt: Event) {
    evt[evtMarker] = true;
  }

  function markEventAndToggle(evt: Event) {
    evt[evtMarker] = true;
    isOpen = !isOpen;
  }
</script>

<button
  on:click={markEventAndToggle}
  class="
    w-[184px] h-[34px absolute left-0 rounded-sm
    font-extrabold text-[17px] leading-[34px]
    after:content-['']  after:h-[10px] after:w-[10px]
    after:inline-block after:bg-no-repeat after:bg-center after:ml-3
    {isOpen
    ? 'border border-[#5e6367] bg-white text-[#5e6367] after:bg-arrow-grey after:rotate-180 hover:border-primary'
    : 'bg-primary text-white after:rotate-90 S after:bg-arrow hover:bg-[#2aa29e]'}
  "
>
  Table of Content
</button>

<svelte:window on:click={onClickOutside} />

{#if isOpen}
  <!-- svelte-ignore a11y-click-events-have-key-events -->
  <div
    class="absolute left-0 top-full bg-stone-100 w-[442px] mt-2 py-4 text-left pl-[34px] z-20"
    on:click={markEvent}
  >
    {#each indexedToc as { chapter, page }, i}
      {@const isOpen = i === openTocChapterIdx}
      <TocChapter
        {chapter}
        {page}
        bind:currentPageIdx
        {isOpen}
        on:click={() => (openTocChapterIdx = isOpen ? null : i)}
      />
    {/each}
  </div>
{/if}
