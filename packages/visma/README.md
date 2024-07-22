Visma is visualizing state machines.

This package provides a command line tool called `visma` that renders hierarchical state machines created with the [hisma](../hisma/) package to interactive state machine diagrams. It gets state machine status updates from its counterpart hisma monitor called [hisma_visual_monitor](../hisma_visual_monitor/) and renders them to interactive web pages with the help of the [pumli](https://github.com/tamas-p/pumli) package.

## Features

Visma tool can be accessed from a web browser, by default accessing it on port 4040: http://127.0.0.1:4040/

List of features visma provides:

### State machines overview page

![visma_overview.gif](doc/resources/visma_overview.gif)

### State machine pages

![visma.gif](doc/resources/visma.gif)

### Visma does not only monitor, you can also fire events from the visma ui:

![fb_auth_hisma_example.gif](../../examples/fb_auth_hisma_example/doc/resources/fb_auth_hisma_example.gif)

## Getting started

There are two different ways of running visma you can choose from:

- visma as a docker container
- visma as a command installed by _dart pub global activate_

Whatever method you use, when visma is running you can reach its user interface via
a web browser at http://127.0.0.1:4040 (if you go with the default port configuration).

### Running the visma docker image

This is arguably the simplest way to get visma up and running:

```
$ docker run -it -p 127.0.0.1:4040:4040 tamasp/visma
```

It will pull (1st time only) and run the visma docker image from Docker Hub.
This image contains visma and all its prerequisites (Java, Graphviz).

More information about the image and its usage is available at the [visma Docker Hub repository](https://hub.docker.com/r/tamasp/visma).

More information about docker is available at https://www.docker.com.

### Manual installation

Manual installation of visma itself is simple, but getting its prerequisites installed could take some valuable time from you. Nevertheless, this section describes the installation of the prerequisites and visma and also how you run visma with this approach.

#### Prerequisites

As stated in the first paragraph, visma is using PlantUML, hence PlantUML is a prerequisite for visma. See https://plantuml.com/starting for PlantUML installation details.

> **Important**
> As PlantUML can change their API anytime prefer using the well tested PlantUML [V1.2022.1](https://sourceforge.net/projects/plantuml/files/1.2022.1/) as described in [pumli](https://github.com/tamas-p/pumli) (visma internally uses the pumli package to render state machine diagrams).

#### Installing visma

If PlantUML and its prerequisites (Java, Graphviz) are installed you can install visma as follows:

```bash
$ dart pub global activate visma
```

#### Usage

First let's have an overview of the command line parameters of visma:

```
$ visma -h
A visualization server for Hisma the hierarchical state machine.
Without parameters it will try running the 'plantuml -picoweb' command as the renderer for visma.

Usage: visma [--bind=BIND] [--port=PORT] [--plantuml_public] | [--plantuml_url=URL] | [--plantuml_jar=JAR --plantuml_bind=BIND --plantuml_port=PORT] [--help]

Options:
-p, --port               Port of the visma service listening on.
-b, --bind               Specify bind address of the visma service.
    --plantuml_public    The public PlantUML service will be used as renderer.
    --plantuml_url       PlantUML service at this URL will be used to render.
    --plantuml_port      Port of the PlantUML renderer service that will be started.
    --plantuml_jar       Specify PlantUML jar location.
    --plantuml_bind      Specify bind address of the local PlantUML service to be started.
-h, --help               Shows this help.
```

#### Examples

##### Simple start from cmd, default parameters

```
$ visma
```

##### Start from cmd, using a specific plantuml jar

```
$ visma --plantuml_jar files/plantuml/plantuml.1.2022.1.jar
```

## Additional information

As stated in the first paragraph visma is getting its workload (state machine updates) from hisma_visual_monitor. Please check the [hisma_visual_monitor](https://pub.dev/packages/hisma_visual_monitor) package at pub.dev for instructions on how to use it in combination with your state machines and visma.

If you have any questions, comments please go to [Hisma GitHub Discussions](https://github.com/tamas-p/hisma/discussions) to start or join discussions.
