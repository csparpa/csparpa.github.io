Title: Command-line software design: 5 advices
Date: 2012-12-10 01:00
Category: design
Tags: software, design, shell
Slug: command-line-software-design-5-advices
Authors: csparpa
Summary: Advices on how to design command line programs

During the last years I developed several command-line utility tools, using several languages and for different environments. Attempts, learning and – of course – errors led me to clear my mind up and to adopt a series of design guidelines which I find very useful for any kind of command-line tool development – ranging from the simplest script to the most articulated modules – and which I'm willing to share. As you'll notice, the guidelines can be generalized, as they simply represent common sense approaches in SW design!  

Here I'm reporting just a few in "humurous" terms :-) (I'll share more with you in future posts as they come out from oblivion).  

From now on, CLM = Command Line Module

### 1. Provide a synopsis describing the module's purposes

**AKA: "What am I supposed to do with you, weird little script?"**

It might sound strange but one of the most recurring difficulties I've ever had when using CLM written by others (fellow workers, project partners) is to understand what they actually do. As all lazy users, I hate asking people what is the aim of a CLM and the last thing on Earth for discovering would be looking at the code itself! That's the reason why I always put a "synopsis" in my CLMs' help messages and comment headers, just like this:

```python
import os, sys
help_msg = """
    WORDSCOUNTER.py
    Synopsis:
        counts the number of words contained into the provided
        input file and prints it on standard output
    Usage:
        python wordscounter.py <input_file>
    [...]
    """
```

This way, I'm just letting users – and you yourself could be among them – know exactly what my CLM is going to do, and save them a lot of headaches. This state of intentions is also useful for you as a developer, as you could use it as a top-down problem analysis trace to go through when coding down your CLM. Had your CLM any side effect (eg: modify files, erase DB tables, etc), let the users know via the synopsis as well. Provide a short and effective synopsis.  

### 2. Minimize the module's responsibilities

**AKA: "Largo al factotum" [air from Gioacchino Rossini's "Il Barbiere di Siviglia", scene II, act I]**

As you certainly know, OOP teaches to identify programming units (classes) by spotting single responsibilities into the program's main frame. This means that a class should go with one – and possibly only one – responsibility: this helps writing clean, testable and well-designed code. This should be our aim when designing and coding ANY piece of software, also CLMs: the piece of software should do just one thing, and in the best possible way. In the world of CLMs, things tend to get a little bit fuzzy when complexity grows up, as CMLs are meant as a quick tools to accomplish multiple repetitive and boring tasks – therefore the word "multiple" here is not handshaking with OOP dogmas at all.  

So, what to do? I firmly believe that our code should not behave like Figaro in "Il Barbiere di Siviglia": it should not be meant to do everything!!! Please consider the pluses of modular software: reusability, ease of use, composability, testability…in a single word: quality!  

My personal advice is that you code complex CLMs using a top-down approach which – in a way – resembles OOP's one. You should first try to break down your main task into sub-steps and then code each sub-step into a separate CLM or into a separate function of your main CLM (it's up to you to decide which approach is the best one, depending also on the programming language you are using).  Functions and small scripts are easy to be called, can be tested and documented on their own; functions can be collected into libraries and imported by client codes, as well as small scripts can be used stand-alone or can be imported by bigger modules.  

By the way, I usually don't rely on OOP when coding simple or medium-complexity CLMs, but there are cases when this is more than an advantage.

### 3. Provide open interfaces

**AKA: "Dont' work out of my sight"**

I recently worked on a Python wrapper for a complicated .exe file, let's call it example.exe. This executable takes a few parameters, runs an algorithm and finally outputs 3 different curves in a tabular format. This module was provided me as a Commercial-Off-The-Shelf, which means that I could not modify it nor I have its source code.  

They told me: "It's so easy! You just need to invoke the executable using this command-line:"

```text
C:\> example.exe
```

I could already smell that lots of work would be needed. The following questions came instantly to my mind:

1. how can I state the CLM's inputs? what are they, files, strings, directories? how many of them? in which order?
2. how can I state the CLM's outputs? what are they, files, strings, directories? how many of them? in which order?
3. is the CLM going to need additional configuration resources (eg: files)?
4. is the CLM going to write logfiles or other kinds of additional resources? how can I state them?

Ok, let's put an end to the tale: I investigated a little bit further and discovered that example.exe was reading an input file containing lots of parameters (many of them were optional) and wrote the output data into a file which was arbitrarily put into the .exe's folder and whose name was arbitrarily given. This is a complete mess! This crap needs wrapping and its creators need to be publicly humiliated!  

