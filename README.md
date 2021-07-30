# Automatic WordPress deployment to WP Engine

This GitHub Action can be used to set automatic deployments using an SSH private key and **rsync**.

By default, the action will deploy the repository root directory, but you can optionally deploy a theme, plugin, or any other directory using the `SOURCE_PATH`. Likewise, if you need to specify a different destination directory, you can do so using `PUBLISH_PATH`.

After the deployment, this action will also purge your WP Engine cache and flush permalinks to ensure all changes are visible.

