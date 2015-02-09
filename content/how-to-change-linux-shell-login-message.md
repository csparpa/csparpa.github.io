Title: How to change Linux shell login message
Date: 2012-02-03 01:00
Category: Linux
Tags: Linux, shell
Slug: how-to-change-linux-shell-login-message
Authors: csparpa
Summary: Change the message appearing when you log into a shell

Your wish is to change that ugly message which is always appearing when you log into a shell (eg: bash) on your Linux system?  

Then, edit this file:  

```text
/etc/motd
```  

and everything you put into it will appear just after logging in.  

In order to disable login messages, simply make sure to add to file `/etc/ssh/sshd_config` the following line: 

```text
PrintMotd no
```  

The login message can also be dynamically generated... and in fact that's what actually happens in many systems (eg: my Ubuntu distro shows how many packages updates are available for downloading into the shell login message).  
In order to create dynamic login messages, I suggest to:

1. prepare a shell script that echoes the desired content for the login message
2. disable `motd` file printing at login
3. launch your script at any login by adding the its command-line to the `/etc/profile` script, which is a system-wide startup script