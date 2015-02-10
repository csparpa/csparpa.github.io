Title: Serve minified CSS and Javascript on a Pelican-powered blog
Date: 2015-02-10 10:41
Category: howtos
Tags: Python, blogging, Pelican, Javascript, CSS, minify
Slug: minify-resources-for-pelican-blog
Authors: csparpa
Summary: How to minify CSS and Javascript content for serving with a Pelican-powered blog

### Summary
In this short tutorial I'll show you how to wire minified CSS and Javascript into your Pelican-powered blog - I did it on my own one (the one you're currently reading!)


### How minification works
"Minification" is the process of compressing the content of CSS and Javascript files by:

 * removing characters (like whitespaces and tabs) the processor/interpreter is insensitive to
 * replacing long variable names with shorter ones (eg: naming variables with just one or two letters)

This is helpful as it decreases the size of `.css` and `.js` files and therefore when these files will be sent over the wire they'll take less time (and bandwidth) to be delivered.

A shortcoming is that minified code is no longer readable by humans, but this seldom is a problem as minification is a one-way process and one can automate it in order to keep the unminified source files apart.


### Requirements
You can read in [my previous post](http://csparpa.github.io/blog/2014/11/setup-static-blog-with-pelican.html) how to setup a weblog using the Pelican library.

In order to install the dependencies we'll need, you need to install the `pip` package manager

### Install minifiers
There are lots of CSS and Javascript minifiers out there.

I've looked specifically for Python minifiers and found `jsmin` for Javascript minification and `csscompressor` for CSS minification.

You can install them with:

```bash
$> pip install jsmin
$> pip install csscompressor
```


### Use minifiers
Their usage is very simple:

```bash
# Minify a Javascript file
$> python -m jsmin my.js > my-minified.js

# Minify a CSS file
$> python -m csscompressor -o my-minified.css my.css
```  

The minifiers output shall be put into your blog's css and js folders, getting served by your webserver.


You can (and you should) add the resource minification commands to your automatic blog-build script - and if you don't have one, go make it! ;)

