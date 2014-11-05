#!/usr/bin/env python
# -*- coding: utf-8 -*- #
from __future__ import unicode_literals

AUTHOR = u'csparpa'
SITENAME = u'Vorsprung durch Informatik'
SITEURL = 'http://csparpa.github.io'

PATH = 'content'

TIMEZONE = 'Europe/Rome'

DEFAULT_LANG = u'en'

DEFAULT_DATE_FORMAT = ('%d/%b/%Y %H:%M')

RELATIVE_URLS = False

HIDE_CATEGORIES_FROM_MENU = True

# URLs formatting
ARTICLE_URL = "{date:%Y}/{date:%m}/{slug}.html"
ARTICLE_SAVE_AS = "{date:%Y}/{date:%m}/{slug}.html"

# Sharethis public key
# SHARETHIS_PUB_KEY = '(575237d0-911a-4d3f-81c4-4cd875623044)'

DISQUS_SITENAME = "csparpa"

# Feed generation is usually not desired when developing
FEED_ALL_ATOM = 'feeds/all.atom.xml'
CATEGORY_FEED_ATOM = 'feeds/%s.atom.xml'

# Blogroll
LINKS = (('Website', 'http://csparpa.tk'),
         ('Time is a gentleman', 'http://claudiosparpaglione.wordpress.com/'),)

# Social widget
SOCIAL = (('GitHub', 'https://github.com/csparpa'),
          ('Linkedin', 'http://linkedin.com/in/claudiosparpaglione'),
          ('Twitter', '@csparpa'),)


DEFAULT_PAGINATION = 5

THEME = 'themes/fresh'