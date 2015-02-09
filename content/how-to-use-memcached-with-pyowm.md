Title: How to use Memcached with PyOWM
Date: 2013-12-13 01:00
Category: howtos
Tags: Python, GitHub, software, adapter, cache, Linux, Memcached, PyOWM
Slug: how-to-use-memcached-with-pyowm
Authors: csparpa
Summary: Quickly plug custom cache providers into the PyOWM library

This is just a little demonstration on how you can quickly change the basic cache provider provided by the [PyOWM library](https://github.com/csparpa/pyowm).  
For this purpose we'll use Memcached, which – simply put – is a key/value in-memory data store: this turns it into a perfect caching mechanism.

### Requirements
This demo requires that you work on a Linux env, as Memcached originally is shipped for Unix-like systems via packet distribution systems (but can nevertheless be compiled from source).  
I'll use Ubuntu, with Memcached 1.4.6 and PyOWM 0.4.0.  
Let's dive into it.  
First we install Memcached and the relative Python bindings:  

```bash
$> sudo apt-get install memcached python-memcache
```

Then we install PyOWM library and check the installation:  

```bash
sudo pip install pyowm
```

And we check then that library has correctly been installed by running from the Python console:

```python
>>> import pyowm
```

(if you don't get any error, then PyOWM was installed correctly).  

Finally, let's start Memcached:

```bash
$> memcached &
```

### Write the adapter
In order to "plug" Memcached support into PyOWM we are going to leverage the installed Python bindings by creating
an adapter class that can conform the SW interface that PyOWM expects into the Memcached API for getting/setting cache elements.  
Fortunately, the Memcached API is very close to the PyOWM expected interface (which is stated into the `pyowm.abstractions.owmcache.OWMCache` class), so we have chances
that our adapter will be simple enough.  
Let's name it `memcachedadapter.py`: you can put it anywhere, provided that this anywhere is "seen" by the Python intepreter: in example, you can put it into any folder
listed into the `PYTHONPATH` variable or you can place it directly into the PyOWM install folder.  
In my distro, Python packages are installed by `pip` into folder `/usr/local/lib/python2.6/dist-packages`, I'll put the file over there.  

Let's write the adapter:

```bash
$> cd /usr/local/lib/python2.6/dist-packages/pyowm
$> sudo vim memcachedadapter.py
```

The module will contain the `MemcachedAdapter` class:

```python
#!/usr/bin/env python
 
class MemcachedAdapter():
  """
  Realizes the pyowm.abstractions.owmcache.OWMCache interface
  adapting a memcache.Client object
  """
  
  __ITEM_LIFETIME_MILLISECONDS = 1000*60*10 # Ten minutes
 
  def __init__(self, hostname="127.0.0.1",
      port="11211", item_lifetime=__ITEM_LIFETIME_MILLISECONDS):
    from memcache import Client
    self._memcached = Client([hostname+":"+port])
    self._item_lifetime = item_lifetime
 
  def get(self, request_url):
    return self._memcached.get(request_url)
 
  def set(self, request_url, response_json):
    self._memcached.set(request_url, response_json, self._item_lifetime)
```

I wrote this adapter in 5 minutes, so please don't blame me for errors ;-) it can surely be improved.  

Now what is left to do is to tell the PyOWM library how to use the adapter: this is done via configuration. The library requires an `OWMCache`
concrete instance which is created into a configuration file and injected into the code.  

We have two options now:
1. create a new configuration file, instantiate the cache adapter in that and then use the configuration file as a parameter when instantiating the PyOM global object
2. patch the default configuraton file, commenting out the default cache object that is provided  

The first solution requires us to write a new configuration module. Say our module will be `pyowm.webapi25.mycustomconfig.py`: then you need
to copy/paste all of the config data from the default `pyowm.webapi25.configuration25.py` configuration module, and then patch the
line where the default cache object is provided:

```python
# Cache provider to be used
# cache = NullCache()  # default cache provided by PyOWM: comment out
from memcachedadapter import MemcachedAdapter  # instantiate our adapter
cache = MemcachedAdapter("127.0.0.1", "11211")
```

Then you need to instantiate the PyOWM object by explicitly setting the path to our custom configuration module:

```python
>>> from pyowm import OWM
>>> owm = OWM(config_module='pyowm.webapi25.mycustomconfig')
```

The second solution is more of a hack and requires us to open module `pyowm.webapi25.configuration25.py` and do the same make up as above.
Once done, you can finally create the main PyOWM object without specifying any custom configuration module:  

```python
>>> from pyowm import OWM
>>> owm = OWM()
```

### See it in action
In the above examples, we are adapting a local Memcached instance listening on the default 11211 port, but you can change this configuration as needed.  
Now let's try it out:

```python
>>> not_cached = owm.daily_forecast("London,uk")  # This first call to the API is not cached, obviously
>>> cached = owm.daily_forecast("London,uk")      # This second call is cached
```  

Time saving should be at a glance!

### More cache adapters for PyOWM
In a similar way it is possible to write adapters for plugging other cache/storage providers (Redis, MongoDB, etc..) into the PyOWM library.  

This post stimulated me to write more adapters, you can find them [on my GitHub repo](https://github.com/csparpa/pyowm-cache-adapters).