<script lang="ts">
  import FilterItem from "./FilterItem.svelte";

  export let tutorials: any;
  export let filteredTutorials: any;

  let filters = {
    language: {
      en: 0,
      korean: 0,
    },
    profile: {
      wearable: 0,
      tv: 0,
      iot: 0,
      mobile: 0,
    },
    level: [0, 0, 0],
    type: {
      video: 0,
      text: 0,
    },
    technology: {},
  };

  let expanded = false;

  let wearableAmount = 0;
  let tvAmount = 0;
  let iotAmount = 0;
  let mobileAmount = 0;
  let beginnerAmount = 0;
  let intermediateAmount = 0;
  let advancedAmount = 0;
  let videoAmount = 0;
  let textAmount = 0;
  let englishAmount = 0;
  let koreanAmount = 0;
  let dotnetAmount = 0;
  let webAmount = 0;
  let nativeAmount = 0;
  let generalAmount = 0;

  const profilesSelected = new Set();
  const levelsSelected = new Set();
  const typesSelected = new Set();
  const languagesSelected = new Set();
  const technologiesSelected = new Set();

  function isLevelSelected(level: number) {
    return levelsSelected.size ? levelsSelected.has(level.toString()) : true;
  }

  function isTypeSelected(type: string) {
    return typesSelected.size ? typesSelected.has(type) : true;
  }

  function isLanguageSelected(language: string) {
    return languagesSelected.size ? languagesSelected.has(language) : true;
  }

  function isTechnologySelected(technology: string) {
    return technologiesSelected.size
      ? technologiesSelected.has(technology)
      : true;
  }

  function isProfileSelected(profiles: string[]) {
    if (!profilesSelected.size) {
      return true;
    }

    for (const profile of profiles) {
      if (profilesSelected.has(profile)) {
        return true;
      }
    }

    return false;
  }

  function filterTutorials() {
    filteredTutorials = tutorials.filter((tutorial: any) => {
      return (
        isLevelSelected(tutorial.level) &&
        isTypeSelected(tutorial.tool) &&
        isLanguageSelected(tutorial.language) &&
        isTechnologySelected(tutorial.type) &&
        isProfileSelected(tutorial.profile)
      );
    });

    wearableAmount = countTutorialsPerItem("wearable");
    tvAmount = countTutorialsPerItem("tv");
    iotAmount = countTutorialsPerItem("iot");
    mobileAmount = countTutorialsPerItem("mobile");

    beginnerAmount = countTutorialsPerItem("beginner");
    intermediateAmount = countTutorialsPerItem("intermediate");
    advancedAmount = countTutorialsPerItem("advanced");

    videoAmount = countTutorialsPerItem("video");
    textAmount = countTutorialsPerItem("text");

    englishAmount = countTutorialsPerItem("english");
    koreanAmount = countTutorialsPerItem("korean");

    dotnetAmount = countTutorialsPerItem("dotnet");
    webAmount = countTutorialsPerItem("web");
    nativeAmount = countTutorialsPerItem("native");
    generalAmount = countTutorialsPerItem("general");
  }

  function countTutorialsPerItem(item: string) {
    return tutorials.filter((tutorial: any) => {
      return (
        (item === "beginner"
          ? tutorial.level === 1
          : item === "intermediate"
          ? tutorial.level === 2
          : item === "advanced"
          ? tutorial.level === 3
          : isLevelSelected(tutorial.level)) &&
        (item === "video"
          ? tutorial.tool === "video"
          : item === "text"
          ? tutorial.tool === "none"
          : isTypeSelected(tutorial.tool)) &&
        (item === "english"
          ? tutorial.language === "en"
          : item === "korean"
          ? tutorial.language === "kr"
          : isLanguageSelected(tutorial.language)) &&
        (item === "dotnet"
          ? tutorial.type === "dotnet"
          : item === "web"
          ? tutorial.type === "web"
          : item === "native"
          ? tutorial.type === "native"
          : item === "general"
          ? tutorial.type === "general"
          : isTechnologySelected(tutorial.type)) &&
        (item === "wearable"
          ? tutorial.profile.includes("wearable")
          : item === "tv"
          ? tutorial.profile.includes("tv")
          : item === "iot"
          ? tutorial.profile.includes("iot")
          : item === "mobile"
          ? tutorial.profile.includes("mobile")
          : isProfileSelected(tutorial.profile))
      );
    }).length;
  }

  function onProfileChanged(event: {
    detail: { state: boolean; value: string };
  }) {
    const value = event.detail.value;

    if (event.detail.state) {
      profilesSelected.add(value);
    } else {
      profilesSelected.delete(value);
    }

    filterTutorials();
  }

  function onLevelChanged(event: {
    detail: { state: boolean; value: string };
  }) {
    const value = event.detail.value;

    if (event.detail.state) {
      levelsSelected.add(value);
    } else {
      levelsSelected.delete(value);
    }

    filterTutorials();
  }

  function onTypeChanged(event: { detail: { state: boolean; value: string } }) {
    const value = event.detail.value;

    if (event.detail.state) {
      typesSelected.add(value);
    } else {
      typesSelected.delete(value);
    }

    filterTutorials();
  }

  function onLanguageChanged(event: {
    detail: { state: boolean; value: string };
  }) {
    const value = event.detail.value;

    if (event.detail.state) {
      languagesSelected.add(value);
    } else {
      languagesSelected.delete(value);
    }

    filterTutorials();
  }

  function onTechnologyChanged(event: {
    detail: { state: boolean; value: string };
  }) {
    const value = event.detail.value;

    if (event.detail.state) {
      technologiesSelected.add(value);
    } else {
      technologiesSelected.delete(value);
    }

    filterTutorials();
  }

  filterTutorials();
