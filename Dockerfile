FROM debian:stable-slim

#  Where to install bineries
ARG BINDIR=/usr/bin

# Package version
ARG KUBECTL_VERSION="v1.19.7"
ARG HELM_VERSION="v3.5.3"
ARG HELMFILE_VERSION="v0.138.7"
ARG KOPS_VERSION="v1.19.1"
ARG TERRAFORM_VERSION="0.14.9"
ARG TERRAGRUNT_VERSION="v0.28.16"
ARG HELM_PLUGIN_VERSION_SECRETS="v3.5.0"
ARG HELM_PLUGIN_VERSION_GIT="0.8.1"
ARG HELM_PLUGIN_VERSION_DIFF="3.1.3"
ARG HELM_PLUGIN_VERSION_SPRAY="4.0.2"
ARG HELM_PLUGIN_VERSION_PUSH="0.8.1"
ARG HELM_PLUGIN_VERSION_2TO3="0.7.0"
ARG HELM_PLUGIN_VERSION_MAPKUBEAPIS="0.0.14"
ARG HELM_PLUGIN_VERSION_ENV="0.1.0"
ARG HELM_PLUGIN_VERSION_PUSH_ARTIFACTORY="1.0.1"

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
 && curl -Lso $BINDIR/kubectl "https://storage.googleapis.com/kubernetes-release/release/${KUBECTL_VERSION}/bin/linux/amd64/kubectl"                    \
 && curl -Lso $BINDIR/helmfile "https://github.com/roboll/helmfile/releases/download/${HELMFILE_VERSION}/helmfile_linux_amd64"                          \
 && curl -Lso $BINDIR/kops "https://github.com/kubernetes/kops/releases/download/${KOPS_VERSION}/kops-linux-amd64"                                      \
 && curl -Lso- "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip"                           \
  | gunzip -c > $BINDIR/terraform                                                                                                                       \
 && curl -Lso $BINDIR/terragrunt "https://github.com/gruntwork-io/terragrunt/releases/download/${TERRAGRUNT_VERSION}/terragrunt_linux_amd64"            \
 && chmod +x                                                                                                                                            \
      $BINDIR/kubectl                                                                                                                                   \
      $BINDIR/helmfile                                                                                                                                  \
      $BINDIR/kops                                                                                                                                      \
      $BINDIR/terraform                                                                                                                                 \
      $BINDIR/terragrunt                                                                                                                                \
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
# alias docker to podman (for all sessions respecting PATH)
 && ln -sf $(which podman) $BINDIR/docker                                                                                                               \
# Enable podman mount_program and set event logger to 'none'
 && sed -i -e 's/#mount_program/mount_program/' /etc/containers/storage.conf                                                                            \
 && echo "[engine]\nevents_logger = \"none\"\ncgroup_manager = \"cgroupfs\"" > /etc/containers/containers.conf                                          \
# Clean up some garbage
 && rm -rf /root/.cache                                                                                                                                 \
           /tmp/*                                                                                                                                       \
           /var/cache/apt/*                                                                                                                             \
           awscliv2.zip aws                                                                                                                             \
           /usr/local/aws-cli/v2/*/dist/aws_completer                                                                                                   \
           /usr/local/aws-cli/v2/*/dist/awscli/data/ac.index                                                                                            \
           /usr/local/aws-cli/v2/*/dist/awscli/examples
