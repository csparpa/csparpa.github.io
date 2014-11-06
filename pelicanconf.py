#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# Blog global info
AUTHOR = u'csparpa'
SITENAME = u'Vorsprung durch Informatik'
SITEURL = 'http://csparpa.github.io'

# Path for source .md files
PATH = 'content'

# Date/language settings
TIMEZONE = 'Europe/Rome'
DEFAULT_LANG = u'en'
DEFAULT_DATE_FORMAT = ('%d/%b/%Y %H:%M')

# Rel/abs URLs
RELATIVE_URLS = True

# Control categories display on navigation bar
HIDE_CATEGORIES_FROM_MENU = True

# URLs formatting
ARTICLE_URL = "{date:%Y}/{date:%m}/{slug}.html"
ARTICLE_SAVE_AS = "{date:%Y}/{date:%m}/{slug}.html"

# Social widget
DISQUS_SITENAME = "csparpa"

# Feed generation
FEED_ALL_ATOM = 'blog/feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'blog/feeds/%s.atom.xml'

# Blogroll links
LINKS = (('Website', 'http://csparpa.tk'),
         ('Time is a gentleman', 'http://claudiosparpaglione.wordpress.com/'),)

# Social links
SOCIAL = (('GitHub', 'https://github.com/csparpa'),
          ('Linkedin', 'http://linkedin.com/in/claudiosparpaglione'),
          ('Twitter', '@csparpa'),)

# How many article previews per page
DEFAULT_PAGINATION = 5

# The graphical theme for the blog
THEME = 'themes/fresh'