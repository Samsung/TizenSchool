<script lang="ts">
  export let member: {
    photoFileName: string;
    name: string;
    surname: string;
    job: string;
  };
</script>

<div class="flex flex-col items-center">
  <div
    style={`background-image: url(/assets/images/about-us/${member.photoFileName});`}
    class="
      rounded-full w-[205px] h-[205px] bg-[size:205px] bg-center before:content-[''] before:absolute relative 
      before:inset-0 before:opacity-40 before:bg-primary before:rounded-full hover:border-4 border-primary hover:shadow-[inset_0_0_0_4px_#fff] before:hover:inset-1
    "
  />
  <div class="text-2xl uppercase pt-10">
    <!--  prettier-ingore -->
    <span>{member.name}</span><span class="font-bold">{member.surname}</span>
  </div>
  <div class="italic text-lg font-semibold">{member.job}</div>
</div>
