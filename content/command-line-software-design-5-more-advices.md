Title: Command-line software design: 5 more advices
Date: 2013-04-18 01:00
Category: design
Tags: software, design, shell
Slug: command-line-software-design-5-more-advices
Authors: csparpa
Summary: More advices on how to design command line programs

Ok, folks, ready to take off with 5 more CLMs (Command-Line Modules) design advices?  This is part II of a posts strip, part I contains the first 5 advices.

### 1. Provide meaningful messages

**AKA: "What am I doing? I am existing..."**

Your CLM should provide insight into what it is currently doing. The difficult part is to decide how much detail you want to provide to the user...and you might argue: "Ok, but you can always use log level filtering and then let the user decide the verbosity" – this is perfectly right, but I'm talking about on-screen messages. My advice is to print out a specific message which conveys what the CLM is currently doing, with a detail level which should be just enough for the user not to say "It is talking rubbish"! So, what is really vital is that you avoid using simple and generalistic messages like "Computing" or "Executing" and – on the other hand – that you avoid using hyper-detailed expressions such as "Inverting matrix – computing determinant of the 3rd 2×2 submatrix" *if they are not meaningful to the user*. Of course if the focus of your CLM is matricial inversion that shall be fine, but it shouldn't be if your CLM is – in example – focused on a higher-level problem which is solved using matricial inversion.  

...And, please, never print out the raw counters in nested for loops. It happened to me just a couple of days ago to run an image-processing CLM provided by a project partner: this was the output of a successful run  

```bash
claudio@laptop:~$ python img_processing_clm.py input.tif output.tif
Conversion to 8bit took 23.567 seconds
1
2
3
4
5
6
#2000 or so more lines
The variance computation took 367.145 seconds
...
```

Each and every row index is printed out....It is just irritating!!!


### 2. Gracefully fail

**AKA: "I don't want to see each blood drop spreading from your wound"**

As a CLM user, would you prefer seeing this:  

```bash
claudio@laptop:~$ python myclm.py /var/clmdata/testoutdir  #we are missing the first parameter
  Traceback (most recent call last):
  File "myclm.py", line 3, in <module>
  inputfile = sys.argv[1]
  IndexError: list index out of range
claudio@laptop:~$ echo $?
1
```

..or this?  

```bash
claudio@laptop:~$ python myclm.py /var/clmdata/testoutdir  #we are missing the first parameter
  ERROR: you must specify an input file
  Usage:
    myclm.py <inputfile_path> <output_path>
claudio@laptop:~$ echo $?
1
```

The correct answer would be: none of them! But you can't expect that your CLM is working fine every time. So it is important to let users know what reasons made the CLM stop running. A nice design choice is to detect possible error conditions and treat them so that your CLM "says something of interest" and terminates with a known exit status: this can be done quite easily if you use languages (eg: Java, Python, etc..) that provide formal exception/error handling constructs – in other terms, the usual try/catch blocks.  

Graceful failures are delightful for the user, but may not the best approach to handle error situations while you are still writing your CLM because they may not give you enough information if you need to debug. So my advice is to add them only when you are pretty sure that you won't make further heavy changes or do any more refactoring on your CLM.

### 3. Organize your CLM folder

**AKA: "I am the Borg ... I bring order to chaos" (Borg Queen – Star Trek: First Contact)**

Order in organizing your code is good. This translates directly into the fact that a well-structured CMS is easy to understand and modify, and can be efficiently used in a small amount of time. My advice is to adhere to widely adopted or standard program folder structuration patterns: I usually have my CLM's folder in this fashion

```text
CLM-folder/
  |--bin/     #Binaries: main CLM program and dependancies
  |--doc/     #Documentation about CLM usage/installation
  |--src/     #Source files
  |--static/  #Static data: config files, static inputs, etc.
  `--test/    #Tests
