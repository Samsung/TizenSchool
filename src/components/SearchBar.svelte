<script lang="ts">
  import { createEventDispatcher, onMount } from "svelte";

  const dispatch = createEventDispatcher<{ search: string }>();

  let text = "";

  onMount(() => (text = location.hash?.slice(1) ?? ""));

  function onKeyDown(evt: KeyboardEvent) {
    if (evt.key === "Enter") {
      dispatch("search", text);
    }
  }
</script>

<svelte:window on:hashchange={() => (text = location.hash?.slice(1) ?? "")} />

<div class="flex w-[380px]">
  <input
    class="border-b text-lg border-[#436c9b] outline-none grow"
    bind:value={text}
    on:keydown={onKeyDown}
  />
  <div
    class="w-4 ml-3 bg-search bg-no-repeat bg-center hover:bg-search-hover cursor-pointer"
    on:click={() => dispatch("search", text)}
  />
</div>
