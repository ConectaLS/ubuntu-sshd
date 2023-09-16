# Use an official Ubuntu base image
FROM ubuntu:22.04

# Define arguments and environment variables
ARG NGROK_TOKEN
ARG Password
ENV Password=${Password}
ENV NGROK_TOKEN=${NGROK_TOKEN}

# Set environment variables to avoid interactive prompts during installation
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG en_US.utf8
# Create shell script
RUN echo "./ngrok config add-authtoken ${NGROK_TOKEN} &&" >>/kali.sh
RUN echo "./ngrok tcp 22 &>/dev/null &" >>/kali.sh


# Create directory for SSH daemon's runtime files
RUN apt update -y > /dev/null 2>&1 && apt upgrade -y > /dev/null 2>&1 && apt install locales -y \
&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8

RUN chmod 777 /kali.sh

# Expose port
EXPOSE 80 8888 8080 443 5130 5131 5132 5133 5134 5135 3306 22 5454 7100 7200 7300 7400 5000 53 

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
RUN echo '/etc/ssh/sshd \ -D' >>/kali.sh

# Create authorized_keys file if AUTHORIZED_KEYS is not empty, then start SSH server
CMD /kali.sh
