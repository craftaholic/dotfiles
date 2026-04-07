FROM debian:stable-slim

ENV DEBIAN_FRONTEND=noninteractive \
  PATH="/home/dev/.local/bin:${PATH}" 

ARG USER_NAME=dev \
  MISE_PATH="./.config/mise/config.toml"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  git \
  sudo \
  adduser \
  make \
  stow \
  curl \
  zsh \
  tmux \
  ca-certificates \
  gcc \
  g++ \
  && rm -rf /var/lib/apt/lists/*

RUN adduser $USER_NAME \
  && usermod -aG sudo $USER_NAME \
  && echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER_NAME

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/documents

# Install mise, a tool for managing multiple versions of Node.js
RUN curl https://mise.run | sh

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
