Title: Zero downtime - Hot code deployments
Date: 2016-10-25 14:00
Category: Devops
Tags: Python, webapps, webserver, software, deployment, Django, Docker, Gunicorn
Slug: zero-downtime-hot-code-deployments
Authors: csparpa
Summary: You can reach almost zero downtimes when deploying web apps thanks to a few tricks


If you're reading this, probably you've asked yourself this question many times:

> How can I minimize (ideally, avoid) downtimes when I deploy my web application?

There are multiple ways to accomplish this task, depending on what type of computing infrastructure you use and what your technology stack is.

In this post, we're going to talk about **hot code reload**: this means that you have an already running codebase and you reload modifications to that codebase on the fly - that is, without downtime.

In the past, I've worked on a high-traffic HTTP API backend that had to be released with almost no downtime, and I instrumented the deployment process to leverage hot code reload, so I want to share with you my experience with this technique.

## Requirements for hot code reload
We need our web runtime environment to support a _hot_ reloading, which means that we don't want to stop the environment and launch it again, this is because we don't obviously want to have downtimes in our website/API/whatever.

Also, we need it to support a _graceful_ code reloading, meaning that any requests currently being serviced when the reload happens must be completed and during the reload operation no further requests must be accepted.

Some modern runtimes natively support hot reloading, but this is technology-dependent. The goal can be accomplished by simply relying on what we already have on our *nix boxes: _POSIX process signals_, specifically, the *`SIGHUP`* one.

