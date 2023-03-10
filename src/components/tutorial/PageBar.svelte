<script lang="ts">
  import PageButton from "./PageButton.svelte";

  export let page: number;
  export let pageCount: number;

  const maxPage = pageCount - 1;
</script>

<PageButton disabled={page === 0} on:click={() => (page -= +!!page)} />
<span class="font-extrabold w-28 text-center text-xl text-tutorial">
  {page + 1}/{pageCount}
</span>
<PageButton
  disabled={page === maxPage}
  on:click={() => (page += +!(page == maxPage))}
/>
