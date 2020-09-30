FROM alpine:3.12

ARG KUBECTL_VERSION="v1.18.9"
ARG HELM_VERSION="v3.3.4"
ARG HELMFILE_VERSION="v0.130.0"
ARG KOPS_VERSION="v1.18.1"
ARG TERRAFORM_VERSION="0.13.3"
ARG TERRAGRUNT_VERSION="v0.25.2"
ARG SECRETS_HELM_PLUGIN_VERSION="2.0.2"
ARG GIT_HELM_PLUGIN_VERSION="0.8.1"
ARG DIFF_HELM_PLUGIN_VERSION="3.1.3"
ARG BINDIR=/usr/bin

# Setup software we need for pipelines and adhocs
RUN apk --update add --no-cache git openssh-client make openssl curl jq tar gzip bash gnupg ca-certificates python3                                        \
 && curl -Lso- "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xvz --strip-components=1 -C $BINDIR linux-amd64/helm                   \
 && curl -Lso $BINDIR/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"                       \
 && curl -Lso $BINDIR/helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64"                             \
 && curl -Lso $BINDIR/kops "https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64"                                         \  
 && curl -Lso- "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"                              \
    | unzip -p - > $BINDIR/terraform                                                                                                                       \
 && curl -Lso $BINDIR/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"               \
 && chmod +x                                                                                                                                               \
      $BINDIR/kubectl                                                                                                                                      \
      $BINDIR/helmfile                                                                                                                                     \
      $BINDIR/kops                                                                                                                                         \
      $BINDIR/terraform                                                                                                                                    \
      $BINDIR/terragrunt                                                                                                                                   \
# Install helm plugins
 && helm plugin install https://github.com/zendesk/helm-secrets --version ${SECRETS_HELM_PLUGIN_VERSION}                                                   \
 && helm plugin install https://github.com/aslafy-z/helm-git --version ${GIT_HELM_PLUGIN_VERSION}                                                          \
 && helm plugin install https://github.com/databus23/helm-diff --version ${DIFF_HELM_PLUGIN_VERSION}                                                       \
# Install azure-cli
 && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev py3-pip                                                                        \
 && pip --no-cache-dir install azure-cli awscli                                                                                                            \
 && apk del --purge build                                                                                                                                  \
# Clean up some garbage
 && rm -rf /root/.cache /tmp/*
