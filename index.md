---
layout: default
---

Welcome to my GREAT Home Page

{% assign date = '2020-04-13T10:20:00Z' %}

- Original date: {{ date }}
- With timeago filter: {{ date | timeago }}
