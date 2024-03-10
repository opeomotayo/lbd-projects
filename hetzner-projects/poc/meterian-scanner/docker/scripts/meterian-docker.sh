#!/bin/bash

set -e
set -o pipefail
if [[ "$*" =~ --debug ]]; then
    set -x
fi

# Set this constant with the tag name corresponding to the image version you wish to use for the scan
# (for a list of tags visit: https://hub.docker.com/r/meterian/cli/tags)
VERSION="latest"
for arg in $*
do
    flagAndTag="$(expr "$arg" : '\(--image:.*\)')" || true
    maybeTag="$(echo "$flagAndTag" | cut -d: -f2)"
    if [[ "$maybeTag" != "" ]]; then
        VERSION="$maybeTag"
        echo "Requested usage of image 'meterian/cli:$VERSION'"
    fi
done

if [[ "$*" =~ --process-notebooks ]]; then
    echo "Python notebooks scan detected, the dedicated image 'meterian/cli:latest-python' will be employed"
    VERSION="latest-python"
fi

DOCKER_FULL_IMAGE_NAME="meterian/cli:${VERSION}"
WORKDIR=${METERIAN_WORKDIR:-$(pwd)}

# in this occasion utilise the client canary for the scan
if [[ "$*" =~ "--canary" ]];
then
    CLIENT_CANARY_FLAG=on
    DOCKER_FULL_IMAGE_NAME="meterian/cli-canary:${VERSION}"
    echo "Using canary version of Docker and Meterian clients"
fi

# checking existence of following files on the host machine prior to binding
dotnetrc_docker_bind=""
if [[ -f "${HOME}/.netrc" ]]; then
    dotnetrc_docker_bind="--volume ${HOME}/.netrc:/home/meterian/.netrc:ro"
fi

gitconfig_docker_bind=""
if [[ -f "${HOME}/.gitconfig" ]]; then
    gitconfig_docker_bind="--volume ${HOME}/.gitconfig:/home/meterian/.gitconfig:ro"
fi

dotssh_docker_bind=""
if [[ -d "${HOME}/.ssh" ]]; then
    dotssh_docker_bind="--volume ${HOME}/.ssh:/home/meterian/.ssh:ro"
fi

if [[ "$*" =~ "--unbound" ]];
then
    docker run -it --rm \
              --volume ${WORKDIR}:/workspace \
              --env METERIAN_API_TOKEN=${METERIAN_API_TOKEN} \
              --env CLIENT_VM_PARAMS="${CLIENT_VM_PARAMS}" \
              --env CLIENT_CANARY_FLAG=${CLIENT_CANARY_FLAG} \
              --env GOPRIVATE=${GOPRIVATE} \
              --env METERIAN_ENV=${METERIAN_ENV:-$CLIENT_ENV} \
              --env METERIAN_PROTO=${METERIAN_PROTO:-$CLIENT_PROTO} \
              --env METERIAN_DOMAIN=${METERIAN_DOMAIN:-$CLIENT_DOMAIN} \
              --env CLIENT_AUTO_UPDATE=${CLIENT_AUTO_UPDATE} \
              --env http_proxy="${http_proxy}" \
              --env https_proxy="${https_proxy}" \
              ${dotnetrc_docker_bind:-} \
              ${gitconfig_docker_bind:-} \
              ${dotssh_docker_bind:-} \
              ${DOCKER_FULL_IMAGE_NAME} $*

    # please do not add any command after "docker run" as we need to preserve
    # the exit status of the meterian client

else

    # get current uid
    HOST_UID=`id -u`
    HOST_GID=`id -g`

    CONTAINER_HOME_DIR=/home/meterian

    VOLUME_BINDS=(
        "$HOME/.cache::$CONTAINER_HOME_DIR/.cache"
    # maven specific mappings
        "$HOME/.m2::$CONTAINER_HOME_DIR/.m2"
    # dotnet specific mappings
        "$HOME/.dotnet::$CONTAINER_HOME_DIR/.dotnet"
        "$HOME/.nuget::$CONTAINER_HOME_DIR/.nuget"
    # gradle specific mappings
        "$HOME/.gradle::$CONTAINER_HOME_DIR/.gradle"
    # sbt specific mappings
        "$HOME/.sbt::$CONTAINER_HOME_DIR/.sbt"
        "$HOME/.ivy2::$CONTAINER_HOME_DIR/.ivy2"
    )

    set +e
    cache_dir=$(gem environment gemdir 2>/dev/null)
    if [ $? -eq 0 ];
    then
        VOLUME_BINDS=( "${VOLUME_BINDS[@]}" "${cache_dir}::/usr/lib/ruby/gems/3.1.0/cache/" )
    fi

    cache_dir=$(npm root -g 2>/dev/null)
    if [ $? -eq 0 ];
    then
        VOLUME_BINDS=( "${VOLUME_BINDS[@]}" "${cache_dir}::/usr/lib/node_modules" )
    fi
    set -e

    docker_run_data=""
    for index in "${VOLUME_BINDS[@]}"; do
        local_addr="${index%%::*}"
        if [ -d $local_addr ];
        then
            docker_addr="${index##*::}"
            docker_run_data="${docker_run_data} --mount type=bind,source='${local_addr}',target='${docker_addr}' "
        fi
    done

    # mapping /tmp so that the most recent version of the meterian client is retained on the host machine causing it to be updated only when a newer version is detected
    docker_run_data="${docker_run_data} --mount type=bind,source=/tmp,target=/tmp "
    docker_run_data="${docker_run_data} ${dotnetrc_docker_bind:-}"
    docker_run_data="${docker_run_data} ${gitconfig_docker_bind:-}"
    docker_run_data="${docker_run_data} ${dotssh_docker_bind:-}"

    docker_run_data="${docker_run_data} --env HOST_UID='${HOST_UID}' --env HOST_GID='${HOST_GID}' "
    docker_run_data="${docker_run_data} --env GOPRIVATE='${GOPRIVATE}' "
    docker_run_data="${docker_run_data} --env METERIAN_ENV='${METERIAN_ENV:-$CLIENT_ENV}' "
    docker_run_data="${docker_run_data} --env METERIAN_PROTO='${METERIAN_PROTO:-$CLIENT_PROTO}' "
    docker_run_data="${docker_run_data} --env METERIAN_DOMAIN='${METERIAN_DOMAIN:-$CLIENT_DOMAIN}' "
    docker_run_data="${docker_run_data} --env CLIENT_AUTO_UPDATE='${CLIENT_AUTO_UPDATE}' "
    docker_run_data="${docker_run_data} --env http_proxy='${http_proxy}' "
    docker_run_data="${docker_run_data} --env https_proxy='${https_proxy}' "
    docker_run_data="${docker_run_data} --env METERIAN_API_TOKEN='${METERIAN_API_TOKEN}' --env CLIENT_VM_PARAMS='${CLIENT_VM_PARAMS}' --env CLIENT_CANARY_FLAG='${CLIENT_CANARY_FLAG}' '${DOCKER_FULL_IMAGE_NAME}' \$*"
    eval "docker run -it --rm --volume $WORKDIR:/workspace $docker_run_data"

    # please do not add any command after "docker run" as we need to preserve
    # the exit status of the meterian client

fi

# please do not add any command after "docker run" as we need to preserve
# the exit status of the meterian client
