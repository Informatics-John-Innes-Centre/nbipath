# Use Ubuntu 22.04 as a base
FROM ubuntu:22.04

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Install bash and basic utilities
RUN apt-get update && apt-get install -y \
    bash \
    coreutils \
    readline-common \
    && rm -rf /var/lib/apt/lists/*

# Copy the directory creation script and run it
COPY creating_paths.sh /tmp/
RUN bash /tmp/creating_paths.sh

# Copy game scripts into /usr/local/bin
COPY nbipath.sh install.sh uninstall.sh /usr/local/bin/

# Make scripts executable
RUN chmod +x /usr/local/bin/nbipath.sh \
    /usr/local/bin/install.sh \
    /usr/local/bin/uninstall.sh

# Set the working directory inside the container
WORKDIR /norwich

# Default command to run the game
ENTRYPOINT ["/usr/local/bin/nbipath.sh"]
