<script lang="ts">
  export let tutorial: any;

  const levels = ["Beginner", "Intermediate", "Advanced"];
</script>

<!-- svelte-ignore a11y-click-events-have-key-events -->
<div
  class="group flex py-4 gap-4 text-default border-b border-default cursor-pointer"
  on:click={() => (location.href = `tutorials/${tutorial.id}`)}
>
  <div class="details grow flex flex-col">
    <div class="type font-semibold mb-2">
      Tutorial | <span class="capitalize">{tutorial.type}</span>
    </div>
    <div class="group-hover:text-amber-400 title mt-2 mb-4 font-extrabold">
      {tutorial.title}
    </div>
    <div class="description grow">{tutorial.description ?? ""}</div>
    <div class="footer flex">
      <div class="profile grow flex gap-2">
        {#if tutorial.profile.includes("mobile")}
          <div class="w-icon-profile h-icon-profile bg-icon-profile-mobile" />
        {/if}
        {#if tutorial.profile.includes("wearable")}
          <div class="w-icon-profile h-icon-profile bg-icon-profile-wearable" />
        {/if}
        {#if tutorial.profile.includes("tv")}
          <div class="w-[42px] h-icon-profile bg-icon-profile-tv" />
        {/if}
        {#if tutorial.profile.includes("iot")}
          <div class="w-icon-profile h-icon-profile bg-icon-profile-iot" />
        {/if}
      </div>
      <div class="level flex gap-2 items-end">
        {levels[tutorial.level - 1]}
        <div class="indicator self-end level-{tutorial.level}" />
      </div>
    </div>
  </div>
  <div class="thumbnail overflow-hidden rounded-lg shrink-0">
    <img
      class="w-full h-full object-cover transition-[transform] hover:scale-[1.15] duration-[400ms]"
      alt=""
      src={tutorial.thumbnail}
    />
  </div>
</div>

<style lang="scss">
  .type,
  .description {
    font-size: 1rem;
    line-height: 20px;
  }

  .title {
    font-size: 20px;
    line-height: 24px;
  }

  .level {
    font-size: 1rem;
    line-height: 1rem;

    .indicator {
      width: 20px;
      height: 20px;
      background: url("/TizenSchool/assets/images/icon_level.svg") -3px -2px
        no-repeat transparent;
      background-size: 42px 24px;

      &.level-2 {
        background-position-x: -10px;
      }

      &.level-1 {
        background-position-x: -18px;
      }
    }
  }

  .thumbnail {
    width: 285px;
    height: 162px;
  }
</style>
