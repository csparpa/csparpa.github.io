Title: Zero downtime - Hot code deployments with Docker
Date: 2016-10-13 14:00
Category: Devops
Tags: Python, webapps, webserver, software, deployment, Django, Docker
Slug: zero-downtime-hot-code-deployments-with-docker
Authors: csparpa
Summary: Docker-based apps can reach almost zero downtimes upon automated deployments thanks to a few tricks


This is the first of a series of posts about a hot Devops topic - the answer to the question:

> How can I minimize (ideally, avoid) downtimes when I deploy my application?

There are many ways to accomplish this task.

In this post, we're going to talk about **hot code reload** using a sample
Python webapp powered by the following techs:

  - Gunicorn as a web runtime environment (WSGI)
  - Django as a web framework
  - Docker as a containerization platform
  - Fabric as a deployment tool

I've worked on a real-life high-traffic API backend that had to be released with almost no downtime, and I want to share with you the steps I underwent to make it deployable in a predictable, automated and *quick* manner!

## The test webapp
TBD

## Servers supporting hot code reload
TBD

## Scenarios: containerized apps vs installed apps
TBD

## Scenarios: deploying infrastructure changes vs deploying code changes
TBD

## Automate it
TBD

## References
I was greatly inspired by [this brilliant blog post by the Ionic team](
[http://blog.ionic.io/docker-hot-code-deploys/): it helped me a lot! Thanks guys!