```

### 4. Minimize filesystem usage and leverage temporary folders

**AKA: "Forbidden: you don't have enough permissions to write the file"**

As a general advice, don't rely on the safety of filesystem operations. If your CLM needs to store intermediate data try to do that in-memory, and if it's not possible and therefore you are compelled to use the filesystem, your target should be to put the least complexity between your CLM and your data. Reading data from filesystems seldom is a problem, but writing often is, and the amount of adversities you might face depends on a variety of factors such as the architecture (never tried to write in a folder for which you don't have `w` permissions?), the possible concurrency in data modification, the remoteness of the target filesystem and so on.  

Another misused – but smooth and clever – technique is to leverage temporary folder support provided by the operating systems. In my experience with bash programming, I've always seen people doing local computations as follows: input files are copied into the same folder of the executing binaries, then intermediate files are written in that folder (usually, a lot  of files), and in case of successful CLM end intermediate files are deleted. This always made me angry, because often their programs were  buggy and therefore never got to their natural end, which forced me to press `CTRL+C`... leaving all of those intermediate files undeleted in the folder. And this meant: I myself would have to delete them!!! :-o To solve this issue, I simply suggested those people to leverage the "mktemp" Linux command, which creates a temporary folder with a pseudo-random name under /tmp and returns its name: one can then use this folder to do whatever she/he likes – i.e. writing the CLM execution's intermediate rubbish.  

It's as easy as follows:

```bash
claudio@laptop:~$ tempdir=$(mktemp)
claudio@laptop:~$ echo $tempdir
/tmp/tmp.hyYKY21864
```

### 5. Leverage absolute paths

**AKA: "Time – as well as folder location – is relative"**

When you provide paths as arguments for CLMs it is a very good practice to give them in an absolute fashion. If you give absolute paths, there's a pretty good chance that your CLM  addresses files and folders in the right way. And my advice is: always handle absolute paths internally to your command-line softwares...in fact, this will prevent you from using terrible solutions like the `cd` (change directory) command, which will mess the whole thing up if you are using relative paths because the root folder they are resolved against changes!  

A little coding exercise: let us write a small bash script (copier.bash) that takes reads a file and echoes its contents to a file named `results.out` which will be created in a directory of our choice. We want it to have this interface:  

```text
copier.bash <inputfile_path> <output_path>
```

and here is the code (as you can see I'm using the `cat` executable which lies in the `/bin` path on my Linux system):  

```bash
#!/bin/bash
 
inputfile="$1"
outputdir="$2"
 
bindir="/bin"
 
cd "$bindir"
cat "$inputfile" > "$outputdir/result.out"
```

Now if we setup the environment like this:

```bash
claudio@laptop:~$ cd /opt/copier
claudio@laptop:~$ mkdir output  #we create the output folder
claudio@laptop:~$ tree .
.
|-- copier.bash
`-- output
1 directory, 1 file
claudio@laptop:~$ echo "italia has got talent" > input.txt #we create the input file
claudio@laptop:~$ bash copier.bash input.txt output        #we run the script
copier.bash: line 9: output/result.out: No such file or directory
```

As we expected, the `cd` inside our script is messing up everything and the bash shell is complaining about the fact that after it, it is impossible to find the `output` subfolder (which, in absolute terms, is: `/bin/output` !!!)  

Also the following command-line fail:  

```bash
claudio@laptop:~$ bash copier.bash input.txt /opt/copier/output
cat: input.txt: No such file or directory
```

This time it's the `cat` executable complaining for the missing `input.txt` file, which it expects to be here: `/bin/input.txt`  

The right way of running this script would be:  

```bash
claudio@laptop:~$ bash copier.bash /opt/copier/input.txt /opt/copier/output
claudio@laptop:~$ cat output/result.out
italia has got talent
```

You can see that: one must know in advance that absolute paths must be used. And consider that we were lucky to have a textual CLM, what if we had a compiled one? Lesson learn: never use `cd` and leverage absolute paths!