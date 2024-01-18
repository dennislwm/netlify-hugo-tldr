# netlify-hugo-tldr

[![Netlify Status](https://api.netlify.com/api/v1/badges/5ec45234-db66-4daf-b3ba-36217c21c823/deploy-status)](https://app.netlify.com/sites/dennislwm/deploys)

**netlify-hugo-tldr** starter project.

_Note: To find the specific badge URL for your site, go to your Netlify account > Site settings > General > Status badges._

---
# 1. Introduction
## 1.1. Purpose

This document describes the `netlify-hugo-tldr` automation and manual services that is provided for my personal blog.

## 1.2. Audience

The audience for this document includes:

* Blogger who will create and modify blog posts on their workstation.

* DevSecOps Engineer who will configure and maintain the build tool, pipeline, and static site.

---
# 2. System Overview
## 2.1. Benefits and Values

## 2.2. Workflow

This project uses several methods and products to optimize your workflow.
- Uses a SaaS application (**Netlify.app**) to host your static site.
- Uses a Static Site Generator (**Hugo**) to generate and customise your static site and theme.
- Uses a Version Control System (**GitHub**) to track your changes and collaborate with others.
- Uses a Build Tool (**Makefile**) to automate your development tasks.
- Uses a SaaS Continuous Integration & Deployment Pipeline (**Netlify**) to automate your build and deployment.

## 2.3. Limitations

This project has several limitations that may hinder your workflow.

---
# 3. User Personas
## 3.1 RACI Matrix

|            Category            |             Activity              | Blogger | DevSecOps |
|:------------------------------:|:---------------------------------:|:-------:|:---------:|
| Installation and Configuration | Creating a new archetype template |         |    R,A    |
|           Execution            |     Creating a new blog post      |   R,A   |           |

---
# 4. Requirements
## 4.1. Workstation

* [Hugo](https://gohugo.io/installation/)

---
# 5. Installation and Configuration
## 5.1. Creating a new archetype template

1. Copy the file `archetypes/default.md` to a new file `archetypes/posts.md`.

2. Copy and paste the following content into the `posts.md`.

```jinja
---
author: "{{ .Site.Param "myname" }}"
title: "{{ replace .Name "-" " " | title }}"
date: "{{ strings.SliceString time.Now.Weekday.String 0 3 }}, {{ time.Now.Day }} {{ strings.SliceString time.Now.Month.String 0 3 }} {{ time.Now.Year }} {{ time.Now.Hour }}:{{ time.Now.Minute }}:{{ time.Now.Second }} +0800"
description: "{{ replace .Name "-" " " | title }}"
draft: true
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
---
```

Hugo looks for archetypes in the following order:
  1. `archetypes/posts.md`
  2. `archetypes/default.md`
  3. `themes/my-theme/archetypes/posts.md`
  4. `themes/my-theme/archetypes/default.md`

If none of these exists, Hugo uses a built-in default archetype.

---
# 6. Execution
## 6.1. Creating a new blog post

1. Open a new terminal, and type the following command:

  ```sh
  hugo new content posts/[TITLE].md
  ```

where TITLE should be your blog post title, e.g. `my-first-post`.

2. This should create a new markdown file in your path `content/en/posts/my-first-post.md` with a default metadata:

```md
---
author: "Dennis Lee 👨"
title: "My First Post"
date: "Thu, 18 Jan 2024 15:47:32 +0800"
description: "My First Post"
draft: true
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
---
```

---
# 7. References

The following resources were used as a single-use reference.

|                             Title                             |       Author       |
|:-------------------------------------------------------------:|:------------------:|
| [Archetypes](https://gohugo.io/content-management/archetypes) | Hugo Documentation |
|      [Site variables](https://gohugo.io/variables/site)       | Hugo Documentation |
|        [Time methods](https://gohugo.io/methods/time)         | Hugo Documentation |