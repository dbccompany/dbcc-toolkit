FROM alpine:3.12

#  Where to install bineries
ARG BINDIR=/usr/bin

# Package version
ARG KUBECTL_VERSION="v1.18.9"
ARG HELM_VERSION="v3.3.4"
ARG HELMFILE_VERSION="v0.130.0"
ARG KOPS_VERSION="v1.18.1"
ARG TERRAFORM_VERSION="0.13.3"
ARG TERRAGRUNT_VERSION="v0.25.2"
ARG SECRETS_HELM_PLUGIN_VERSION="2.0.2"
ARG GIT_HELM_PLUGIN_VERSION="0.8.1"
ARG DIFF_HELM_PLUGIN_VERSION="3.1.3"

# AWS CLI 2 dependency
ARG GLIBC_VERSION=2.31-r0


# Setup software we need for pipelines and adhocs
RUN apk --update add --no-cache git openssh-client make openssl curl jq tar gzip bash gnupg ca-certificates                                                \
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
# install glibc compatibility for alpine (awscli-v2 requirement)
 && curl -sL https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub -o /etc/apk/keys/sgerrand.rsa.pub                                                           \
 && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-${GLIBC_VERSION}.apk                                   \
 && curl -sLO https://github.com/sgerrand/alpine-pkg-glibc/releases/download/${GLIBC_VERSION}/glibc-bin-${GLIBC_VERSION}.apk                               \
 && apk add --no-cache glibc-${GLIBC_VERSION}.apk glibc-bin-${GLIBC_VERSION}.apk                                                                           \
# Install azure-cli and awscli
 && apk add --virtual=build gcc libffi-dev musl-dev openssl-dev python3-dev py3-pip binutils                                                               \
 && pip --no-cache-dir install azure-cli                                                                                                                   \
 && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip                                                                      \
 && unzip awscliv2.zip                                                                                                                                     \
 && aws/install --install-dir /usr/local/aws-cli --bin-dir $BINDIR                                                                                         \
 && apk del --purge build                                                                                                                                  \
# Clean up some garbage
 && rm -rf /root/.cache                                                                                                                                    \
           /tmp/*                                                                                                                                          \
           /var/cache/apk/*                                                                                                                                \
           awscliv2.zip aws                                                                                                                                \
           /usr/local/aws-cli/v2/*/dist/aws_completer                                                                                                      \
           /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index                                                                                               \
           /usr/local/aws-cli/v2/*/dist/awscli/examples                                                                                                    \
           glibc-${GLIBC_VERSION}.apk                                                                                                                      \
           glibc-bin-${GLIBC_VERSION}.apk                                                                                                                  \