</script>

<div class="flex p-1 border-t border-default" class:expanded>
  <div class="grow flex">
    <div class="w-[160px] flex flex-col gap-2">
      <div class="title font-extrabold">Profile</div>
      {#if expanded}
        <div class="flex flex-col">
          <FilterItem
            id="wearable"
            value="wearable"
            label="Wearable"
            amount={wearableAmount}
            checked={profilesSelected.has("wearable")}
            on:change={onProfileChanged}
          />
          <FilterItem
            id="tv"
            value="tv"
            label="TV"
            amount={tvAmount}
            checked={profilesSelected.has("tv")}
            on:change={onProfileChanged}
          />
          <FilterItem
            id="iot"
            value="iot"
            label="IoT"
            amount={iotAmount}
            on:change={onProfileChanged}
            checked={profilesSelected.has("iot")}
          />
          <FilterItem
            id="mobile"
            value="mobile"
            label="Mobile"
            amount={mobileAmount}
            on:change={onProfileChanged}
            checked={profilesSelected.has("mobile")}
          />
        </div>
      {/if}
    </div>
    <div class="w-[160px] flex flex-col gap-2">
      <div class="title font-extrabold">Level</div>
      {#if expanded}
        <div class="flex flex-col">
          <FilterItem
            id="beginner"
            value="1"
            label="Beginner"
            amount={beginnerAmount}
            checked={levelsSelected.has("1")}
            on:change={onLevelChanged}
          />
          <FilterItem
            id="intermediate"
            value="2"
            label="Intermediate"
            amount={intermediateAmount}
            checked={levelsSelected.has("2")}
            on:change={onLevelChanged}
          />
          <FilterItem
            id="advanced"
            value="3"
            label="Advanced"
            amount={advancedAmount}
            checked={levelsSelected.has("3")}
            on:change={onLevelChanged}
          />
        </div>
      {/if}
    </div>
    <div class="w-[160px] flex flex-col gap-2">
      <div class="title font-extrabold">Type</div>
      {#if expanded}
        <div class="items">
          <FilterItem
            id="video"
            value="video"
            label="Video"
            amount={videoAmount}
            checked={typesSelected.has("video")}
            on:change={onTypeChanged}
          />
          <FilterItem
            id="text"
            value="none"
            label="Text"
            amount={textAmount}
            checked={typesSelected.has("none")}
            on:change={onTypeChanged}
          />
        </div>
      {/if}
    </div>
    <div class="w-[160px] flex flex-col gap-2">
      <div class="title font-extrabold">Language</div>
      {#if expanded}
        <div class="items">
          <FilterItem
            id="english"
            value="en"
            label="English"
            amount={englishAmount}
            checked={languagesSelected.has("en")}
            on:change={onLanguageChanged}
          />
          <FilterItem
            id="korean"
            value="kr"
            label="Korean"
            amount={koreanAmount}
            checked={languagesSelected.has("kr")}
            on:change={onLanguageChanged}
          />
        </div>
      {/if}
    </div>
    <div class="w-[160px] flex flex-col gap-2">
      <div class="title font-extrabold">Technology</div>
      {#if expanded}
        <div class="items">
          <FilterItem
            id="dotnet"
            value="dotnet"
            label=".NET"
            amount={dotnetAmount}
            checked={technologiesSelected.has("dotnet")}
            on:change={onTechnologyChanged}
          />
          <FilterItem
            id="web"
            value="web"
            label="Web"
            amount={webAmount}
            checked={technologiesSelected.has("web")}
            on:change={onTechnologyChanged}
          />
          <FilterItem
            id="native"
            value="native"
            label="Native C"
            amount={nativeAmount}
            checked={technologiesSelected.has("native")}
            on:change={onTechnologyChanged}
          />
          <FilterItem
            id="general"
            value="general"
            label="General"
            amount={generalAmount}
            checked={technologiesSelected.has("general")}
            on:change={onTechnologyChanged}
          />
        </div>
      {/if}
    </div>
  </div>
  <div>
    <button
      class="p-2 rounded-lg text-white font-bold w-48 bg-[#4cccc8]"
      on:click={() => (expanded = !expanded)}
      >{expanded ? "HIDE FILTERS" : "SHOW FILTERS"} ({filteredTutorials.length})</button
    >
  </div>
</div>
