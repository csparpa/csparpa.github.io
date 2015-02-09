Title: Linux paths manipulation
Date: 2011-10-25 01:00
Category: Linux
Tags: Linux, shell
Slug: linux-paths-manipulation
Authors: csparpa
Summary: How to play with Linux paths, filenames and dirnames

Sometimes – when geeking around in Linux – you need to play with things like filenames, paths and so on. Here's a quick reference that uses *readlink*, *basename* and *dirname* commands.  

You have a folder structure like, say:  

```text
/opt/
   |_ goofy.txt
   |_ test/
       |_ mickey.txt
```  

Now, let's get inside:  

```bash
$> cd /opt
```  

and let's start playing:  

```bash
# ABSOLUTE PATHS 
# Get absolute path of goofy.txt</span>
$> readlink -f goofy.txt          # Gives: /opt/goofy.txt
# ...and of mickey.txt
$> readlink -f test/mickey.txt    # Gives: /opt/test/mickey.txt
 
# FILENAMES 
# Get filename for mickey.txt without extension
$> basename test/mickey.txt .txt    # Gives: mickey
 
# BASE DIRECTORIES 
# Get base directory relatively to the current directory
$> dirname goofy.txt          # Gives: .
$> dirname test/mickey.txt    # Gives: test
#...and then absolutely
$> dirname "$(readlink -f goofy.txt)"        # Gives: /opt
$> dirname "$(readlink -f test/mickey.txt)"  # Gives: /opt/test
```  

As you can see, it's just... for playing :-)