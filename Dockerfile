FROM ubuntu:20.04

LABEL maintainer="Nikita Nemirovsky <n.nemirovskiy@gmail.com>"

ENV ORGANIZATION=""
ENV ACCESS_TOKEN=""

ARG TARGETARCH
ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt upgrade -y && \
    apt install -y curl jq build-essential libssl-dev && \
    useradd -m -u 1001 -s /bin/bash docker && \
    mkdir -p /home/docker/actions-runner && cd /home/docker/actions-runner && \
    RUNNER_VERSION=$( \
    curl https://api.github.com/repos/actions/runner/releases/latest | \
    jq .name -r | cut -c2-) \
    ARCH=$( [ "${TARGETARCH}" = "amd64" ] && echo "x64" || echo "${TARGETARCH}") \
    FILENAME=actions-runner-linux-${ARCH}-${RUNNER_VERSION}.tar.gz && \
    curl -OL https://github.com/actions/runner/releases/download/v${RUNNER_VERSION}/${FILENAME} && \
    tar -xzf $FILENAME && \
    rm $FILENAME && \
    chown -R docker:docker /home/docker/actions-runner && \
    ./bin/installdependencies.sh

USER docker

WORKDIR /home/docker

COPY --chown=docker:docker entrypoint.sh .

ENTRYPOINT [ "./entrypoint.sh" ]
