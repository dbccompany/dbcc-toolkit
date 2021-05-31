FROM debian:stable-slim

#  Where to install bineries
ARG BINDIR=/usr/bin

# Package version
ARG TERRAFORM_VERSION="0.14.9"
ARG TERRAGRUNT_VERSION="v0.28.16"
ARG KOPS_VERSION="v1.20.1"
ARG KUBECTL_VERSION="v1.20.7"
ARG HELM_VERSION="v3.5.3"
ARG HELMFILE_VERSION="v0.139.6"
ARG HELM_PLUGIN_VERSION_SECRETS="v3.5.0"
ARG HELM_PLUGIN_VERSION_GIT="0.8.1"
ARG HELM_PLUGIN_VERSION_DIFF="3.1.3"
ARG HELM_PLUGIN_VERSION_SPRAY="4.0.2"
ARG HELM_PLUGIN_VERSION_PUSH="0.8.1"
ARG HELM_PLUGIN_VERSION_2TO3="0.7.0"
ARG HELM_PLUGIN_VERSION_MAPKUBEAPIS="0.0.14"
ARG HELM_PLUGIN_VERSION_ENV="0.1.0"
ARG HELM_PLUGIN_VERSION_PUSH_ARTIFACTORY="1.0.1"

ARG GCLOUD_VERSION="342.0.0"
ARG YQ_VERSION="4.9.3"
ARG TFMASK_VERSION="0.7.0"
ARG INFRACOST_VERSION="0.8.7"
ARG CONFTEST_VERSION="0.25.0"
ARG ATLANTIS_VERSION="0.17.0"


# Setup software we need for pipelines and adhocs


RUN apt update -y                                                                                                                                       \
 && apt install -y sudo git openssh-client make openssl curl jq tar gzip unzip bash gnupg ca-certificates parallel debian-archive-keyring               \
 && echo 'deb http://deb.debian.org/debian buster-backports main' >> /etc/apt/sources.list                                                              \
 && curl -sL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/trusted.gpg.d/microsoft.gpg                                   \
 && echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ buster main" > /etc/apt/sources.list.d/azure.list                            \
 && curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/Release.key | apt-key add -                        \
 && echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/Debian_10/ /"                                               \
  > /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list                                                                                       \
 && apt update -y && apt-get -y -t buster-backports install libseccomp2 && apt install -y azure-cli skopeo buildah podman                               \
 && curl -Lso- "https://get.helm.sh/helm-${HELM_VERSION}-linux-amd64.tar.gz" | tar -xvz --strip-components=1 -C $BINDIR linux-amd64/helm                \
 && curl -Lso- "https://github.com/mikefarah/yq/releases/download/v${YQ_VERSION}/yq_linux_amd64.tar.gz"                                                  \
  | tar -xvz --transform "s/yq_linux_amd64/yq/" -C $BINDIR "./yq_linux_amd64"                                                                           \
 && curl -Lso $BINDIR/kubectl "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"                                                    \
 && curl -Lso $BINDIR/helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64"                          \
 && curl -Lso $BINDIR/kops "https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64"                                      \
 && curl -Lso- "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"                           \
  | gunzip -c > $BINDIR/terraform                                                                                                                       \
 && curl -Lso $BINDIR/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"            \
 && curl -Lso- "https://github.com/runatlantis/atlantis/releases/download/v${ATLANTIS_VERSION}/atlantis_linux_amd64.zip"                                \
  | gunzip -c > $BINDIR/atlantis                                                                                                                        \
 && curl -Lso- "https://github.com/open-policy-agent/conftest/releases/download/v${CONFTEST_VERSION}/conftest_${CONFTEST_VERSION}_Linux_x86_64.tar.gz"  \
  | tar -xvz -C $BINDIR conftest                                                                                                                        \
 && curl -Lso $BINDIR/tfmask "https://github.com/cloudposse/tfmask/releases/download/${TFMASK_VERSION}/tfmask_linux_amd64"                              \
 && curl -Lso- "https://github.com/infracost/infracost/releases/download/v${INFRACOST_VERSION}/infracost-linux-amd64.tar.gz"                            \
  | tar -xvz --transform "s/infracost-linux-amd64/infracost/" -C $BINDIR infracost-linux-amd64                                                          \
 && chmod +x                                                                                                                                            \
      $BINDIR/kubectl                                                                                                                                   \
      $BINDIR/helmfile                                                                                                                                  \
      $BINDIR/kops                                                                                                                                      \
      $BINDIR/terraform                                                                                                                                 \
      $BINDIR/terragrunt                                                                                                                                \
      $BINDIR/atlantis                                                                                                                                  \
      $BINDIR/conftest                                                                                                                                  \
      $BINDIR/infracost                                                                                                                                 \
