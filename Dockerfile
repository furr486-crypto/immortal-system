
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Asia/Jakarta
ENV IMMORTAL_MODE=ULTIMATE

# Install semua dependensi + tools hacking
RUN apt-get update && apt-get install -y \
    curl wget git sudo systemd cron \
    ca-certificates gnupg lsb-release \
    software-properties-common \
    openssh-server net-tools \
    python3 python3-pip python3-venv \
    jq unzip htop \
    docker.io docker-compose \
    && rm -rf /var/lib/apt/lists/*

# Install AI tools
RUN pip3 install flask numpy pandas scikit-learn tensorflow

# Install Docker
RUN curl -fsSL https://get.docker.com | bash && \
    usermod -aG docker root

# Setup SSH hardened
RUN mkdir /var/run/sshd && \
    echo 'root:ThaipuriKing2847' | chpasswd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Copy semua script
COPY *.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Copy cron
COPY cron-jobs /etc/cron.d/immortal
RUN chmod 0644 /etc/cron.d/immortal

EXPOSE 22 80 443 8080 2022 5000

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
