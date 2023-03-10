<script lang="ts">
  export let disabled: boolean;
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
  on:click
  class={`
    h-[30px] w-[30px] rounded-full bg-arrow 
    bg-[position:12px_7px] 
    bg-[size:8px] 
    bg-no-repeat
    rotate-180
    last:rotate-0
    ${
      disabled
        ? "border border-[#dfdfdf] bg-arrow-page-grey"
        : "bg-primary bg-arrow hover:bg-[#2aa29e] cursor-pointer"
    }
  `}
/>
