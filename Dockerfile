FROM debian:stable-slim

####################################################################
# DEVBOX TOOL INSTALLATION
####################################################################

# Optional arg to install custom devbox version
ARG DEVBOX_USE_VERSION

# Step 1: Installing dependencies
RUN apt-get update
RUN apt-get -y install bash binutils git xz-utils wget sudo

# Step 2: Prepare for Nix
ARG TARGETPLATFORM
RUN mkdir -p /etc/nix/
RUN if [ "$TARGETPLATFORM" = "linux/arm64" ] || [ "$TARGETPLATFORM" = "linux/arm64/v8" ]; then \
        echo "filter-syscalls = false" >> /etc/nix/nix.conf; \
    fi

# Step 3: Setting up devbox user
ENV USER_NAME=dev
RUN adduser $USER_NAME
RUN usermod -aG sudo $USER_NAME
RUN echo "${USER_NAME} ALL=(ALL:ALL) NOPASSWD: ALL" | sudo tee /etc/sudoers.d/$USER_NAME
USER $USER_NAME

# Step 4: Installing Nix
RUN wget --output-document=/dev/stdout https://nixos.org/nix/install | sh -s -- --no-daemon
RUN . ~/.nix-profile/etc/profile.d/nix.sh

ENV PATH="/home/${USER_NAME}/.nix-profile/bin:$PATH"

# Step 5: Installing devbox
ENV DEVBOX_USE_VERSION=$DEVBOX_USE_VERSION
RUN wget --quiet --output-document=/dev/stdout https://get.jetify.com/devbox   | bash -s -- -f
RUN chown -R "${USER_NAME}:${USER_NAME}" /usr/local/bin/devbox

####################################################################
# Image customization and dotfiles setup
####################################################################

ENV DEBIAN_FRONTEND=noninteractive \
  PATH="/home/dev/.local/bin:${PATH}" 

ARG DEVBOX_PATH="./.local/share/devbox/global/default/devbox.json" \
  MISE_PATH="./.config/mise/config.toml"

USER root

RUN apt-get update && apt-get install -y --no-install-recommends \
  make \
  stow \
  curl \
  zsh \
  tmux \
  ca-certificates \
  gcc \
  g++ \
  && rm -rf /var/lib/apt/lists/*

USER ${USER_NAME}
WORKDIR /home/${USER_NAME}/documents

# Install mise, a tool for managing multiple versions of Node.js
RUN curl https://mise.run | sh

# ✅ Copy ONLY the lockfiles/configs first — cache busts only when these change
COPY --chown=${USER_NAME}:${USER_NAME} ./packages/${DEVBOX_PATH} /home/${USER_NAME}/${DEVBOX_PATH}
RUN --mount=type=secret,id=github_token,uid=1000 \
  if [ -f /run/secrets/github_token ]; then \
    export GITHUB_TOKEN=$(cat /run/secrets/github_token); \
  fi && \
  devbox global install && \
  rm -rf /home/${USER_NAME}/${DEVBOX_PATH}

# ✅ Copy ONLY the lockfiles/configs first — cache busts only when these change
COPY --chown=${USER_NAME}:${USER_NAME} ./packages/${MISE_PATH} /home/${USER_NAME}/${MISE_PATH}
RUN --mount=type=secret,id=github_token,uid=1000 \
  if [ -f /run/secrets/github_token ]; then \
    export GITHUB_TOKEN=$(cat /run/secrets/github_token); \
  fi && \
  mise install -y && \
  rm -rf /home/${USER_NAME}/${MISE_PATH}

COPY --chown=${USER_NAME}:${USER_NAME} . dotfiles/

# Copy dotfiles and set up the environment
RUN cd dotfiles \
  && git config --global --add safe.directory /home/${USER_NAME}/dotfiles \
  && make copydotfiles

# Pre-install Neovim plugins and treesitter parsers
RUN export PATH="/home/${USER_NAME}/.local/share/mise/shims:$PATH" && \
  nvim --headless "+Lazy! install" +qa && \
  timeout 30 nvim --headless -c "TSUpdate" 2>&1 || true

ENTRYPOINT ["/bin/zsh"]