[This Stackoverflow answer](http://unix.stackexchange.com/a/15606) clarifies very well the situation: the `HUP` signal was originally meant to be used to notify detached background processes to exit whenever users lost their
terminal/frontend counterparts - but this is not the case for daemon-only processes like our web runtime environments. So these processes are free to implement the handling of the `HUP` signal as they want, and the generally accepted idea is to have it trigger a _reload configuration files and/or code_.

Say that our runtime has master process ID of `$PID`, then:

```shell
$ kill -HUP $PID
```

is a "portable" way to reload configuration/code changes in a graceful way (in a pre-fork model, this means that the process handles worker processes' lifecycle) and without compromising uptime too much.

For instance, [this is what happens with Gunicorn](http://docs.gunicorn.org/en/stable/signals.html#master-process) when SIGHUP is received.

More application runtimes supporting hot code reload are: Unicorn (Ruby), Nodemon (Javascript), Gin (Go), etc.. Also popular webservers such as Nginx and Apache Httpd support hot configuration reload.


## A sample webapp
Let's get our hands dirty with code, now!

For the sake of concreteness, we will use a sample Python webapp powered by the following techs:

  - Python 3.5
  - Gunicorn 19.6 as a web runtime environment (WSGI), running Gevent 1.1.2 workers
  - Django 1.10 as a web framework
  - Docker 1.12 as a containerization platform

You can find [the code on Github](https://github.com/csparpa/blog-zero-downtime.git)

## Operate the sample app
Start with Git-cloning the app, say, into folder `$SAMPLE_APP`. Now, you can run the app in a Docker container or natively on your host.

Both scenarios rely on the `run.bash` script that is basically a shell wrapper launching Gunicorn in daemon mode and saving its PID into a file. This is
important as we will use it later to send a `HUP` signal to the Gunicorn process.

Code reload will be performed by the `reload.sh` script, that basically calls
`kill -HUP` on the running Gunicorn process.


### Run natively
If you *do not want to use Docker*, then I suggest you to install the app's dependencies under a [virtualenv](https://virtualenv.pypa.io) so that you don't pollute your local host's `PYTHONPATH`. Once inside the virtualenv, install the dependencies and run the app with:

```shell
$ pip install -r requirements.txt
$ bash run.sh
```

Keep this terminal open for the moment. Open a new terminal and check that the app is running like this:

```shell
$ curl http://localhost:1234/ping
{"message": "test"}
```

In the same terminal, run the polling client with:

```shell
$ python3.5 poll.py
UP: response was {'message': 'test'} [2016-10-25 13:57:35.414]
UP: response was {'message': 'test'} [2016-10-25 13:57:35.578]
UP: response was {'message': 'test'} [2016-10-25 13:57:35.914]
```

Keep it running.

The client polls the `/ping` endpoint for data and prints responses on screen.

The timestamp refers to the moment when the HTTP request has been issued to the server: a default timeout of 0.1 seconds is considered for responses.
So, if any request takes more than 0.1 seconds to be fulfilled, we consider our app to be down.

If you see green then the server is up, if you see red then the server is down and if you see yellow then the server is up and a change in the response body has been detected: this will happen once we hot reload the code.

Open the file `$PYTHONPATH/hot_code_reload/views.py` and modify the `message` value in the dictionary that is returned by the endpoint, i.e. put `abcd`:

```python
class PingView(View):

    def get(self, request):
        data = {
            "message": EXPECTED_MESSAGE_VALUE,  # <----
        }
        return HttpResponse(json.dumps(data), content_type="application/json")
```

Save, go back to the first terminal and perform the actual hot code reload magic with:

```shell
$ bash reload.sh
```

Now take a look at the second terminal, you should see something like this:

```shell
UP: response was {'message': 'test'} [2016-10-25 08:16:17.860]
UP: response was {'message': 'test'} [2016-10-25 08:16:17.872]
DOWN [2016-10-25 08:16:17.882]
DOWN [2016-10-25 08:16:17.990]
DOWN [2016-10-25 08:16:18.095]
UP AND CHANGED: response was {'message': 'abcd'} [2016-10-25 08:16:18.204]
UP: response was {'message': 'abcd'} [2016-10-25 08:16:18.254]
UP: response was {'message': 'abcd'} [2016-10-25 08:16:18.266]
```

As you can see from the printed timestamps, it looks like the reload took less than 1 second - that's a very short downtime!

### Run using Docker
We can perform hot code reload on dockerized applications by mounting its source code as a _container volume_ and - after code changes - by issuing a `SIGHUP` with the `docker exec` subcommand.

That's how to do it:

```shell
$ docker run -d \
    --name test_hcr \
    -v $SAMPLE_APP:/hcr \
    -p 0.0.0.0:1234:8000 \
    python:3.5 \
    tailf /dev/null
```

This command
  - creates a non-interactive container named `test_hcr` from Python3.5 official image (it will be downloaded from DockerHub if you don't already have it on your host)
  - mounts host folder `$SAMPLE_APP` to container folder `/hcr`
  - maps container port 8000 to host port 1234

Good, now let's install the Python dependencies on the container and start our app (I'm not doing this in a Dockerfile on purpose...):

```shell
$ docker exec -it test_hcr pip3 install -r /hcr/requirements.txt
$ docker exec -it hcr bash -c 'cd /hcr && bash run.sh'
```

and test it's online with:

```shell
$ curl http://localhost:1234/ping
{"message": "test"}
```

Cool! The next steps are exactly the same as in the case of non-containerized apps: open a new terminal an run the polling client.

Now modify the source code in order to return a different message, and then cast the hot code reload magic with:

```shell
docker exec -it hcr bash -c 'cd /hcr && bash reload.sh'
```

Now look back in the other terminal, you should see the output as described in the section about non-containerised apps.

As you can notice, *we did not stop the container*, nor we stopped Gunicorn running inside of it!


## Deploying code changes and/or environment changes
What are the pros/cons of mounting your application source code as a Docker volume? As said, no need to restart your container when you want to ship code changes to production. However, your code lives outside your Docker containers and is therefore subject to accidental or intentional modifications (typical risk: fixing a bug on production environment by patching the mounted code and restart it on-the-fly!).

> But what if I need to also ship environment (read: Dockerfile) changes to production?
> And what if I need to ship _only infrastructure changes?


In such cases, you are forced to ship a new Docker image to production and mounting code volumes becomes pointless if you need to also ship images provided that you embed your source code inside the new Docker image every time you build it.
The frequency of code vs infrastructure changes of course depends on your
needs, but usually one delivers more software than software dependencies... so hot code reload still has the chances to be useful.

I would suggest not to pack your source code into the Docker image on new deployments, because the release of code-only changes means the unneeded generation of a new Docker image - which has nothing different in terms of "environment" things!

**If you have a Continuous Deployment pipeline, you can instrument it so that**:
  - everytime a change in your Dockerfile is detected, a new Docker image is build and deployed, without deploying any code
  - everytime a change in your source code is detected, no new Docker images are built and your deployment only consists in hot code reload across all your codebase running instances


## References

  - I was greatly inspired by [this brilliant blog post by the Ionic team](
[http://blog.ionic.io/docker-hot-code-deploys/): it helped me a lot! Thanks guys!
  - For Gunicorn pros, take a look at the documentation about [signal handling with Gunicorn](http://docs.gunicorn.org/en/stable/signals.html)
