#!/bin/bash
# Workaround for Puppetcore not publishing /public/puppet8-release-trixie.deb.
# Trixie runtime packages exist in apt-puppetcore.puppet.com (verified via
# InRelease manifest: .refs/puppet8/puppet-agent_8.19.0-1trixie_amd64.deb etc.),
# but the unauthenticated bootstrap config-deb that install_shell.sh fetches
# does not. We install the bookworm bootstrap (which exists and just drops
# keyring + sources.list + auth.conf), then rewrite the codename so apt
# resolves against the host's actual suite.
#
# Remove this script and revert to litmus:install_agent once Puppetcore
# publishes puppet8-release-<codename>.deb to /public/ for trixie.
#
# Usage: install_puppetcore_agent.sh <collection> <forge_token>

set -euo pipefail

COLLECTION="${1:?collection arg required}"
TOKEN="${2:?forge token arg required}"

. /etc/os-release
case "${ID:-}" in debian|ubuntu) ;; *)
  echo "Unsupported OS for puppetcore bootstrap workaround: ID=${ID:-unknown}" >&2
  exit 2
  ;;
esac

export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends ca-certificates curl

curl -fsSL -o /tmp/puppet-release.deb \
  "https://apt-puppetcore.puppet.com/public/${COLLECTION/core/}-release-bookworm.deb"
dpkg -i /tmp/puppet-release.deb
rm -f /tmp/puppet-release.deb

sed -i "s/ bookworm / ${VERSION_CODENAME} /" \
  /etc/apt/sources.list.d/puppet8-release.list

auth_conf="/etc/apt/auth.conf.d/apt-puppetcore-puppet.conf"
sed -i '/^#\?login/d; /^#\?password/d' "$auth_conf"
printf 'login forge-key\npassword %s\n' "$TOKEN" >> "$auth_conf"
chmod 0600 "$auth_conf"

apt-get update
apt-get install -y puppet-agent

# Mirror puppet_litmus's configure_path: write /etc/environment so PAM exports
# /opt/puppetlabs/puppet/bin on subsequent SSH sessions. bolt run_command uses
# non-login shells where /etc/profile.d/puppet-agent.sh isn't sourced, so the
# downstream `puppet module install` step would otherwise not find the binary.
echo "PATH=$PATH:/opt/puppetlabs/puppet/bin" > /etc/environment

/opt/puppetlabs/bin/puppet --version
