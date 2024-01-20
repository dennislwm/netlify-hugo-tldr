---
author: "{{ .Site.Param "myname" }}"
title: "{{ replace .Name "-" " " | title }}"
date: "{{ strings.SliceString time.Now.Weekday.String 0 3 }}, {{ time.Now.Day }} {{ strings.SliceString time.Now.Month.String 0 3 }} {{ time.Now.Year }} 12:00:06 +0800"
description: "{{ replace .Name "-" " " | title }}"
draft: true
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
---

<!-- TOC depthfrom:2 -->

- [Introduction](#introduction)
- [TL;DR](#tldr)
- [Conclusion](#conclusion)
- [Get the Source Code](#get-the-source-code)
- [What To Do Next](#what-to-do-next)

<!-- /TOC -->on

---
## TL;DR

---
## Conclusion

---
## Get the Source Code


You can download the above source code from my GitHub repository.

---
## What To Do Next

You can further extend your code in several meaningful ways:

* * *

**Was this article useful? Help me to improve by replying in the comments.**

[![Buy Me A Coffee donate button](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://ko-fi.com/dennislwm "Donate to this project using Buy Me A Coffee")
