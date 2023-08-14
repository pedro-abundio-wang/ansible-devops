#!/bin/sh
set -e

# Ansible for Linux installation script.
#
# This script is intended as a convenient way to install Ansible.
#
# The script:
#
# - Requires `root` or `sudo` privileges to run.
# - Attempts to detect your Linux distribution and version and configure your package management system for you.
# - Installs dependencies and recommendations without asking for confirmation.
# - Installs the latest stable release (by default) of Ansible.
# - Isn't designed to upgrade an existing Ansible installation.
#
# Usage
# ==============================================================================
#
# To install the latest stable versions of Ansible, and their dependencies:
#
# 1. run the script with --dry-run to verify the steps it executes
#
#   $ sudo sh install.sh --dry-run
#
# 2. run the script either as root, or using sudo to perform the installation.
#
#   $ sudo sh install.sh
#
# ==============================================================================

while [ $# -gt 0 ]; do
  case "$1" in
  --dry-run)
    DRY_RUN=1
    ;;
  --*)
    echo "Illegal option $1"
    ;;
  esac
  shift $(($# > 0 ? 1 : 0))
done

command_exists() {
  command -v "$@" >/dev/null 2>&1
}

is_dry_run() {
  if [ -z "$DRY_RUN" ]; then
    return 1
  else
    return 0
  fi
}

deprecation_notice() {
  distro=$1
  distro_version=$2
  echo
  printf "\033[91;1mDEPRECATION WARNING\033[0m\n"
  printf "    This Linux distribution (\033[1m%s %s\033[0m) reached end-of-life and is no longer supported by this script.\n" "$distro" "$distro_version"
  printf "    No updates or security fixes will be released for this distribution, and users are recommended"
  printf "    to upgrade to a currently maintained version of %s." "$distro"
  echo
  printf "Press \033[1mCtrl+C\033[0m now to abort this script, or wait for the installation to continue."
  echo
  sleep 10
}

get_distribution() {
  lsb_dist=""
  # Every system that we officially support has /etc/os-release
  if [ -r /etc/os-release ]; then
    lsb_dist="$(. /etc/os-release && echo "$ID")"
  fi
  # Returning an empty string here should be alright since the
  # case statements don't act unless you provide an actual value
  echo "$lsb_dist"
}

do_install() {
  echo "# Executing ansible install script"

  if command_exists ansible; then
    cat >&2 <<-'EOF'
			Warning: the "ansible" command appears to already exist on this system.

			If you already have Ansible installed, this script can cause trouble, which is
			why we're displaying this warning and provide the opportunity to cancel the
			installation.

			If you installed the current Ansible package using this script and are using it
			again to install Ansible, you can safely ignore this message.

			You may press Ctrl+C now to abort this script.
		EOF
    (
      set -x
      sleep 10
    )
  fi

  user="$(id -un 2>/dev/null || true)"

  sh_c='sh -c'
  if [ "$user" != 'root' ]; then
    if command_exists sudo; then
      sh_c='sudo -E sh -c'
    else
      cat >&2 <<-'EOF'
			  Error: this installer needs the ability to run commands as root.
			  We are unable to find "sudo" available to make this happen.
			EOF
      exit 1
    fi
  fi

  if is_dry_run; then
    sh_c="echo"
  fi

  # perform some very rudimentary platform detection
  lsb_dist=$(get_distribution)

  case "$lsb_dist" in
  ubuntu)
    if command_exists lsb_release; then
      dist_version="$(lsb_release --codename | cut -f2)"
    fi
    if [ -z "$dist_version" ] && [ -r /etc/lsb-release ]; then
      dist_version="$(. /etc/lsb-release && echo "$DISTRIB_CODENAME")"
    fi
    ;;
  *)
    if command_exists lsb_release; then
      dist_version="$(lsb_release --release | cut -f2)"
    fi
    if [ -z "$dist_version" ] && [ -r /etc/os-release ]; then
      dist_version="$(. /etc/os-release && echo "$VERSION_ID")"
    fi
    ;;
  esac

  # Print deprecation warnings for distro versions that recently reached EOL,
  # but may still be commonly used (especially LTS versions).
  case "$lsb_dist.$dist_version" in
  ubuntu.xenial | ubuntu.trusty)
    deprecation_notice "$lsb_dist" "$dist_version"
    ;;
  ubuntu.impish | ubuntu.hirsute | ubuntu.groovy | ubuntu.eoan | ubuntu.disco | ubuntu.cosmic)
    deprecation_notice "$lsb_dist" "$dist_version"
    ;;
  esac

  # Run setup for each distro accordingly
  case "$lsb_dist" in
  ubuntu)
    (
      if ! is_dry_run; then
        set -x
      fi
      $sh_c 'apt-get update -qq >/dev/null'
    )
    (
      pkgs="software-properties-common ansible"
      if ! is_dry_run; then
        set -x
      fi
      $sh_c "DEBIAN_FRONTEND=noninteractive apt-get install -y -qq $pkgs >/dev/null"
    )
    ;;
  *)
    echo
    echo "ERROR: Unsupported distribution '$lsb_dist'"
    echo
    exit 1
    ;;
  esac
}

# wrapped up in a function so that we have some protection against only getting
# half the file during "curl | sh"
do_install
