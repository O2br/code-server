#!/bin/sh
set -eu

# This isn't set by default.
export USER="$(whoami)"

if [ "${DOCKER_USER-}" != "$USER" ]; then
  echo "$DOCKER_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null
  sudo usermod --login "$DOCKER_USER" \
    --home "/home/$DOCKER_USER" \
    coder
  sudo groupmod -n "$DOCKER_USER" coder

  # We cannot use usermod to do this as it uses mv which will
  # fail as files are open in $HOME. We have to copy.
  sudo cp -a "$HOME" "/home/$DOCKER_USER"
  export HOME="/home/$DOCKER_USER"
  export USER="$(whoami)"

  sudo sed -i "/coder/d" /etc/sudoers.d/nopasswd
  sudo sed -i "s/coder/$DOCKER_USER/g" /etc/fixuid/config.yml
fi

dumb-init fixuid -q /usr/bin/code-server "$@"
