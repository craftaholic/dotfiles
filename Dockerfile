FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    git \
    make \
    stow \
    curl \
    sudo \
    zsh \
    ca-certificates \
    && useradd -m -s /bin/zsh user \
    && echo "user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/user \
    && chmod 0440 /etc/sudoers.d/user \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/user/dotfiles

COPY --chown=user:user . .

USER user

RUN make setup \
    && cd /home/user \
    && rm -rf /home/user/dotfiles

WORKDIR /home/user

ENTRYPOINT ["/bin/zsh"]
