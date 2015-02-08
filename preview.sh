#!/bin/bash

echo '***Clearing .pyc files...'
rm *.pyc

echo '***Clearing ./output folder...'
rm -rf output/*

echo '***Generating blog content...'
pelican content -s preview_conf.py -o output/blog

echo '***Copying images to blog...'
mkdir output/blog/img
cp images/*.png output/blog/img
cp images/favicon.ico output/blog

echo '***Copying resource files to blog...'
mkdir output/blog/res
cp resources/* output/blog/res

echo '***Copying static website to ./output/ folder...'
cp -R website/* output/
if [ -f extra/CNAME ]; then
    echo '***Copying CNAME settings to ./output folder...'
    cp extra/CNAME output/
fi

echo '***Minifying CSS files...'
for f in output/css/*.css
do
   python -m csscompressor -o "$f" "$f"
done

echo '***Minifying Javascript files...'
for f in output/js/*.js
do
   filename="$(basename $f)"
   python -m jsmin "$f" > tmp.file 
   cat tmp.file > "$f"
   rm tmp.file
done

echo '***Serving preview on http://localhost:8000...'
cd output/
python -m SimpleHTTPServer &> /dev/null