This is the typical situation when the CLM does not have an open interface. I'm referring to "interface" of the CLM as to the way you can launch it by a certain enviroment (bash shell, python interpreter, command prompt, etc): as a user, your desire is to provide all of the input stuff to your module and obtain all of the output stuff you EXPECT. And this is where many CLMs fall.  

You should always provide open interfaces: this means that your CLM should not use or write anything without letting you explicitly specifying it! So, my advice is that you design your CLM's interface clearly using the following best practices:

* specifiy all the parameters (even if you end with a long command-line, don't worry)
* when giving names to parameters, try to provide meaningful and speficific designations  so that users can instantly understand what a parameter name stands for
* the interface should accept the least information letting the module work (no unuseful info!)
* avoid duplicating parameters: don't provide many times the same value (especially under different names: that would be ugly to discover)
* input parameters come first, output parameters come after inputs
* logfiles come at the end and could also be omitted – as the runtime environments (eg: bash, prompt) provide ways redirect messages to files
* configfiles come at the end as well: use them only if you have a high number of parameters (tens)

### 4. Provide help

**AKA: "No one can hear you cry in space"**

"Ok, I'm willing to launch this fucking CLM but I really don't know how to…where are the docs? Oh damn, they just gave me the binary, no documentation…so what do I do now?" How many times did you think something similar to this?  

No one should cry loud in the dark in order to get help (which – more than often – won't come), because every CLM should have a help switch! It's such a simple and wise trick: embed in your CLM one or more help strings that can help users to know how to invoke execution. The more is the help message verbose, the better for your user. I suggest you to include in your help messages the following sections:

* Synopsis – (see Advice n.1)
* Usage  - how to launch the CLM, in other words the command-line interface along with parameters explanation)
* Usage examples [optional] – two or three command-line invocation examples
* Prerequisites – anything your CLM is relying on…watch out: don't exceed with them. If something goes wrong and one or more prerequisites are missing, your module must signal this lack using exit codes
* Help switch [optional] – tells how to print the help message
* Exit codes – a list of error conditions your CLM could encounter. Each category has an associated number (zero is reserved for successful execution)
* Authors, Copyright [optional] – if you really want/need to sign your "creation"

At this point, one should ask herself/himself: "Ok, when I execute it for the first time, how can I know how to print the help message?". This question should be answered by making as simple as possible the printing of help message by the users. So, I suggest to provide help messages whenever a user provides no parameters to your CLM (only – of course – if your CLM do have one or more parameters) or whenever switches such as `[ help | -help | h | -h | /? ]` are provided.  

Example of help message in Python:

```python
import sys
help_msg = """
   WORDSCOUNTER.py
   Synopsis:
     counts the number of words contained into the provided
     input file and prints it on standard output
   Usage:
     python wordscounter.py <input_file>
   Parameters:
     <input_file> = the text file whose words are to be counted
   Help:
     you can print this message using one of the followings
     python wordscounter.py
     python wordscounter.py [ help | /? ]
   Exit codes:
    -1 - showed help
     0 - successful execution
     1 - input file does not exist
     2 - input file is not a file
     3 - input file is not a text file
    90 - internal error"""
if len(sys.argv) == 1:
  print help_msg
  sys.exit(-1)
elif len(sys.argv) == 2 and sys.argv[1] == 'help' or sys.argv[1] == '/?':
  print help_msg
  sys.exit(-1)
```

### 5. Tell the user what is happening

**AKA: "It's thinking, I will have a cofee in the meantime"**

How many times I started a CLM with a terminal looking like this:

```bash
claudio@laptop:~$ bash install.bash package.tar.gz
```

and after minutes or tens of minutes the terminal looked like this:

```bash
claudio@laptop:~$ bash install.bash package.tar.gz
claudio@laptop:~$
```

How many times? Countless! This is because the module is not telling me what it is currently doing. This way, I can not state how much it will take for it to complete the task, I can not even know whether it's performing well or not and I can not know at which stage of the whole computation it is running… I can not schedule my time, as I depend on the module's outputs, therefore I will be less productive!  

So the basic advice is: whenever the tool starts to do something new (e.g: enters a specific computational stage, starts parsing parameters, writing output files or inverting matrices or whatever) please print something onscreen and/or onto a logfile. This will save a lot of headaches to the CLM's users and it will be easy also for recognize that bugs are coming (such as execution stuck into infinite loops). I suggest you to make your CLM verbose, but not  "gossipy": you don't have to make it echo out every single line of code that is executed (and if you really need to, use something like: `bash -x`)  

Another idea is to make your CLM print the amount of work (percentage?) done against the overall, better if along with a gross estimation of the time needed to complete the task: this is very useful when dealing with long-running tasks such as matrices inversion, recursive algorithms, and so on.