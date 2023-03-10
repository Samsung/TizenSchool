<script lang="ts">
  import { createEventDispatcher } from "svelte";

  export let id: string;
  export let label: string;
  export let value: string;
  export let amount: number;
  export let checked: boolean;

  const dispatch = createEventDispatcher();

  let input: HTMLInputElement;

  $: if (!amount) {
    uncheck();
  }

  function uncheck() {
    if (!input) {
      return;
    }

    input.checked = false;

    dispatch("change", {
      state: input.checked,
      value: value,
    });
  }

  function onChange(event: any) {
    dispatch("change", {
      state: event.target.checked,
      value: value,
    });
  }
</script>

<div class="flex gap-2 py-2 items-center">
  <input
    type="checkbox"
    bind:this={input}
    {id}
    {value}
    on:change={onChange}
    disabled={!amount}
    {checked}
    class="appearance-none grid place-content-center bg-white border-2
    border-solid border-[#4cccc8] disabled:border-gray-400 w-[0.875rem] h-[0.875rem]
    before:content-[' '] before:w-[0.5rem] before:h-[0.5rem] before:scale-0
    before:shadow-[inset_1rem_1rem_rgba(255,255,255)] cursor-pointer
    checked:bg-[#4cccc8] checked:border-0 checked:before:scale-100
    checked:before:clip-path-polygon-[14%_44%,_0_65%,_50%_100%,_100%_16%,_80%_0,_43%_62%]"
  /><label
    for={id}
    class="leading-4 cursor-pointer"
    class:cursor-default={!amount}
    class:text-gray-400={!amount}>{label} ({amount})</label
  >
</div>
