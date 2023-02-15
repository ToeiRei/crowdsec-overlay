#!/bin/bash

# A script for setting up Portage to use a given github overlay
# for us lazy people.

REPO_NAME="crowdsec-overlay" 
AUTHOR="crowdsec"
REPO_URL="https://github.com/${AUTHOR}/${REPO_NAME}"
OVERLAY_DIR="/var/db/repos/${REPO_NAME}"

# Make sure we are root
if [[ "$EUID" -ne 0 ]]; then
  printf "This script must be run as root.\n\n"; exit 1
fi

# Make sure we have Portage
which emerge > /dev/null 2>&1

if [[ $? -ne 0 ]]; then
  printf "Portage doesn't seem to be installed...\n\n"; exit 1
fi

# Make sure git is installed
qlist -Ieq "dev-vcs/git" > /dev/null

if [[ $? -ne 0 ]] ; then
  while true; do
    read -r -p "Y'all ain't got git.  Install it? [Y/N] " yn

    case $yn in
        [Yy][Ee][Ss]|[Yy])
    printf "\nOn it!\n\n"
    emerge "dev-vcs/git" || exit 1 && break
    ;;
        [Nn][Oo]|[Nn])
    printf "\nThis is a git overlay; it needs git to function.\n\n"
    exit 1
    ;;
        *)
    echo "\nNo comprende.\n\n"
    ;;
    esac

  done
fi

# Get the goods
printf "Fetching ${REPO_NAME}.conf\n\n"
wget "https://raw.githubusercontent.com/${AUTHOR}/${REPO_NAME}/master/${REPO_NAME}.conf" -O "/etc/portage/repos.conf/${REPO_NAME}.conf" && \

# Create the overlay directory or empty it if necessary.
if [ -d "${OVERLAY_DIR}"/.git ]; then
  printf "Existing repo directory found: ${OVERLAY_DIR}.\n\n"
elif [ -d "${OVERLAY_DIR}" ] && [ ! -z "${OVERLAY_DIR}" ]; then
  printf "${OVERLAY_DIR} already exists and is not a git repo!\n"
  while true; do
    read -r -p "Ok to empty it? [Y/N] " yn

    case $yn in
        [Yy][Ee][Ss]|[Yy])
    printf "\nOk, removing contents of ${OVERLAY_DIR}.\n\n"
    cd ${OVERLAY_DIR} && find -delete || exit 1 && break
    ;;
        [Nn][Oo]|[Nn])
    printf "\nOk, exiting.\n\n"
    exit 1
    ;;
        *)
    echo "\nCome again?\n\n"
    ;;
    esac

  done
else
  printf "Creating ${OVERLAY_DIR}.\n\n"
  mkdir -p "${OVERLAY_DIR}"
fi

# Initial sync
printf "Syncing overlay.\n\n"
emaint sync -r "${REPO_NAME}"

printf "Hecks yeah!  We ready to roll!\n"
