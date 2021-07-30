# Automatic WordPress deployment to WP Engine

This GitHub Action can be used to set automatic deployments using an SSH private key and **rsync**.

By default, the action will deploy the repository root directory, but you can optionally deploy a theme, plugin, or any other directory using the `SOURCE_PATH`. Likewise, if you need to specify a different destination directory, you can do so using `PUBLISH_PATH`.

After the deployment, this action will also purge your WP Engine cache and flush permalinks to ensure all changes are visible.

## GitHub Action workflow

1. Set up your [SSH key](#setting-up-your-ssh-key) on WP Engine.

1. Create a new YML file in the directory `.github/workflows/` in the root of your repository. You can choose any name, e.g., `deploy.yml`.

1. Add the following code to this new file, replacing values for `PRD_BRANCH` and `PRD_ENV` accordingly. Optionally, you can uncomment and set the values for `STG_BRANCH`/`STG_ENV` and `DEV_BRANCH`/`DEV_ENV` environments.

   **`> .github/workflows/deploy.yml`**

   ```yml
   name: 📦 Deploy to WP Engine
   on:
      push:
      workflow_dispatch:

   jobs:
      build:
         name: 🚩 Starting deployment job
         runs-on: ubuntu-latest
         steps:
            - name: 🚚 Getting latest code
            uses: actions/checkout@v2

            - name: 🔁 Deploying to WP Engine
            uses: IlanVivanco/github-action-wpe-site-deploy@feature/filter-files
            env:
               # Deployment options.
               WPE_SSH_KEY: ${{ secrets.WPE_SSH_KEY }}
               SOURCE_PATH: ''
               PUBLISH_PATH: ''

               # You must, at least, set the production environment.
               PRD_BRANCH: main
               PRD_ENV: prodinstall

               # Uncomment this for staging environment.
               # STG_BRANCH: staging
               # STG_ENV: stageinstall

               # Uncomment this for development environment.
               # DEV_BRANCH: dev
               # DEV_ENV: devinstall
   ```

1. You can now push the latest changes to the repository, the action will do the rest.

   ![Magic](https://media.giphy.com/media/l3V0dy1zzyjbYTQQM/giphy.gif)

## Setting up your SSH key

1. [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/) as a special deploy key between your GitHub Repo and WP Engine. The simplest method is to generate a key pair with a blank passphrase, which creates an unencrypted private key.

1. Add the public SSH key to your [WP Engine SSH Keys](https://wpengine.com/support/ssh-gateway/#Add_SSH_Key) configuration panel.

1. Store the private key in the GitHub repository as new [GitHub encrypted secret](https://docs.github.com/en/actions/reference/encrypted-secrets#creating-encrypted-secrets-for-a-repository) using the name `WPE_SSH_KEY` save it —this can be customized if you change the secret name in the yml file to call it correctly—.

## Ignoring files

If you want some files to be ignored upon deployment, you can create a `.deployignore` file on your source directory, adding the exclude patterns —one per line—. Blank lines and lines starting with _#_ will be ignored.

**`> .deployignore`**

```bash
# Exclude rules
bin
composer*
dist
gulp*
node_modules
package*
phpcs*
src
vendor
```

## Environment variables

### Required

| Name          | Type      | Usage                                                                                     |
| ------------- | --------- | ----------------------------------------------------------------------------------------- |
| `WPE_SSH_KEY` | _secrets_ | Authorized SSH private key for deployment. See [SSH key usage](#setting-up-your-ssh-key). |
| `PRD_BRANCH`  | _string_  | Name of the branch you would like to deploy from, e.g., "_main_".                         |
| `PRD_ENV`     | _string_  | Name of the WP Engine Prod environment you want to deploy to.                             |

### Optional

| Name           | Type     | Usage                                                                                                                       |
| -------------- | -------- | --------------------------------------------------------------------------------------------------------------------------- |
| `STG_BRANCH`   | _string_ | Name of the staging branch you would like to deploy from.                                                                   |
| `STG_ENV`      | _string_ | Name of the the WP Engine Stage environment you want to deploy to.                                                          |
| `DEV_BRANCH`   | _string_ | Name of the a development branch you would like to deploy from.                                                             |
| `DEV_ENV`      | _string_ | Name of the the WP Engine Dev environment you want to deploy to.                                                            |
| `SOURCE_PATH`  | _string_ | Path to specify a theme, plugin, or any other directory source to deploy from. Defaults to the repository root.             |
| `PUBLISH_PATH` | _string_ | Path to specify a theme, plugin, or any other directory destination to deploy to. Defaults to the WordPress root directory. |

### Additional Resources

-  [Generate a new SSH key pair](https://help.github.com/articles/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent/)
-  [Setting up SSH on WP Engine](https://wpengine.com/support/ssh-gateway/)
-  [Storing secrets in GitHub](https://docs.github.com/en/actions/reference/encrypted-secrets)

### Contributing
Contributions to this action are always welcome and highly encouraged.

### Attribution

This action is based on the work made by Alex Zuniga on [GitHub Action for WP Engine Site Deployments](https://github.com/wpengine/github-action-wpe-site-deploy).

### License
This is open-sourced software licensed under the [MIT license](LICENSE.md).