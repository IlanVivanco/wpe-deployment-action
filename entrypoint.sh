#!/bin/bash -l

set -e

: ${WPE_SSH_KEY?Required secret not set.}

# SSH key vars
SSH_PATH="$HOME/.ssh"
KNOWN_HOSTS_PATH="$SSH_PATH/known_hosts"
WPE_SSH_KEY_PATH="$SSH_PATH/wpe_deploy"

# Setup our SSH connection & use keys.
[ ! -d "$SSH_PATH" ] && mkdir "$SSH_PATH"

# Copy secret keys to container.
echo "$WPE_SSH_KEY" > "$WPE_SSH_KEY_PATH"

###
# Branches config.
#
# To add new environments, just copy/paste an elif line and the following export.
# Then adjust variables names to match the new ones you added to the deploy.yml
#
# Example:
# elif [[ ${GITHUB_REP} =~ ${NEW_BRANCH}$ ]]; then
#     export WPE_ENV_NAME=${NEW_ENV};
###
if [[ $GITHUB_REF =~ ${PRD_BRANCH}$ ]]; then
	export WPE_ENV_NAME=$PRD_ENV
elif [[ $GITHUB_REF =~ ${STG_BRANCH}$ ]]; then
	export WPE_ENV_NAME=$STG_ENV
elif [[ $GITHUB_REF =~ ${DEV_BRANCH}$ ]]; then
	export WPE_ENV_NAME=$DEV_ENV
else
	echo "FAILURE: Branch name is required." && exit 1
fi

# Deploy directories.
if [ -n "$PUBLISH_PATH" ]; then
	DIR_PATH="$PUBLISH_PATH"
else
	DIR_PATH=""
fi

if [ -n "$SOURCE_PATH" ]; then
	SRC_PATH="$SOURCE_PATH"
else
	SRC_PATH="."
fi

# Deploy vars.
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"
WPE_DESTINATION="$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"

# Setup our SSH Connection & use keys.
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH"

# Set key permissions.
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$WPE_SSH_KEY_PATH"

# Deploy via SSH.
rsync -chav --inplace \
	--rsh="ssh -v -p 22 -i ${WPE_SSH_KEY_PATH} -o StrictHostKeyChecking=no" \
	--chmod=D2775,F664 --out-format="%n" \
	$SRC_PATH "$WPE_DESTINATION"

# Flush permalinks and clear cache.
ssh -v -p 22 -i ${WPE_SSH_KEY_PATH} -o StrictHostKeyChecking=no $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} && wp rewrite flush && wp page-cache flush"

echo "SUCCESS: Site has been deployed!"
