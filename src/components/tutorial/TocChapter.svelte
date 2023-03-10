<script lang="ts">
  export let currentPageIdx: number;
  export let page: { title: string; index: number }[];
  export let chapter: string;
  export let isOpen: boolean;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
  class="flex justify-between mr-4 text-toc font-bold text-2xl my-3 cursor-pointer"
  on:click
>
  {chapter}
  <span
    class:rotate-180={isOpen}
    class="h-8 w-8 bg-toc-arrow bg-no-repeat bg-center"
  />
</div>
{#if isOpen}
  {#each page as { title, index }}
    {@const highlihted = index === currentPageIdx}
    <!-- svelte-ignore a11y-click-events-have-key-events -->
    <div
      class="flex pr-12 text-lg text-default cursor-pointer before:content-[''] before:w-6 before:bg-center before:bg-no-repeat before:-rotate-90"
      class:font-bold={highlihted}
      class:before:bg-toc-arrow={highlihted}
      on:click={() => (currentPageIdx = index)}
    >
      {title}
    </div>
  {/each}
{/if}
