FROM ubuntu:22.04   

# Update OS and install Graphviz and Java plus cleanup.
RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt -y install graphviz && \
    apt -y install openjdk-8-jre-headless && \
    apt autoremove --yes && \
    apt clean && \
    rm -fr /var/lib/apt/lists/*

# Copy the plantuml jar.
COPY build/plantuml.jar /opt/visma/

# Copy the visma service itsef and its assets.
COPY assets/package_config.json /opt/visma/.dart_tool/ && \
    build/hisma/packages/visma/lib/src/visualizer/visual_monitor/page/ /opt/visma/lib/src/visualizer/visual_monitor/page/ && \
    build/visma /opt/visma/bin/

# Visma service listens on TCP port 4040. 
EXPOSE 4040

CMD ["/opt/visma/bin/visma", "--bind", "0.0.0.0", "--plantuml_jar", "/opt/visma/plantuml.jar"]