Title: The yes command
Date: 2012-06-22 01:00
Category: Linux
Tags: Linux, shell
Slug: the-yes-command
Authors: csparpa
Summary: A Linux command that indefinitively repeats a given text bit

The dumbest "yes-man" Linux command: `yes`!  

It has only one aim: to continuously repeat what you tell it. Useful if pipelined with interactive cmd line installers (where you usually have to type `y` a lot of times in order to accept the default values) and similar boring operations.  

So, for example if you go with:  

```bash
$> yes test
```

it keeps on printing the cmd line arguments followed by a new line character (`CTRL+C` to stop execution):  

```bash
test
test
test
[...]
```

... and if you do not specify any argument, it just says:  

```bash
y
y
y
y
[...]
```

Yes, man! :-)