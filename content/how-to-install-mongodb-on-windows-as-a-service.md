Title: How to install MongoDB on Windows as a service
Date: 2012-10-29 01:00
Category: howtos
Tags: software, NoSQL, database, Windows, MongoDB
Slug: how-to-install-mongodb-on-windows-as-a-service
Authors: csparpa
Summary: How to install the MongoDB NoSQL datastore on Windows as a system service

### Introduction
I’m showing you a quick procedure to install MongoDB as a service on Windows platforms (I simply gathered the hints explained in the [official documentation page](http://www.mongodb.org/display/DOCS/Windows) and adapted the whole stuff to my specific case).  

### Requirements
In my example, I’m installing MongoDB version 2.2.0 on a Windows Server 2003 R2 machine and my goal is to have it available as a service.  

### Steps
The procedure is pretty straightforward: all you need is to setup the path in which MongoDB will physically store the data collections, to provide a logfile for the service we’re going to create and finally to tell the `mongod` daemon to run as a service.  

Here we go (be sure to enclose all the paths in double quotes if they contain spaces):


1. Download the installation package (a .zip archive) and decompress it into folder `C:\mongodb-2.2.0`
 
2. Create the data path folders (in my example, `C:\mongodb-2.2.0\data\db`):

```text
C:\> md C:\mongodb-2.2.0\data
C:\> md C:\mongodb-2.2.0\data\db
C:\> set datapath = C:\mongodb-2.2.0\data\db
```
 
3. Setup mongod configuration file path (my file is `C:\mongodb-2.2.0\mongod.cfg`):
```text
C:\> set configpath = C:\mongodb-2.2.0\mongod.cfg
```

4. Create the folder that will host the service's log file (my folder is `C:\mongodb-2.2.0\log`) and write its path into the config file:
```text
C:\> md C:\mongodb-2.2.0\log
C:\> echo logpath = C:\mongodb-2.2.0\log\mongod.log > C:\mongodb-2.2.0\mongod.cfg
```

5. Install `mongod` as a service:
```text
C:\> C:\mongodb-2.2.0\bin\mongod.exe --config %configpath% --dbpath %dbpath% --install
```

Now you can start/stop/remove the MongoDB service via the services administration graphical interface, or via the command line using the following commands:

```text
:: Start service
C:\> net start MongoDB
 
:: Stop service
C:\> net stop MongoDB
 
:: Uninstall the service
C:\> C:\mongodb-2.2.0\bin\mongod.exe --remove
```

Wanna test out your installation? Just call the MongoDB Javascript shell:

```text
C:\> C:\mongodb-2.2.0\bin\mongo.exe
```

and if no error message appears – have fun!