#!/bin/bash
echo 'Clearing output/blog folder...'
rm -rfv output/blog
echo 'Generating content...'
pelican content -o output/blog
ghp-import output
echo 'Pushing to GitHub pages...'
git push git@github.com:csparpa/csparpa.github.io.git gh-pages:master
