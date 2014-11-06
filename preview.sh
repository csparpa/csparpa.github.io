#!/bin/bash
echo '***Clearing ./output/blog/ folder...'
rm -rf output/blog
echo '***Generating blog content...'
pelican content -o output/blog
echo '***Copying images to blog...'
mkdir output/blog/img
cp images/*.png output/blog/img
echo '***Copying static website to ./output/ folder...'
cp -R website/* output/
echo '***Copying CNAME settings to ./output folder...'
cp extra/CNAME output/
echo '***Serving on http://localhost:8000...'
cd output/
python -m SimpleHTTPServer &> /dev/null