# Install helm plugins
 && helm plugin install https://github.com/jkroepke/helm-secrets --version ${HELM_PLUGIN_VERSION_SECRETS}                                               \
 && helm plugin install https://github.com/aslafy-z/helm-git --version ${HELM_PLUGIN_VERSION_GIT}                                                       \
 && helm plugin install https://github.com/databus23/helm-diff --version ${HELM_PLUGIN_VERSION_DIFF}                                                    \
 && helm plugin install https://github.com/ThalesGroup/helm-spray --version ${HELM_PLUGIN_VERSION_SPRAY}                                                \
 && helm plugin install https://github.com/chartmuseum/helm-push --version ${HELM_PLUGIN_VERSION_PUSH}                                                  \
 && helm plugin install https://github.com/helm/helm-2to3 --version ${HELM_PLUGIN_VERSION_2TO3}                                                         \
 && helm plugin install https://github.com/hickeyma/helm-mapkubeapis --version ${HELM_PLUGIN_VERSION_MAPKUBEAPIS}                                       \
 && helm plugin install https://github.com/adamreese/helm-env --version ${HELM_PLUGIN_VERSION_ENV}                                                      \
 && helm plugin install https://github.com/belitre/helm-push-artifactory-plugin --version ${HELM_PLUGIN_VERSION_PUSH_ARTIFACTORY}                       \
# Install awscli v2
 && curl -sL https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip                                                                   \
 && unzip awscliv2.zip                                                                                                                                  \
 && aws/install --install-dir /usr/local/aws-cli --bin-dir $BINDIR                                                                                      \
# Install GCloud CLI
 && curl -Lso- https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-${GCLOUD_VERSION}-linux-x86_64.tar.gz                        \
  | tar xvz -C /usr/local                                                                                                                               \
        google-cloud-sdk/bin                                                                                                                            \
        google-cloud-sdk/lib                                                                                                                            \
        google-cloud-sdk/platform                                                                                                                       \
# && google-cloud-sdk/install.sh -q
 && ln -fsL /usr/local/google-cloud-sdk/bin/* $BINDIR                                                                                                   \
# Alternative way to install latest Google SDK
# && curl https://sdk.cloud.google.com | bash -s -- --disable-prompts --install-dir=/usr/local
# && rm -rf /usr/local/google-cloud-sdk/.install/
# && ln -s /usr/local/google-cloud-sdk/bin/gcloud $BINDIR/gcloud

# alias docker to podman (for all sessions respecting PATH)
 && ln -sf $(which podman) $BINDIR/docker                                                                                                               \
# Enable podman mount_program and set event logger to 'none'
 && sed -i -e 's/#mount_program/mount_program/' /etc/containers/storage.conf                                                                            \
 && echo "[engine]\nevents_logger = \"none\"\ncgroup_manager = \"cgroupfs\"" > /etc/containers/containers.conf                                          \
# Clean up some garbage
 && rm -rfv /root/.cache                                                                                                                                \
            /tmp/*                                                                                                                                      \
            /var/cache/apt/*                                                                                                                            \
            awscliv2.zip aws                                                                                                                            \
            google-cloud-sdk                                                                                                                            \
            /usr/local/aws-cli/v2/*/dist/aws_completer                                                                                                  \
            /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index                                                                                           \
            /usr/local/aws-cli/v2/*/dist/awscli/examples
