Title: How to install MongoDB on Fedora
Date: 2012-03-18 01:00
Category: howtos
Tags: Linux, NoSQL, MongoDB, database, Fedora
Slug: how-to-install-mongodb-on-fedora
Authors: csparpa
Summary: How to install the MongoDB NoSQL datastore on Fedora distro

During the last days, I've been delving into NoSQL datastores study and now I've got the chance to use MongoDB for a real-life need (of course, something relating to work issues). In order to reach my target, I needed a fresh installation of one of the most promising NoSQL technologies: the document-oriented datastore MongoDB.  

### Requirements
Here is how I managed to install MongoDB 2.0.3 on a Fedora Core 11 host. You can easily adapt the steps I went through to your operational environment.  

We're about to issue every command as `root` user.  

### Steps
First, I downloaded, extracted and placed the Mongo stuff (I didn't use the 10gen repo, but just a `tar.gz` from MongoDB website):  

```bash
$> cd /opt
$> wget http://fastdl.mongodb.org/linux/mongodb-linux-i686-2.0.3.tgz
$> tar xvf mongodb-linux-i686-2.0.3.tgz
$> mv mongodb-linux-i686-2.0.3.tg mongodb-2.0.3
```

I decided that my databases would go under `/usr/data/mongodb` and that MongoDB log file would be `/var/log/mongodb.log`

As I wanted my MongoDB server instance to be started/stopped as a demon, I prepared the following `init.d` script named `mongodb` and placed it under `/etc/init.d/`:

```bash
#!/bin/bash
source /etc/rc.d/init.d/functions
prog="mongod"
mongod="/opt/mongodb-2.0.3/bin/mongod"
RETVAL=0
 
start() {
  echo -n $"Starting $prog: "
  #This is the fundamental call to start the MongoDB server instance
  daemon $mongod "--fork --journal --dbpath /usr/data/mongodb \
  --logpath /var/log/mongodb.log \
  --logappend 2&gt;&amp;1 &gt;&gt;/var/log/mongodb.log"
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] &amp;&amp; touch /var/lock/subsys/$prog
  return $RETVAL
}
 
stop() {
  echo -n $"Stopping $prog: "
  killproc $prog
  RETVAL=$?
  echo
  [ $RETVAL -eq 0 ] &amp;&amp; rm -f /var/lock/subsys/$prog
  return $RETVAL
}
 
case "$1" in
 start)
  start
  ;;
 stop)
  stop
  ;;
 restart)
  stop
  start
  ;;
 status)
  status $mongod
  RETVAL=$?
  ;;
 *)
  echo $"Usage: $0 {start|stop|restart|status}"
  RETVAL=1
esac
 
exit $RETVAL
```

Then, I opened my Iptables firewall's `INPUT` chain so that port 27017 (the port MongoDB server is listening to) is not blocked: I opened the file `/etc/sysconfig/iptables` and added the following rule before of the `COMMIT` statement:  

```text
-A INPUT -p tcp -m tcp -m multiport --ports 27017 -j ACCEPT
```

and restarted iptables with:  

```bash
$> service iptables restart
```

That's it. Finally, I started the server instance with:  

```bash
$> service mongodb start
```

and tested the whole thing opening the Mongo Javascript shell like this:  

```bash
$> cd /opt/mongodb-2.0.3/bin
$> ./mongo
```

and everything was fine.