#!/bin/bash
echo '***Clearing .pyc files...'
rm *.pyc
echo '***Clearing ./output/blog/ folder...'
rm -rf output/blog
echo '***Generating blog content...'
pelican content -s publish_conf.py -o output/blog
echo '***Copying images to blog...'
mkdir output/blog/img
cp images/*.png output/blog/img
cp images/favicon.ico output/
cp images/favicon.ico output/blog
echo '***Copying static website to ./output/ folder...'
cp -R website/* output/
if [ -f extra/CNAME ]; then
    echo '***Copying CNAME settings to ./output folder...'
    cp extra/CNAME output/
fi
echo '***Pushing to GitHub pages on csparpa.github.io@master...'
ghp-import output
git push http://github.com/csparpa/csparpa.github.io gh-pages:master
