FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
  PATH="/home/dev/.local/bin:${PATH}" 

ARG USER_NAME=dev \
  MISE_PATH="./.config/mise/config.toml"

ARG GIT_VERSION=1:2.47.3-0+deb13u1 \
  SUDO_VERSION=1.9.16p2-3+deb13u2 \
  ADDUSER_VERSION=3.152 \
  MAKE_VERSION=4.4.1-2 \
  STOW_VERSION=2.4.1-2 \
  CURL_VERSION=8.14.1-2+deb13u3 \
  ZSH_VERSION=5.9-8+b23 \
  TMUX_VERSION=3.5a-3 \
  CA_CERTIFICATES_VERSION=20250419 \
  GCC_VERSION=4:14.2.0-1 \
  GPP_VERSION=4:14.2.0-1 \
  UNZIP_VERSION=6.0-29

ARG MISE_VERSION=2026.5.12

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  git=${GIT_VERSION} \
  sudo=${SUDO_VERSION} \
  adduser=${ADDUSER_VERSION} \
  make=${MAKE_VERSION} \
  stow=${STOW_VERSION} \
  curl=${CURL_VERSION} \
  zsh=${ZSH_VERSION} \
  tmux=${TMUX_VERSION} \
  ca-certificates=${CA_CERTIFICATES_VERSION} \
  gcc=${GCC_VERSION} \
  g++=${GPP_VERSION} \
  unzip=${UNZIP_VERSION} \
  && apt-get upgrade -y --no-install-recommends \
  && rm -rf /var/lib/apt/lists/*

RUN adduser --disabled-password --gecos "" $USER_NAME \
  && usermod -aG sudo $USER_NAME \
  && echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER_NAME

RUN curl https://mise.run | MISE_INSTALL_PATH=/usr/local/bin/mise MISE_VERSION=${MISE_VERSION} sh;

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/documents

# ✅ Copy ONLY the lockfiles/configs first — cache busts only when these change
COPY --chown=${USER_NAME}:${USER_NAME} ./packages/${MISE_PATH} /home/${USER_NAME}/${MISE_PATH}
RUN --mount=type=secret,id=github_token,uid=1000 \
  if [ -f /run/secrets/github_token ]; then \
    export GITHUB_TOKEN=$(cat /run/secrets/github_token); \
  fi && \
  mise install -y && \
  rm -rf /home/${USER_NAME}/${MISE_PATH} && \
  rm -rf /home/${USER_NAME}/.zshrc

COPY --chown=${USER_NAME}:${USER_NAME} . dotfiles/

# Copy dotfiles and set up the environment
RUN cd dotfiles \
  && make copydotfiles

# Pre-install Neovim plugins and treesitter parsers
RUN export PATH="/home/${USER_NAME}/.local/share/mise/shims:$PATH" && \
  nvim --headless "+Lazy! install" +qa && \
  timeout 60 nvim --headless -c "TSUpdate" 2>&1 || true

ENTRYPOINT ["/bin/zsh"]
