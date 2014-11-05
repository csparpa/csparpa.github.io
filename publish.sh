#!/bin/bash
echo 'Clearing output/blog folder...'
rm -rfv output/blog
echo 'Generating content...'
pelican content -o output/blog
ghp-import output
echo 'Pushing to GitHub pages...'
git push http://github.com/csparpa/csparpa.github.io gh-pages:master
