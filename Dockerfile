FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
  PATH="/home/dev/.local/bin:${PATH}" 

ARG USER_NAME=dev \
  MISE_PATH="./.config/mise/config.toml"

ARG GIT_VERSION=1:2.39.5-0+deb12u1 \
  SUDO_VERSION=1.9.13p3-1+deb12u1 \
  ADDUSER_VERSION=3.134 \
  MAKE_VERSION=4.3-4.1 \
  STOW_VERSION=2.3.1-1 \
  CURL_VERSION=7.88.1-10+deb12u8 \
  ZSH_VERSION=5.9-4+deb12u1 \
  TMUX_VERSION=3.3a-3 \
  CA_CERTIFICATES_VERSION=20230311 \
  GCC_VERSION=4:12.2.0-3 \
  GPP_VERSION=4:12.2.0-3

ARG MISE_VERSION=2026.4.5

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
  && rm -rf /var/lib/apt/lists/*

RUN adduser $USER_NAME \
  && usermod -aG sudo $USER_NAME \
  && echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER_NAME

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/documents

# Install mise v2026.4.5, a tool for managing multiple versions of development tools
RUN curl -fsSL https://github.com/jdx/mise/releases/download/v${MISE_VERSION}/mise-v${MISE_VERSION}-linux-x64.tar.gz \
  | tar -xzC /tmp && \
  mv /tmp/mise/bin/mise /home/${USER_NAME}/.local/bin/mise && \
  chmod +x /home/${USER_NAME}/.local/bin/mise && \
  rm -rf /tmp/mise

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
