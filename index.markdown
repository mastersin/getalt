---
# Feel free to add content and custom Front Matter to this file.
# To modify the layout, see https://jekyllrb.com/docs/themes/#overriding-theme-defaults

layout: home
---



{% for distrib_hash in site.data.distribs %}
<div>
  {% assign distrib = distrib_hash[1] %}
	<h2 style="text-align: center;">
    <a href="https://github.com/{{ org.username }}">
      {{ distrib.name }}
    </a>
</h2>
    <div>
      {% for loc in distrib.members %}
        <li>
          {{ loc.name }} 
        </li>
      {% endfor %}
    </div>
  </div>
{% endfor %}
</ul>