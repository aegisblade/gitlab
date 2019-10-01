<p align="center">
  <a href="https://www.aegisblade.com">
    <img src="https://www.aegisblade.com/images/BigCloud.png" alt="Logo" width="80">
  </a>

  <h3 align="center">AegisBlade Gitlab Setup</h3>

  <p align="center">
    <img src="https://img.shields.io/pypi/v/aegisblade" alt="pypi version" />
    <img src="https://img.shields.io/pypi/pyversions/aegisblade" alt="supported python versions" />
    <img src="https://img.shields.io/github/license/aegisblade/aegis-python" alt="license">
  </p>

  <p align="center">
    Single machine Gitlab site & CI setup in code.
    <br />
    <a href="https://www.aegisblade.com/docs"><strong>Read the docs »</strong></a>
    <br />
    <br />
    <a href="https://www.github.com/aegisblade/examples">Examples</a>
    ·
    <a href="https://www.aegisblade.com/account/register">Sign Up for an API Key</a>
    ·
    <a href="https://github.com/aegisblade/gitlab/issues">Report Bug</a>
  </p>
</p>

## Overview

This repo defines a setup for self-hosted Gitlab instance with a single CI runner inside of it's own virtual machine.

After setup, the Gitlab instance can be reached from the host machine only, on this url:
```
https://gitlab.local
```

This gitlab instance could easily be exposed to the outside web, but that configuration is outside the scope of this repo.

## Get Started

#### Install Prerequisites

 - [Docker](https://docs.docker.com/install/)
 - [docker-compose](https://docs.docker.com/compose/install/)
 - [Vagrant](https://www.vagrantup.com/docs/installation/)
 - [Virtualbox](https://www.virtualbox.org/wiki/Downloads)

#### Run the Gitlab Site
First, add the url mapping to your hosts file.

```bash
$ echo "172.28.1.1    gitlab.local" | sudo tee -a /etc/hosts
```

Then, generate the self-signed ssl certificates for the site.
```bash
$ ./genssl.sh
```

Finally, start up the Gitlab site instance.

```bash
$ docker-compose up -d
```

Gitlab will take a minute or so to boot up, then navigate to `https://gitlab.local`.

#### Setup a User and a Project

After navigating to `https://gitlab.local` ...

 - Accept the self-signed certificate warning.
 - Set an Admin Password.
 - Register a new user for yourself.

At this point you need to setup a group so you can obtain a registration token for the CI runner.

We recommend setting up a group rather than a project directly so the runner can be shared amongst different projects.

#### Obtain the Registration Token

[Find the registration token](https://docs.gitlab.com/ee/ci/runners/) for the group/project you created and copy it to your clipboard.

#### Start the CI Runner

Run the `start-runner.sh` script with the registration token to start the CI runner VM with Vagrant, and connect it to the Gitlab instance.

```bash
$ ./start-runner.sh MY_REGISTRATION_TOKEN
```

(of course, replace `MY_REGISTRATION_TOKEN` with your registration token.)

#### Notes on the CI Runner Configuration

The CI runner in this repo is configured so...

 - Each job is run in a `docker` container.
 - The VM's `docker` socket is mounted in every job, making `docker` available for use inside the job's container.
 - It can run up to 4 jobs concurrently.

#### Test the CI

Use this `.gitlab-ci.yml` file to test out the CI.

```
image: 'docker:latest'

my-ci-job:
  script:
    - docker run hello-world
```

## Subsequent Starts

After rebooting you can restart the site and runner with these simple commands.

```bash
$ docker-compose up -d
$ vagrant up
```

## Troubleshooting

#### Full VM Disk
Depending on your usage, the vm's disk can become full, and cause stuck CI builds or strange failures.

You can check disk usage with df:
```bash
$ vagrant ssh
$ df -h
```

If this is the issue, the solution is to clear space, or to remove the VM entirely, and make a new one.

```bash
$ vagrant destroy
$ ./start-runner.sh MY-REGISTRATION-TOKEN
```

## Check out AegisBlade

[AegisBlade is an Infrastructure as Code Platform](https://www.aegisblade.com) where you can deploy & run with a single function call.

## Contact

AegisBlade - [@aegisbladehq](https://twitter.com/aegisbladehq) - welovedevs@aegisblade.com

Project Link: [https://github.com/aegisblade/gitlab](https://github.com/aegisblade/gitlab)



