Title: How to deploy Flask applications to Apache webserver
Date: 2013-03-06 01:00
Category: howtos
Tags: software, webserver, webapps, Python, Flask
Slug: how-to-deploy-flask-applications-to-apache-webserver
Authors: csparpa
Summary: How to deploy your Flask applications to WSGI-compatible webservers such as Apache

### Introduction
This is a simple guide explaining how I managed to configure Apache 2.2 httpd server on a Windows 2012 server platform so that it can serve a Python webapplication I wrote using the [Flask micro-framework](http://flask.pocoo.org/).  

The guide is valid, with a very little modification, also on Linux environments (you geeks know how to do)

### Why I needed to to this

I developed this application at work and I‘ve been serving it from the beginning via the Flask's built-in minimal webserver: unfortunately this  is not enough for production stage as I need a more robust server with SSL capabilities, which Flask's has not. This was my first time in deploying a Python webapp... So, after googling a bit and reading the [Flask deployment notes](http://flask.pocoo.org/docs/deploying/), I came up with the answer: what I needed was a WSGI-compliant server running on my target platform, a Windows 2012 server. The natural choice to me was to enable the WSGI module on the "good ole" Apache webserver, which I'm experienced with.

### Steps

#### 1. Flask app

We choose a folder in which we place the Python code. For instance,  

```cmd
D:\webapps\test
```

In this folder we create the real Flask webapplication that we want to deploy (file `test.py`):  

```python
# test.py
from flask import Flask, request
app = Flask(__name__)
 
@app.route('/hello')
def hello_world():
    name = request.args.get('name','')
    return 'Hello ' + name + '!'
if __name__ == '__main__':
    app.run()
```

The Apache server won't be aware of `test.py` at all. What you need to do now is to write in the same folder a Python file named `test.wsgi` that we will link into the webserver's configuration: the code in this file will import the main Flask application object (built in our case as a singleton) and will be actually executed by the WSGI module of Apache. In the code, it is vital that you DON'T change the name of the "application" variable, as it is exactly what the server expects to find. Also please note that we are extending the Python classes path to include our own webapplication's folder.  

This is `test.wsgi`:

```python
# test.wsgi
import sys
 
#Expand Python classes path with your app's path
sys.path.insert(0, "d:/webapps/test")
 
from test import app
 
#Put logging code (and imports) here ...
 
#Initialize WSGI app object
application = app
```

As an additional remark, if you want to put any logging code (e.g: file/e-mail/console loggers) into your Flask app, you must put it before the `if __name__ == ‘__main__'` block, otherwise it won't log anything! Add your loggers to the app object.  

More on this on the [Flask documentation](http://flask.pocoo.org/docs/0.10/api/#flask.Flask.logger)

#### 2. Apache setup

Ok, what's next? Now it's all about installing and properly configuring Apache.

First: install Apache webserver. I [downloaded](http://apache.panu.it//httpd/binaries/win32/httpd-2.2.22-win32-x86-openssl-0.9.8t.msi) and executed the .msi installer. Apache was installed at:

```text
"C:\Program Files (x86)\Apache Software Foundation\Apache2.2"
```

Second: install the WSGI Apache module. Pay attention to download the module compiled for your specific combination of platform and Python and Apache versions: I downloaded [this module](https://code.google.com/p/modwsgi/downloads/detail?name=mod_wsgi-win32-ap22py27-3.3.so). Once downloaded, rename the `.so` file into `mod_wsgi.so` and put it under the `modules` subfolder of your Apache installation folder. Then you have to tell Apache to use it: open in a text editor the `httpd.config` file which is under the `conf` subfolder and add the following line at the bottom:  

```text
LoadModule wsgi_module modules/mod_wsgi.so
```

Third: restart Apache.

Now Apache is ready to serve WSGI webapplications.  

What is left to do is to tell about where our application is and match it to a URL alias. It's child's play: open in a text editor the `httpd.config` file we used before and add these lines to the bottom:  

```text
<Directory d:/webapps/test>
    Order allow,deny
    Allow from all
</Directory>
WSGIScriptAlias /flasktest d:/webapps/test/test.wsgi
```

(nevertheless, I prefer to place the per-virtual-host or per-alias configurations' stuff into separate files and then use an Include directive into the main `httpd.conf`).  

Now restart Apache again and if you open a browser and point it to:

```text
http://localhost/flasktest/hello?name=claudio
```

and you should see the webapp's greetings!

### Further references
- [This guide](https://code.google.com/p/modwsgi/wiki/QuickConfigurationGuide) helped me a lot in understanding how to setup Apache WSGI.
- I also found [this tutorial](https://beagle.whoi.edu/redmine/projects/ibt/wiki/Deploying_Flask_Apps_with_Apache_and_Mod_WSGI?version=3) which is far more comprehensive than mine and covers Flask deployment on Apache on Debian/Ubuntu environments