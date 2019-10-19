---
layout: download-solution
solution: server
title: ALT Linux Server
lang: en
---
{% assign sol = site.descriptions | where: "name", page.solution | first %}

<h1>{{ sol.header[page.lang] }}</h1>

{{ sol.description[page.lang] }}

{% assign images = site.contents | where: "solution", page.solution %}
{% for img in images %}
DOWNLOAD: {{ img.url }}<br>
{% endfor %}

