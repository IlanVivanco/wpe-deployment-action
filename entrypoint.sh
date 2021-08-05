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

# Sanitize branches input characters.
PRD_BRANCH=$(printf '%s' $PRD_BRANCH)
STG_BRANCH=$(printf '%s' $STG_BRANCH)
DEV_BRANCH=$(printf '%s' $DEV_BRANCH)

# Use regex to check if there's a match with the current GITHUB_REF.
# Replace commas with pipes and check if any branches at NN_BRANCH is a match.
# If so, use the corresponding NN_ENV install for deploying.
FAIL_CODE=${FAIL_CODE:=1}
if [[ $GITHUB_REF =~ ($(echo $PRD_BRANCH | tr ',' '|'))$ ]]; then
	export WPE_ENV_NAME=$PRD_ENV
elif [[ $GITHUB_REF =~ ($(echo $STG_BRANCH | tr ',' '|'))$ ]]; then
	export WPE_ENV_NAME=$STG_ENV
elif [[ $GITHUB_REF =~ ($(echo $DEV_BRANCH | tr ',' '|'))$ ]]; then
	export WPE_ENV_NAME=$DEV_ENV
else
	echo "ABORT: At least a branch name is required." && exit FAIL_CODE
fi

# Deploy vars.
DIR_PATH=${PUBLISH_PATH:=""}
SRC_PATH=${SOURCE_PATH:="."}
WPE_SSH_HOST="$WPE_ENV_NAME.ssh.wpengine.net"
WPE_SSH_USER="$WPE_ENV_NAME"@"$WPE_SSH_HOST"
WPE_DESTINATION="$WPE_SSH_USER":sites/"$WPE_ENV_NAME"/"$DIR_PATH"

# Setup our SSH Connection & set SSH permissions.
ssh-keyscan -t rsa "$WPE_SSH_HOST" >> "$KNOWN_HOSTS_PATH"
chmod 700 "$SSH_PATH"
chmod 644 "$KNOWN_HOSTS_PATH"
chmod 600 "$WPE_SSH_KEY_PATH"

# Deploy via SSH.
rsync -chav --inplace \
	--rsh="ssh -v -p 22 -i ${WPE_SSH_KEY_PATH} -o StrictHostKeyChecking=no" \
	--exclude=".*" --exclude-from="$SRC_PATH/.deployignore" \
	--chmod=D2775,F664 --out-format="%n" \
	--delete --delete-excluded \
	$SRC_PATH "$WPE_DESTINATION"

# Flush permalinks and clear cache.
ssh -v -p 22 -i ${WPE_SSH_KEY_PATH} -o StrictHostKeyChecking=no $WPE_SSH_USER "cd sites/${WPE_ENV_NAME} && wp rewrite flush && wp page-cache flush"

echo "SUCCESS: Site has been deployed!"
