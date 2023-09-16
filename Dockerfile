# Use an official Ubuntu base image
FROM ubuntu:22.04

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
# Define arguments and environment variables
ARG NGROK_TOKEN
ARG Password
ENV Password=${Password}
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Download and unzip ngrok
RUN wget -O ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.zip > /dev/null 2>&1
RUN unzip ngrok.zip

# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/ubu.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/ubu.sh

# Install OpenSSH server and clean up
RUN apt-get update \
    && apt-get install -y openssh-server \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Generate SSH keys (you can replace them with your own)
RUN mkdir /var/run/sshd \
    && sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin without-password/' /etc/ssh/sshd_config \
    && sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config \
    && ssh-keygen -A
RUN service ssh start
RUN chmod 777 /ubu.sh

# Expose port
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 22 5454 7100 7200 7300 7400 5000 53

# Create authorized_keys file if AUTHORIZED_KEYS is not empty, then start SSH server
CMD /bin/sh -c "[ -n \"$AUTHORIZED_KEYS\" ] && mkdir -p /root/.ssh && echo \"$AUTHORIZED_KEYS\" > /root/.ssh/authorized_keys; /usr/sbin/sshd -D"
CMD  /ubu.sh
