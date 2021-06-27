---
author: "Dennis Lee"
title: "Installing Minikube on Ubuntu with Windows Subsystem Linux Backend"
date: "Tue, 15 Jun 2021 12:00:06 +0800"
description: "minikube is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes. 
Why write an article on installing minikube on Ubuntu with WSL 2 backend? There are two reasons:"
draft: false
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
tags:
- minikube
- kubernetes
- wsl
---

**minikube** is local Kubernetes, focusing on making it easy to learn and develop for Kubernetes.

Why write an article on installing minikube on **Ubuntu** with **Windows Subsystem Linux** (WSL) 2 backend? There are two reasons:

* the official minikube site has documentation for installing on Windows, Linux, and macOS, but not on Ubuntu with WSL 2 backend.

* compared to the macOS or Linux, the installation process on Ubuntu with WSL 2 backend is not a trivial task.

## Preparing your Windows 10 machine

What you'll need:
* 2 CPUs or more
* 2Gb of free memory
* 20Gb of free disk space
* Internet connection
* Windows Subsystem Linux ["WSL"] 2
  
> You can install WSL 2 by following this article [Install WSL on Windows 10](https://docs.microsoft.com/en-us/windows/wsl/install-win10)

* Ubuntu 18.04+

> You can install Ubuntu on WSL 2 by following this article [Ubuntu on WSL 2 Is Generally Available](https://ubuntu.com/blog/ubuntu-on-wsl-2-is-generally-available)

* Container or virtual machine manager

> All you need is Docker (or similarly compatible) container or a Virtual Machine environment, and Kubernetes is a single command away: `minikube start`. You can install Docker Desktop for Windows by following this article [Docker Desktop WSL 2 backend](https://docs.docker.com/docker-for-windows/wsl)

## Installing minikube on Ubuntu 18.04 with Windows Subsystem Linux 2 backend

Download and install the latest minikube package for Ubuntu.

```sh
curl -LO https://storage.googleapis.com/minikube/releases/latest/minikube_latest_amd64.deb
sudo dpkg -i minikube_latest_amd64.deb
```

## Configuring VM driver

As we're on a virtual machine, we should set VM driver to none, as we cannot virtualize on virtualization.

```sh
sudo minikube config set vm-driver none
```

You should see the following output, which you can ignore as we don't have minikube running yet.

```sh
These changes will take effect upon a minikube delete and then a minikube start
```

## Changing permissions

First, change permissions for your `$USER` to the `.minikube` directory.

```sh
sudo chown -R $USER $HOME/.minikube
sudo chmod -R u+wrx $HOME/.minikube
```

## Installing package dependencies

Ensure that the following packages are installed.

```sh
sudo apt-get install -y conntrack
```

## Deleting previous minikube profiles

Check if an existing profile exists using `sudo minikube profile list`. Delete all existing profiles.

```sh
sudo minikube delete --purge=true --all=true
```

## Starting minikube

Finally, start `minikube` using the following command **without** `sudo` privileges:

```sh
minikube start --driver=docker --delete-on-failure
```

_Warning: The option `--driver=none` should not be used in Windows._

A successful output should have the following:

```sh
😄  minikube v1.20.0 on Ubuntu 18.04
✨  Using the docker driver based on user configuration
👍  Starting control plane node minikube in cluster minikube
🚜  Pulling base image ...
💾  Downloading Kubernetes v1.20.2 preload ...
    > preloaded-images-k8s-v10-v1...: 491.71 MiB / 491.71 MiB  100.00% 7.71 MiB
    > gcr.io/k8s-minikube/kicbase...: 358.09 MiB / 358.10 MiB  100.00% 5.30 MiB
    > gcr.io/k8s-minikube/kicbase...: 358.10 MiB / 358.10 MiB  100.00% 5.90 MiB
🔥  Creating docker container (CPUs=2, Memory=2200MB) ...
🐳  Preparing Kubernetes v1.20.2 on Docker 20.10.6 ...
    ▪ Generating certificates and keys ...
    ▪ Booting up control plane ...
    ▪ Configuring RBAC rules ...
🔎  Verifying Kubernetes components...
    ▪ Using image gcr.io/k8s-minikube/storage-provisioner:v5
🌟  Enabled addons: storage-provisioner, default-storageclass
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

## Troubleshooting

1. If you get the following error on `sudo minikube start`:

```sh
Exiting due to GUEST_MISSING_CONNTRACK: Sorry, Kubernetes 1.20.2 requires conntrack to be installed in root's path
```

The following command should resolve the above issue:

```sh
sudo apt-get install -y conntrack
```

2. If you get the following error on `sudo minikube start --driver=docker`:

```sh
Exiting due to DRV_AS_ROOT: The "docker" driver should not be used with root privileges.
```

You should perform `minikube start --driver=docker` without `sudo` privilege.

3. If you get the following error on `minikube start --driver=docker`:

```sh
Exiting due to HOST_HOME_PERMISSION: Failed to save config: open /home/dennislwm/.minikube/profiles/minikube/config.json: permission denied
```

The following command should resolve the above issue:

```sh
sudo chown -R $USER $HOME/.minikube; chmod -R u+wrx $HOME/.minikube
```

4. If you get the following error on `sudo minikube start --driver=docker`:

```sh
Exiting due to GUEST_DRIVER_MISMATCH: The existing "minikube" cluster was created using the "none" driver, which is incompatible with requested "docker" driver.
```

Check if an existing profile exists using `sudo minikube profile list`. The following command should resolve the above issue:

```sh
sudo minikube delete --purge=true --all=true
```

* * *

**Was this article useful? Help us to improve!**

_With your feedback, we can improve the newsletter. Click on a link to vote: 🗳️_

* [👍 Thanks - this issue helped me.](https://feedletter.co/feedback/give/1/98147649-0679-4569-9815-2460979f69be) 
* [😐 Meh - was ok.](https://feedletter.co/feedback/give/2/98147649-0679-4569-9815-2460979f69be)
* [👎 Not interesting to me.](https://feedletter.co/feedback/give/3/98147649-0679-4569-9815-2460979f69be)

[![Buy Me A Coffee donate button](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://ko-fi.com/dennislwm "Donate to this project using Buy Me A Coffee")
