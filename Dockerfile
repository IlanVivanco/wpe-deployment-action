FROM instrumentisto/rsync-ssh:alpine3.13-r4

LABEL "com.github.actions.name"="Automatic WordPress deployment to WP Engine"
LABEL "com.github.actions.description"="Set automatic deployments using an SSH private key and rsync."
LABEL "com.github.actions.icon"="arrow-up-circle"
LABEL "com.github.actions.color"="yellow"
LABEL "repository"="https://github.com/IlanVivanco/wpe-deployment-action"
LABEL "maintainer"="Ilán Vivanco <ilanvivanco@gmail.com>"

RUN apk add bash php
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
