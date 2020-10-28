# pip should only run if there is a virtualenv currently activated
export PIP_REQUIRE_VIRTUALENV=true

# Cache pip-installed packages to avoid re-downloading
export PIP_DOWNLOAD_CACHE=$HOME/.pip/cache

# Python startup file
export PYTHONSTARTUP=$HOME/.pythonrc

# Vagrant
VAGRANT_DISABLE_VBOXSYMLINKCREATE=1

# fzf
[ -f ~/.zsh/fzf.zsh ] && source ~/.zsh/fzf.zsh
bindkey "ç" fzf-cd-widget

# Kubernetes
source <(kubectl completion zsh)
source <(kubectl completion zsh | sed s/kubectl/k/g)

# gcloud athentication env
export GOOGLE_APPLICATION_CREDENTIALS=$HOME/.config/gcloud/application_default_credentials.json

# for gsutil
# https://github.com/GoogleCloudPlatform/gsutil/issues/961#issuecomment-665603017
export CLOUDSDK_PYTHON=/usr/local/bin/python3
