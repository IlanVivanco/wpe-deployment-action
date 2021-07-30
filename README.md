# Automatic WordPress deployment to WP Engine

This GitHub Action can be used to set automatic deployments using an SSH private key and **rsync**.

By default, the action will deploy the repository root directory, but you can optionally deploy a theme, plugin, or any other directory using the `SOURCE_PATH`. Likewise, if you need to specify a different destination directory, you can do so using `PUBLISH_PATH`.

After the deployment, this action will also purge your WP Engine cache and flush permalinks to ensure all changes are visible.

## GitHub Action workflow

1. Set up your [SSH key](#setting-up-your-ssh-key) on WP Engine.

1. Create a new YML file in the directory `.github/workflows/` in the root of your repository. You can choose any name, e.g., `deploy.yml`.

1. Add the following code to this new file, replacing values for `PRD_BRANCH` and `PRD_ENV` accordingly. Optionally, you can uncomment and set the values for `STG_BRANCH`/`STG_ENV` and `DEV_BRANCH`/`DEV_ENV` environments.

   ###### .github/workflows/deploy.yml:

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
