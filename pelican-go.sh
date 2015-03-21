#!/bin/bash

# functions
function print_usage {
  echo "Usage:"
  echo "  ./pelican-go.sh [ preview | publish ]"
}

function clear_pyc {
  echo '***Clearing .pyc files...'
  rm *.pyc
}

function clear_output_dir {
  echo '***Clearing ./output folder...'
  rm -Rf output/
  mkdir output
}

function compile_blog_content {
  echo '***Generating blog content...'
  pelican content -s preview_conf.py -o output/blog
}

function deploy_blog_images {
  echo '***Copying images to blog...'
  mkdir output/blog/img
  cp images/*.png output/blog/img
  cp images/favicon.ico output/blog
}

function deploy_blog_resources {
  echo '***Copying resource files to blog...'
  mkdir output/blog/res
  cp resources/* output/blog/res
}

function deploy_website {
  echo '***Copying static website to ./output/ folder...'
  cp -R website/* output/
  if [ -f extra/CNAME ]; then
      echo '***Copying CNAME settings to ./output folder...'
      cp extra/CNAME output/
  fi
}

function minify_website_css {
  echo '***Minifying CSS files...'
  for f in output/css/*.css
  do
    python -m csscompressor -o "$f" "$f"
  done
}

function minify_website_javascript {
  echo '***Minifying Javascript files...'
  for f in output/js/*.js
  do
    filename="$(basename $f)"
    python -m jsmin "$f" > tmp.file 
    cat tmp.file > "$f"
    rm tmp.file
  done
}

function serve_preview {
  echo '***Serving preview on http://localhost:8000...'
  local port="$1"
  if [ -z "$port" ]; then
    port="8000"
  fi
  cd output/
  python -m SimpleHTTPServer "$port" &> /dev/null
}

function publish_to_github {
  echo '***Pushing to csparpa.github.io@master...'
  tempdir="$(mktemp -d)"
  cp -R output/* "$tempdir"
  echo "$tempdir"
  git checkout master
  cp -R "$tempdir"/* .
  echo 'Modifications:'
  git status
  git add -A
  staged_files="$(git diff --cached --numstat | wc -l)"
   if [ $staged_files -ne 0]; then
     echo 'No local modifications to be pushed'
   else:
     git commit -m "Automatic commit"
     git push https://csparpa@github.com/csparpa/csparpa.github.io.git master
   fi
}

# actual action script
exitcode=1
if [ "$#" -eq 1 ]; then
  mode="$1"
  if [ "$mode" == 'preview' ]; then
    echo "*** Pelican: performing action '$mode' in folder: $(pwd)"
    echo ""
    clear_output_dir
    compile_blog_content
    deploy_blog_images
    deploy_blog_resources
    deploy_website
    minify_website_css
    minify_website_javascript
    serve_preview "8000"
    exitcode=0
  elif [ "$mode" == 'publish' ]; then
    echo "*** Pelican: performing action '$mode' in folder: $(pwd)"
    echo ""
    clear_output_dir
    compile_blog_content
    deploy_blog_images
    deploy_blog_resources
    deploy_website
    #minify_website_css
    #minify_website_javascript
    publish_to_github
    exitcode=0
  fi
fi
if [ $exitcode -ne 0 ]; then
  print_usage
fi
exit $exitcode
