#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

# Blog global info
AUTHOR = u'csparpa'
SITENAME = u'Vorsprung durch Informatik'
ROOTURL = 'http://csparpa.github.io'
SITEURL = ROOTURL + '/blog'

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

# Pelican plugins
PLUGIN_PATHS = [u'plugins']
PLUGINS = [u'sitemap']

# Social widget
DISQUS_SITENAME = "csparpa"

# Google Analytics hook
GOOGLE_ANALYTICS = 'UA-56547669-1'

# Feed generation
FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

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

# Configuration for the 'sitemap' plugin
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