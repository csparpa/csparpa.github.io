Title: How to setup centralized logging on your Django apps using Logstash and Amazon EC2
Date: 2016-10-01 17:00
Category: howtos
Tags: Django, Python, Logstash, Elasticsearch, Kibana, logging, EC2, AWS, Docker, Docker-compose
Slug: django-centralized-logging-on-ec2-with-logstash
Authors: csparpa
Summary: Send your Django app logs to a centralized persistent collector offering graphical querying capabilities


This post is a step-by-step guide on how to realize a centralized logging
solution for your Django apps.

We will instrument an Amazon EC2 instance running Ubuntu 14.04 to collect logs
from a locally-running Django app through the use of the "ELK" stack, which includes
Logstash as a log aggregator, and Docker as a containerization platform.


Centralized logging
-------------------
Centralized logging is a monitoring technique that allows you to view all of your
applications' log messages on a single hub that acts as a collector and as unique
storage provider for them, and also gives you some degree of "log-browsability".

The centralized logging solution that we'll setup gives you the following
advantages:

  - the setup is very easily and quickly reproducible
  - logs from different hosts flow to a single collector host
  - logs are persisted by the collector: no more need to logrotate on the hosts
    (you can always do it as a backup strategy) and fault-tolerance
    in case of complete failure of the origin hosts
  - logs are saved almost in real-time
  - logs are saved along with metadata that allows you to query them (eg: filter
    them by timespan, by origin host, by words in the log content, etc..)
  - you get a nice web-based UI to browse/query the logs
  - depending on what your log messages contain, you might be able to track down
    the full track of a high-level that gets decomposed into multiple sub-requests
    flowing through many parts of a complex system (eg: a microservices based
    architecture) with only one query. This for example can be done if you put
    correlation IDs into your requests: then you query for those IDs.

And - as nothing comes completely free of charge, these are the cons:

  - the collector is a Single Point of Failure unless you provide load balancing
    for it
  - the collector could quickly get out of disk space, depending on how many
    hosts you collect from and the logs flow rate
  - log centralization relies on network efficiency: no network, no centralized
    logging - so you need to provide a local backup where to write your logs
    just in case.

It is worth mentioning that the solution we're going to provide can be
effectively used not only to track application-level logs but also to chunk and
collect system-level logs (eg: syslog, dmesg, etc..)

