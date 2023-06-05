<script lang="ts">
  import { onMount } from "svelte";
  import SearchBar from "../SearchBar.svelte";
  import Filter from "./Filter.svelte";

  import ListItem from "./ListItem.svelte";

  export let metadata: {
    id: number;
    title: string;
    description?: string;
    videoUrl?: string;
  }[];

  let filteredTutorials = metadata;

  let queryText = "";

  onMount(() => (queryText = location.hash?.slice(1) ?? ""));

  $: filteredAndMatchingTutorials = queryText
    ? filteredTutorials.filter((tutorial) => {
        const queryLower = queryText.toLowerCase();
        return (
          tutorial.title.toLowerCase().includes(queryLower) ||
          tutorial.description?.toLowerCase().includes(queryLower)
        );
      })
    : filteredTutorials;
</script>

<svelte:window
  on:hashchange={() => (queryText = location.hash?.slice(1) ?? "")}
/>

<div class="flex max-w-6xl mx-auto h-[80px] items-center justify-between">
  <a
    class="block bg-[url('/TizenSchool/assets/images/logo.png')] w-[212px] h-[52px]"
    href="/"
  />
  <SearchBar
    on:search={({ detail }) => {
      history.pushState(null, "", "#" + detail);
      queryText = detail;
    }}
  />
  <a class="self-start text-[15px] pt-1 hover:font-semibold" href="/aboutus/"
    >About us</a
  >
</div>
<div class="max-w-6xl mx-auto">
  <Filter tutorials={metadata} bind:filteredTutorials />
  <ul class="border-t border-default min-h-[700px]">
    {#each filteredAndMatchingTutorials as tutorial}
      <ListItem {tutorial} />
    {:else}
      <div
        class="h-96 flex flex-col gap-1 items-center justify-center text-2xl font-bold text-tutorial"
      >
        No items found.
        <a href="/" class="text-primary hover:text-[#25a39f] underline"
          >See available tutorials</a
        >
      </div>
    {/each}
  </ul>
</div>
