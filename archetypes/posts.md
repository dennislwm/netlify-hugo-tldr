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

