#!/bin/bash
echo 'Clearing output/blog folder...'
rm -rf output/blog
echo 'Generating content...'
pelican content -o output/blog
cd output/
python -m SimpleHTTPServer
