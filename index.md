---
layout: default
---


# Welcome to Ben's blog




<!-- begin posts summary. -->
<!-- this section produces proper HTML, which is safely embedded in Markdown. -->
<div class='post listing' id='post-listing'>
{% for post in site.posts %}
    <div class='post item'>    
        <div class='post timestamp'>
            <time datetime='{{ post.date | date: "%F %T %Z" }}'>
                {{post.date | date_to_string }}
            </time>
        </div>
        <h3 class='post title inline'><a href='{{post.url}}' class='post link'>{{post.title}}</a></h3>
        <div class='post excerpt'>
        {{ post.summary | default: post.excerpt }}
        </div>
    </div>
{% endfor %}
<div>
<!-- end posts summary. -->
