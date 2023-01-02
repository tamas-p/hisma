Visma is visualizing Hisma state machines.

# Intro

This image provides the [visma](https://pub.dev/packages/visma) tool that renders hierarchical state machines created with the [hisma](https://pub.dev/packages/hisma) package to interactive state machine diagrams. It gets state machine status updates from its counterpart hisma monitor called [hisma_visual_monitor](https://pub.dev/packages/hisma_visual_monitor) and renders them to interactive web pages with the help of the [pumli](https://pub.dev/packages/pumli) package.

# Running visma

Visma can be started by the standard `docker run` command as shown in the examples bellow. Please note that the port
mapping `-p 127.0.0.1:4040:4040` is restricting the visma service to be accessible only from the localhost. If you want to enable access visma from remote hosts please remove 127.0.0.1 from the port mapping: `-p 4040:4040` (firewall rules of your machine might also need to be adjusted).

## Running in the foreground

This way visma will be running in the foreground and you will see the logs in the console and you can easily stop visma by pressing CTRL+C.

```
$ docker run -it -p 127.0.0.1:4040:4040 tamasp/visma
```

## Running as a daemon

This way visma will be running as a daemon in the background.

```
$ docker run -d -p 127.0.0.1:4040:4040 tamasp/visma
```

# Using visma

After you started visma with the previous docker run command you can simply access visma by opening
the http://127.0.0.1:4040/ URL. This will show in the web browser the state machine overview page similar to this:

![hisma_visual_monitor_domain.png](https://github.com/tamas-p/hisma/raw/master/packages/hisma_visual_monitor/doc/resources/hisma_visual_monitor_domain.png)

# More information

https://pub.dev/packages/visma
