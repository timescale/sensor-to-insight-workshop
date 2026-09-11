#!/usr/bin/env bash
#
# Runs once, when the codespace is first created.
#
# Installs the Tiger CLI and nothing else. Every SQL statement in this workshop
# runs through `tiger db query`, so there's no psql and no database driver to
# install.

set -euo pipefail

echo "==> Installing Tiger CLI"
# INSTALL_DIR is honoured by the install script, so the binary lands on PATH for
# every shell. The alternative -- installing to ~/bin and symlinking afterwards --
# works, but only because Debian's .profile happens to add ~/bin in a login shell.
curl -fsSL https://cli.tigerdata.com | sudo INSTALL_DIR=/usr/local/bin sh

echo "==> Configuring Tiger CLI credential storage"
# There is no keyring in a container -- no gnome-keyring, no dbus, nothing for the
# default backend to write to. Without this, `tiger auth login` reports success and
# then every later command fails to read the credentials back. It is the single
# most common way this setup breaks.
tiger config set password_storage pgpass

cat <<'BANNER'

  ────────────────────────────────────────────────────────────────
   Sensor to Insight — container ready

   Installed: tiger

   Next, from this terminal:
       tiger auth login --headless
       tiger service create --name iot-workshop --cpu 500 --memory 2

   That sets the new service as your default, so every later
   `tiger db query` command needs no service ID.
  ────────────────────────────────────────────────────────────────

BANNER
