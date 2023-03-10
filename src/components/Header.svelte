<script>
  import SearchBar from "./SearchBar.svelte";
</script>

<div class="flex max-w-6xl mx-auto h-[80px] items-center justify-between">
  <a
    class="block bg-[url('/assets/images/logo.png')] w-[212px] h-[52px]"
    href="/"
  />
  <SearchBar
    on:search={({ detail }) => {
      location.href = "/#" + detail;
    }}
  />
  <a
    class="self-start text-[15px] pt-1 hover:font-semibold"
    href="/aboutus/">About us</a
  >
</div>
