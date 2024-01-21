#!/bin/bash

# Change owner of bind mounted volumes.
sudo chown -R $USER:$USER $HOME/.go
sudo chown -R $USER:$USER $HOME/.ssh

if [ ! -f $HOME/.ssh/key ]; then
    ssh-keygen -t ed25519 -f $HOME/.ssh/key -C "godevel-devel"
fi

if [ -f $HOME/.ssh/key ]; then
    while ! ssh-add $HOME/.ssh/key; do
        : # nothing to do
    done
fi

if [ -z "$(git config user.name)" ]; then
    if [ -z "${GIT_USER_NAME}" ]; then
        read -p "Enter git user.name: " gitUserName
        git config user.name "${gitUserName}"
    else
        git config user.name "${GIT_USER_NAME}"
    fi
fi

if [ -z "$(git config user.email)" ]; then
    if [ -z ${GIT_USER_EMAIL} ]; then
        read -p "Enter git user.email: " gitUserEmail
        git config user.email "${gitUserEmail}"
    else
        git config user.email "${GIT_USER_EMAIL}"
    fi
fi

if ! golangci-lint --version ; then
    curl -sSfL \
        https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh | \
            sh -s -- -b $(go env GOPATH)/bin v1.55.2
fi

go install google.golang.org/protobuf/cmd/protoc-gen-go@v1.28
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@v1.2
