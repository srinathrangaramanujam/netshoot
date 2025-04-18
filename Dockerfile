FROM debian:stable-slim as fetcher
COPY build/fetch_binaries.sh /tmp/fetch_binaries.sh

RUN apt-get update && apt-get install -y \
  curl \
  wget \ 
  git \ 
  unzip

RUN /tmp/fetch_binaries.sh

FROM debian:stable-slim as final

RUN apt-get update && apt-get install -y \
    git \
    apache2-utils \
    bash \
    dnsutils \                     
    bird \
    bridge-utils \
    busybox \
    conntrack \
    curl \
    dhcping \
    dnsutils \                     
    ethtool \
    file \
    fping \
    iftop \
    iperf \
    iperf3 \
    iproute2 \
    ipset \
    iptables \
    iptraf-ng \
    iputils-ping \                
    ipvsadm \
    httpie \
    jq \
    liboping0 \
    ltrace \
    mtr \
    snmp \
    netcat-openbsd \
    nftables \
    ngrep \
    nmap \
    openssl \
    python3-pip \
    python3-setuptools \
    socat \
    speedtest-cli \
    openssh-client \
    strace \
    tcpdump \
    tcptraceroute \
    tshark \
    util-linux \
    vim \
    zsh \
    lsof \
    swaks \
    perl \
    libnet-ssleay-perl \
    libcrypt-ssleay-perl \
    zsh \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# # Installing ctop - top-like container monitor
COPY --from=fetcher /tmp/ctop /usr/local/bin/ctop

# # Installing calicoctl
COPY --from=fetcher /tmp/calicoctl /usr/local/bin/calicoctl

# Installing termshark
COPY --from=fetcher /tmp/termshark /usr/local/bin/termshark

# Installing grpcurl
COPY --from=fetcher /tmp/grpcurl /usr/local/bin/grpcurl

# Installing fortio
COPY --from=fetcher /tmp/fortio /usr/local/bin/fortio

#install websocat
COPY --from=fetcher /tmp/websocat /usr/local/bin/websocat
COPY --from=fetcher /tmp/crictl /usr/local/bin/crictl

# Setting User and Home
USER root
WORKDIR /root
ENV HOSTNAME netshoot

# ZSH Themes
RUN curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh | sh
RUN ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom} && \
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

RUN ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom} && \
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

COPY zshrc .zshrc
COPY motd motd

RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && unzip awscliv2.zip && ./aws/install && rm awscliv2.zip && rm -r aws

# Fix permissions for OpenShift and tshark
RUN chmod -R g=u /root
RUN chown root:root /usr/bin/dumpcap

# Running ZSH
CMD ["zsh"]
