#!/bin/bash -l

set -e

: ${WPE_SSH_KEY?Required secret not set.}

# SSH key vars
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSH_KEY_PATH="$SSH_PATH/wpe_deploy"

