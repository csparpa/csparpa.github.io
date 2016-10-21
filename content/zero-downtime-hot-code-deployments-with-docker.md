Title: Zero downtime - Hot code deployments with Docker
Date: 2016-10-13 14:00
Category: Devops
Tags: Python, webapps, webserver, software, deployment, Django, Docker
Slug: zero-downtime-hot-code-deployments-with-docker
Authors: csparpa
Summary: Docker-based apps can reach almost zero downtimes upon automated deployments thanks to a few tricks


If you're reading this, probably you've asked yourself this question many times:

> How can I minimize (ideally, avoid) downtimes when I deploy my web application?

There are many ways to accomplish this task, depending on what type of computing infrastructure you use and what your technology stack is.

In this post, we're going to talk about **hot code reload**: this means that you have an already running codebase and you reload modifications to that codebase on the fly - that is, without downtime.

In the past, I've worked on a high-traffic HTTP API backend that had to be released with almost no downtime, and I instrumented the deployment process to leverage hot code reload, so I want to share with you my experience with this technique.

## Requirements for web runtime environments
Skip this paragraph if you are not interested in philosophical discussion.

We need our web runtime environment to support a _graceful_ code reloading, meaning that any requests currently being serviced when the reload happens must be completed and during the reload operation no requests must be accepted.

Also, we need a _hot_ reloading, which means that we don't want to stop the
environment and launch it again, this is because we don't obviously want to
have downtimes in our website/API/whatever.

Some modern runtimes natively support hot reloading, but this is technology-dependent. The goal can be accomplished by simply relying on what we already use: the **POSIX process signals**, specifically, the `SIGHUP` one.

[This Stackoverflow answer](http://unix.stackexchange.com/a/15606) clarifies very well the situation: the `HUP` signal was originally meant to be used to notify detached background processes to exit whenever users lost their
terminal/frontend counterparts - but this is not the case for daemon-only processes like our web runtime environments. So these processes are free to implement the handling of the `HUP` signal as they want, and the generally accepted idea is to _reload configuration files and/or code_.

Say that our runtime has master process ID of `$PID`, then:

```shell
$ kill -HUP $PID
```

is a "portable" way to reload configuration/code changes in a graceful way (in a pre-fork model, this means by handling the workers lifecycle) and without compromising uptime too much.

For instance, [this is what happens for Gunicorn](http://docs.gunicorn.org/en/stable/signals.html#master-process) when SIGHUP is received.

More application runtimes supporting hot code reload are: Unicorn (Ruby), Nodemon (Javascript), Gin (Go), etc..
Also popular webservers such as Nginx and ApacheHTTPD support hot configuration reload.


## A sample webapp
Let's get our hands dirty with code, now!

For the sake of concreteness, we will use a sample Python webapp powered by the following techs:

  - Python 3.5
  - Gunicorn 19.6 as a web runtime environment (WSGI), running Gevent 1.1.2 workers
  - Django 1.10 as a web framework
  - Docker 1.12 as a containerization platform

You can find the code on Github: **TOOOOBEEEEDOOOOONEEEEEE**

## Operate the sample app
Start with Git-cloning the app, say, into folder `$SAMPLE_APP`:

```shell
$ cd $SAMPLE_APP && git clone https://github.com/csparpa/blog-zero-downtime.git
```

and then you have the power: decide if run it under Docker or not.

### With Docker
If you choose to run the app inside a Docker container, then **TOOOOBEEEEDOOOOONEEEEEE**



### Without Docker
If you *do not want to use Docker*, then I suggest you to install the app's dependencies under a [virtualenv](https://virtualenv.pypa.io) so that you don't pollute your local host's `PYTHONPATH`. Once inside the virtualenv, install the dependencies and run it:

```shell
$ pip install -r requirements.txt
$ bash run.sh
```

Keep this terminal open for the moment. Open a new terminal and check that the app is running like this:

```shell
$ curl http://localhost:1234/ping
{"message": "hey!", "timestamp": 1477062924}
```

In the same terminal, run the polling client with:

```shell
$ python3.5 poll.py
UP: response was {'message': 'hey!', 'timestamp': 1477063514}
UP: response was {'message': 'hey!', 'timestamp': 1477063514}
UP: response was {'message': 'hey!', 'timestamp': 1477063515}
```

Keep it running. If you see green then the server is up, if you see red then the server is down and if you see yellow then the server is up and there has
been a change in the data returned by the `/ping` endpoint, and this will
happen once we hot reload the code.

Now open the file `$PYTHONPATH/hot_code_reload/views.py` and modify the `message` value in the dictionary that is returned by the endpoint - any string value different than the original one is OK

For instance:

```python
class PingView(View):

    def get(self, request):
        data = {
            "message": "changed",  # <----
            "timestamp": int(time.time())
        }
        return HttpResponse(json.dumps(data), content_type="application/json")
```

Save, go back to the first terminal and perform the actual hot code reload magic with:

```shell
bash reload.sh
```

Now take a look at the second terminal, you should see something like:

```shell
UP: response was {'timestamp': 1477064012, 'message': 'hey!'}
UP: response was {'timestamp': 1477064012, 'message': 'hey!'}
DOWN
DOWN
DOWN
DOWN
UP AND CHANGED: response was {'timestamp': 1477064013, 'message': 'changed'}
UP: response was {'timestamp': 1477064013, 'message': 'changed'}
UP: response was {'timestamp': 1477064013, 'message': 'changed'}
```

As you can see from the printed timestamps, it looks like the reload took 1 millisecond - that's a very short downtime.

Of course, if we deploy heavier changes to the codebase, then we could expect
a slightly longer downtime.

## Considerations: deploying infrastructure changes vs deploying code changes
TBD

## Automate deployments
TBD

## References

  - I was greatly inspired by [this brilliant blog post by the Ionic team](
[http://blog.ionic.io/docker-hot-code-deploys/): it helped me a lot! Thanks guys!
  - For Gunicorn pros, take a look at the documentation about [signal handling with Gunicorn](http://docs.gunicorn.org/en/stable/signals.html)
