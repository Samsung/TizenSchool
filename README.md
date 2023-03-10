# Authoring a tutorial

1. Create an `{id}.md` file in `/src/pages/tutorials/` with a chosen unique id.
1. Create an `{id}` directory in `public/assets/images/tutorials/`
   - There you may place images for your tutorial and the thumbnail
   - In order to reference them, use an url like this: `/assets/images/tutorials/{id}/my_image.png`

## If you're authoring a text tutorial

1. Include a frontmatter in this format in the md file:

```yaml
---
layout: ../../layouts/tutorial/TextTutorial.astro
title: "YOUR TITLE"
description: "YOUR DESCRIPTION"
created: "2022/03/19" # creation date in provided format
profile: ["iot", "mobile"] # any combination of: "web" "mobile" "iot" "tv"
type: "native" # one of: "native" "web" "dotnet" "general"
level: 2 # one of: 1 2 3
state: "closed" # must be changed to "open" right before merge
thumbnail: "THUMBNAIL URL"
---
```

4. Fill in the body of the tutorial. `#` and `##` headers will become chapters and sections of your tutorial.
5. In order to add highlights to code fences use a `highlight` tag as shown below. Inside the tag place a comma separated list of lines or ranges to highlight

````md
<highlight>1,3,5-6</highlight>

```lang
my code here
```
````

## If you're authoring a viedo tutorial

1. Include a frontmatter in this format in the md file:

```yaml
---
layout: ../../layouts/tutorial/VideoTutorial.astro
title: "YOUR TITLE"
description: "YOUR DESCRIPTION"
created: "2022/03/19" # creation date in provided format
profile: ["iot", "mobile"] # any combination of: "web" "mobile" "iot" "tv"
type: "native" # one of: "native" "web" "dotnet" "general"
level: 2 # one of: 1 2 3
state: "closed" # must be changed to "open" right before merge
thumbnail: "THUMBNAIL URL"
videoUrl: "URL TO VIDEO OF TUTORIAL"
---
```

2. Keep the body of the tutorial empty

## If you're modifying an existing tutorial

Add a `modified` entry to the frontmatter, formatted identically to the `created` entry

## Preview and submit the tutorial

1. Run `npm run dev` and navigate to `/tutorials/{id}` to preview your tutorial

2. Submit a pull request
