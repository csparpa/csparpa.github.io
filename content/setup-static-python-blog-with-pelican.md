Title: Setup a static Python-powered blog/website with Pelican
Date: 2014-11-01 13:49
Category: howtos
Tags: python, blogging, pelican
Slug: setup-static-blog-with-pelican
Authors: csparpa
Summary: How to setup a static Python-powered blog/website in 10 minutes using Pelican

### Summary
Pelican is a Python library that allows static content generation from plain text files written using ReSructured Text or Markdown syntaxes.  
It is an efficient, easy to setup tool that can - in example - be used to create blogs in minutes.  
More info on the [official Pelican blog](http://blog.getpelican.com/), and of course links to source code and docs.  


In this tutorial we'll be generating a blog and posting content using Markdown.  
We'll call our blog: "blog"  

### Requirements
You will need Python 2.7+ and the `pip` package manager

### Install Pelican
Install Pelican and Markdown syntax modules:
```bash
$> pip install pelican Markdown
```  

### Create a skeleton Pelican project
```bash
$> cd 
$> mkdir blog
$> cd blog
$> pelican-quickstart
$> tree
    ./
    +-- content              # Place here source .md files
    +-- output               # Will contain the output .html files after generation
    +-- develop_server.sh
    +-- fabfile.py
    +-- Makefile
    +-- pelicanconf.py       # Main settings file
    +-- publishconf.py       # Settings to use when ready to publish
```  
  
### Install themes
You can modify Pelican's default theme by installing (cloning) one or more
of the [themes you find on Github](https://github.com/getpelican/pelican-themes):
```bash
$> cd pelican-test
$> mkdir -p themes/fresh  # I've chosen to install the 'fresh' theme
$> git clone git://github.com/jsliang/pelican-fresh themes/fresh
```  
  
### Write Pelican configuration file
The configuration file is `pelicanconf.py`, it will be used by Pelican
when generating HTML content from the Markdown sources:
```python
#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'me'
SITENAME = u'blog'
SITEURL = ''

# Pelican will take contents in this folder as sources
PATH = 'content'

TIMEZONE = 'Europe/London'

DEFAULT_LANG = u'en'

# Feed generation
FEED_ALL_ATOM = None
CATEGORY_FEED_ATOM = None
TRANSLATION_FEED_ATOM = None

# Blogroll links
LINKS = (('My link 1', 'http://mylink1.com'),
         ('My link 2', 'http://mylink2.com'),)

# Social widget links
SOCIAL = (('My social link 1', 'https://mysociallink1.com'),
          ('My social link 2', 'https://mysociallink2.com'),)

# Max Number of article previews per page
DEFAULT_PAGINATION = 5

# Document-relative URLs ?
RELATIVE_URLS = True

# Path to the theme you want to apply
THEME = 'themes/fresh'
```  

### Write a blog post
Now write a Markdown blog post like this one:
```text
Title: My test blog post
Date: 2014-11-01 13:49
Category: attempts
Tags: blogging, pelican, markdown
Slug: my-test-blog-post
Authors: me
Summary: This is a really deep and introspective test blog post

What is the meaning of life the universe and everything?
--------------------------------------------------------
42
```
and save it into the `content` folder as `test.md`

### Generate HTML from Markdown
You're now ready to generate the corresponding HTML content:
```bash
$> pelican content -o output
$> tree output
    output/
    +-- author/
    +-- category/
    +-- feeds/
    +-- images/
    +-- tag/
    +-- theme/
    +-- archives.html
    +-- authors.html
    +-- categories.html
    +-- index.html
    +-- my-test-blog-post.html
    +-- tags.html
```  

### Take a look!
You can now preview your blog by launching a web server:
  
```bash
$> python -m SimpleHTTPServer 8888
```
and pointing your browser to <http://localhost:8888>.  
Cool, isn't it?

### Installing Pelican plugins
Pelican is an extensible platform, which means you can add one or more [plugins](https://github.com/getpelican/pelican-plugins)
into it and add functionalities.  
You can install community-provided plugins by cloning the plugins repository:

```bash
$> git clone https://github.com/getpelican/pelican-plugins plugins
```

Now the plugins are in the `plugins` folder and you can enable/disable them and put their corresponding configuration
data into your Pelican configuration file.


### Adding an XML sitemap

You want your blog to be fully crawled by Google, dont' you? So you need to generate a sitemap for it.  
Generating a sitemap is easy if you use the `sitemap` plugin.  
What you need to do is, once you've installed all the plugins, add the following lines to the `pelicanconf.py`:

```python
# Path to the folder containing the plugins
PLUGIN_PATHS = [u'plugins']

# The plugins you want to be enabled
PLUGINS = [u'sitemap']

# Configuration for the "sitemap" plugin
SITEMAP = {
    'format': 'xml',
    'priorities': {
        'articles': 1,
        'indexes': 0.5,
        'pages': 0.5,
    },
    'changefreqs': {
        'articles': 'always',
        'indexes': 'hourly',
        'pages': 'monthly'
    }
}
```

Regenerate the output and you'll notice your `output` folder now contains a `sitemap.xml` file.  

### Where to go from here
Now you can upload the contents of the `output` folder 'as are' to your web hosting provider.  
Don't forget to setup your Google Analytics account to crawl to the domain you publish the pages under.  
Visit the  [Pelican tips page](http://docs.getpelican.com/en/3.4.0/tips.html) which also explains how to integrate Pelican into GitHub pages.