Logstash
--------
[Logstash](https://www.elastic.co/products/logstash) is the log aggregating
solution we're going to use. It is a daemon + command-line tool that just
accepts and stores all the log messages that you send it, but provides no way
of indexing and querying the logs. Furthermore, it comes without any graphical
user interface.

So if we want to effectively leverage Logstash we need to bind it with another
solution that allows to index and query for logs and possibly another solution
that allows us to do all of this in a human-friendly fashion.


Introducing the ELK stack
-------------------------
"ELK" is the short of [Elasticsearch](https://www.elastic.co/products/elasticsearch),
[Logstash](https://www.elastic.co/products/logstash) and [Kibana](https://www.elastic.co/products/kibana).
This application stack provides us exactly what we need:

  - *Logstash* - collects logs from hosts, these are handed over to...
  - *Elasticsearch* - indexes and stores logs, that can be seen using...
  - *Kibana* - a rich web-based user interface

Installing and configuring three different applications is too much, we'll
use a quicker solution: Docker. But first, let's setup our EC2 instance.

Steps
=====
<a name="#guide"></a>

Setup of EC2 instance
---------------------
When you setup the instance, make sure it instantiates Ubuntu 14.04 AMI and
mounts a good capacity volume (this depends on the logs frequency of course,
but I would advice at least 32 GB) and at least 2 GB of RAM (a t2.small could be
fine)

Install Docker 1.9 by running the following commands as root user:

    $ apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D
    $ echo "deb https://apt.dockerproject.org/repo ubuntu-trusty main" | sudo tee -a /etc/apt/sources.list.d/docker.list
    $ apt-get update
    $ apt-get install -y docker-engine python-pip
    $ usermod -aG docker ubuntu

Then logout and login again as user ubuntu.

Now install Docker-compose with the following commands:

    $ cd
    $ curl -L https://github.com/docker/compose/releases/download/1.5.2/docker-compose-`uname -s`-`uname -m` > $ /usr/local/bin/docker-compose
    $ chmod +x /usr/local/bin/docker-compose

Now you need to edit the security groups for your instance. We will need to
expose the following host ports to the machines that "produce" logs:

  - TCP 5000 (Logstash)
  - TCP 9200 (Elasticsearch REST JSON interface)
  - TCP 9300 (Elasticsearch transport protocol)

and the following port to the Internet (but be aware that our Kibana setup
won't provide any kind of authentication mechanism!):

  - TCP 5601 (Kibana web UI)

Also, you may want to assign a DNS name to the EC2 instance so you can
easily reach Kibana. Let's assume that you use `logs.mydomain.com`.

Moreover, the Django hosts will need to publish their logs to Logstash possibly
not through a public network. Encrypting logs is out of the scope of this tutorials:
as a security measure we can bind a private DNS name to the private IP of your
EC2 instance (you can use Route53 on AWS for that purpose) and have Django
publish logs on that name. Let's assume the private IP of our instance is:
`13.0.0.13`


Setup Docker containers for ELK applications
--------------------------------------------
As I told before, we want to leverage Docker to quickly spin-up our ELK stack.
I found a very good Github project by Anthony Lapenna: [docker-elk](https://github.com/deviantony/docker-elk),
it basically is an out-of-the-box setup (YML file) for Docker-compose to run
all the applications in the ELK stack, each one a separate Docker container.
Containers are instrumented so they can communicate and the one running Kibana
will get mapped to a public port of the EC2 host.

We can clone the repo with:

    $ cd
    $ git clone https://github.com/deviantony/docker-elk

In the repo you find subfolders for each ELK component, storing config files
that you can modify according to your needs.

Bringing up all the ELK stack is as simple as:

    $ cd docker-elk
    $ docker-compose up -d

After a while, you can test that the containers have been started:

    $ docker ps
    CONTAINER ID        IMAGE                  COMMAND                  CREATED             STATUS              PORTS                                             NAMES
    8f34a3f8d142        dockerelk_kibana       "/docker-entrypoint.s"   5 seconds ago       Up 2 seconds        0.0.0.0:5601->5601/tcp                            dockerelk_kibana_1
    d2530f2e0194        logstash:latest        "/docker-entrypoint.s"   8 seconds ago       Up 6 seconds        0.0.0.0:5000->5000/tcp                            dockerelk_logstash_1
    9c6580429bde        elasticsearch:latest   "/docker-entrypoint.s"   11 seconds ago      Up 9 seconds        0.0.0.0:9200->9200/tcp,  0.0.0.0:9300->9300/tcp   dockerelk_elasticsearch_1

You can test if Kibana is running by pointint your browers to:

     http://logs.mydomain.com:5601

As you see, using Docker-compose makes it really easy to spin up again the whole
stack just in case of errors. If you want to bring down the ELK stack, just do:

    $ docker-compose stop

from inside the `/home/ubuntu/docker-elk` folder.

    
Instrument Django to use centralized logging
--------------------------------------------
This will be very simple: we can use the `python-logstash` binding library developed
by [GitHub user vklochan](https://github.com/vklochan/python-logstash). This
library will tell Django to send logs also to Logstash via network, but it
needs a bit of configuration before.

Switch to the host (eg: localhost) where your Django setup is, then install the
library with:

    $ pip install python-logstash

Let us assume your Django app is named *myapp*. Open the `settings.py` file where
all the Django config settings live. You should spot a section about logging
(the `LOGGING` dict):

```
    LOGGING = {

        # Put here formatters, etc...

        'handlers': {
            'myhandler': {
                # Bla bla bla
            },
            'logstash': {
                'level': 'INFO',
                'class': 'logstash.TCPLogstashHandler',
                'host': '13.0.0.13',   # IP/name of our Logstash EC2 instance
                'port': 5000,
                'version': 1,
                'message_type': 'logstash',
                'fqdn': True,
                'tags': ['myapp'],
            }
        },
        'loggers': {
            'myapp': {
                'handlers': ['myhandler', 'logstash'],
                'level': 'INFO',
            }
        }
    }
```

The configuration is pretty straightforward to understand (for more info please
take a look at `python-logstash`'s' GitHub project wiki)

Now all you need to do is restart Django and take a look at Kibana if logs get tracked.

_Update_: at Jan 2016, `python-logstash` is still missing SSL support, but
this is notified as an issue on the GitHub project repository.


Further references
==================
[This](https://www.digitalocean.com/community/tutorials/how-to-install-elasticsearch-logstash-and-kibana-elk-stack-on-ubuntu-14-04)
guide can be useful to setup authentication on Kibana.

If you need a comprehensive reference to the ELK stack (eg: how to write custom
Logstash plugins or how build advanced queries and dashboards with Kibana) you
can read ["Learking ELK stack" by Packt Publishing](https://www.packtpub.com/big-data-and-business-intelligence/learning-elk-stack)