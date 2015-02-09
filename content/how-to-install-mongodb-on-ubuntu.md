Title: How to install MongoDB on Ubuntu
Date: 2012-07-09 01:00
Category: howtos
Tags: Linux, NoSQL, MongoDB, database, Ubuntu
Slug: how-to-install-mongodb-on-ubuntu
Authors: csparpa
Summary: How to install the MongoDB NoSQL datastore on Ubuntu distro

This is a quick-guide to install MongoDB on Ubuntu 12.04 (if you want to know how to install it also on Fedora Core 11, please check out one of my old posts.  

### Steps

Here is all you have to do:  

```bash
$> sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
$> sudo touch /etc/apt/sources.list.d/10gen.list
$> line="$(echo "deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen")"
$> sudo echo "$line" > /etc/apt/sources.list.d/10gen.list
$> sudo apt-get update
```

And then you can install MongoDB with:  

```bash
$> sudo apt-get install mongodb-10gen
```

Enjoy!