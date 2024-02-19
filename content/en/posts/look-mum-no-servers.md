---
author: "Dennis Lee 👨"
title: "Look Mum, No Servers!"
date: "Fri, 16 Feb 2024 12:00:06 +0800"
description: "Look Mum, No Servers!: A Telegram bot to communicate with GitHub Actions"
draft: true
hideToc: false
enableToc: true
enableTocContent: true
authorEmoji: 👨
---

<!-- TOC depthfrom:2 -->

- [TL;DR](#tldr)
- [Prerequisites](#prerequisites)
  - [How to Create a New Telegram Bot](#how-to-create-a-new-telegram-bot)
- [From DevOps to BotOps](#from-devops-to-botops)
- [Steps to Configure Your Pipedream Workflow](#steps-to-configure-your-pipedream-workflow)
- [Conclusion](#conclusion)
- [Get the Source Code](#get-the-source-code)
- [What To Do Next](#what-to-do-next)

<!-- /TOC -->

---
## TL;DR

[Telegram](https://telegram.org) isn't just for sending and receiving chat messages. It's also for automating your dialog flow, including workflow.

Using a Telegram Bot gives you the ability to check prices, query status, solve puzzles, and even have a fun conversation.

And if you're a serious developer or engineer, you can create your own Telegram Bot to manage your servers, view user details, and open or close issues.

GitHub-Actions-Telegram-Bot is a Telegram bot that allow you to communicate with a GitHub Actions pipeline that may return an output message.

---
## Prerequisites

You'll need to create an account (no credit card required):
1. [Telegram](https://telegram.org)
2. [GitHub](https://github.com)
3. [Pipedream](https://pipedream.com)

---
### How to Create a New Telegram Bot

My previous article [Building a Telegram Chat with a MT4 Forex Trading Expert Advisor](https://dev.to/dennislwm/building-a-telegram-chat-with-a-mt4-forex-trading-expert-advisor-4p35) contains a prerequisite tutorial on [How to Create a New Telegram Bot](https://github.com/dennislwm/MT4-Telegram-Bot-Recon).

It is also worth checking out if you are a serious crypto or forex trader.

---
## From DevOps to BotOps

A [GitHub Actions](https://docs.github.com/en/actions/learn-github-actions/understanding-github-actions) is a continuous integration and continuous delivery (CI/CD) platform that allows you to automate your build, test, and deployment pipeline.

A typical workflow for a CI/CD pipeline is to make some changes to your repository files, then add and commit these file changes. The pipeline may trigger on a `push`, or any event types, that you have defined in a GitHub Actions config file.

In this article, instead of automating your build, test and deployment pipeline, you will have a bit of fun by creating a CI/CD pipeline to automate solving a sudoku puzzle and returning the result.

A typical workflow for a Telegram Bot is to send a command (prefix with a `/`). For example:

```sh
/solve PUZZLE_STRING
```

Then a webhook listens for this command and starts a chain of events, which includes automating the CI/CD pipeline. The result of the pipeline may be returned to the Telegram bot.

---
## Steps to Configure Your Pipedream Workflow

In order to create a webhook that listens for your Telegram bot commands, and starts a chain of events, which includes automating the CI/CD pipeline, you'll need to create a workflow in [Pipedream](http://pipedream.com).

Your TELEGRAM_BOT_TOKEN that you created in the [previous](#how-to-create-a-new-telegram-bot) section will come in handy here.

1. Navigate to your Pipedream dashboard > Projects.
2. Click New Project, and name the project **Telegram-Bot**.
3. Click Save, and your project should appear under Projects.
4. Click on your project name, navigate to Resources.
5. Click on New > Workflow, and name the workflow **Sudoku-Actions**.
6. Click Create Workflow, and your workflow should appear under Resources.

Now that you have created a workflow, let's create a trigger.

1. Click on your workflow name, and search for **Telegram** app.
2. Select Telegram Bot > **New Bot Command Received (Instant)**.
  - In the Telegram Bot Account, select **Connect new account**.
  - In token, enter your TELEGRAM_BOT_TOKEN.
  - In nickname, enter your Telegram bot name.
3. Click Save, and your telegram bot should appear under Telegram Bot Account.
4. Select Commands > and select one or more commands.

Now to test your first action, open your Telegram app and send a command from your Telegram bot.

![New Bot Command Received (Instant) from Telegram Bot](img)

Now that you have created a trigger, let's create some actions.

1. Click on the + icon (below your trigger), and search for **GitHub** app.
2. Select GitHub app, and search for **file contents**.
3. Select **Create or update file contents**.
  - In the GitHub Account, select **Connect new account**.
  - Follow the steps to connect your GitHub account.
4. Click Save, and your account should appear under GitHub Account.
5. Click Repository, search for and select **sudoku-cli**.
6. In Path, enter `puzzle.txt`.
7. Click File content, and search for and select **/solve**.
8. Click Test.

---
## Conclusion

---
## Get the Source Code


You can download the above source code from my GitHub repository [dennislwm/sudoku-cli](https://github.com/dennislwm/sudoku-cli).

---
## What To Do Next

You can further extend your code in several meaningful ways:

* * *

**Was this article useful? Help me to improve by replying in the comments.**

[![Buy Me A Coffee donate button](https://img.shields.io/badge/buy%20me%20a%20coffee-donate-yellow.svg)](https://ko-fi.com/dennislwm "Donate to this project using Buy Me A Coffee")
