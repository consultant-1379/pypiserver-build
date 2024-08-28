
ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles

# CBO PRA version
ARG CBO_VERSION

FROM ${CBO_IMAGE_URL}:${CBO_VERSION} 
ARG CBO_VERSION
ARG NODE_VERSION
ARG NPM_VERSION
ARG YARN_VERSION


# CBO ARM BASE URL
ARG ARM_URL="https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local"
ARG CBO_REPO="$ARM_URL/common_base_os/sles/$CBO_VERSION"
ARG DEV_REPO="$ARM_URL/adp-dev/adp-build-env/$CBO_VERSION"

ARG NPM_REGISTRY=https://arm.seli.gic.ericsson.se/artifactory/api/npm/npm-remote/

RUN zypper addrepo --gpgcheck-strict -f $CBO_REPO COMMON_BASE_OS_SLES_REPO  \
    && zypper addrepo --gpgcheck-strict -f $DEV_REPO ADP_DEV_BUILD_ENV_REPO \
    && zypper --gpg-auto-import-keys refresh -f \
    && zypper install -l -y wget xz git \
    && wget --progress=dot:giga https://arm.sero.gic.ericsson.se/artifactory/proj-adp-cicd-3PP-deps-generic-local/nodejs/node-${NODE_VERSION}-linux-x64.tar.xz \
    && xz -d -v node-${NODE_VERSION}-linux-x64.tar.xz \
    && mkdir -p /opt/node \
    && tar xf node-${NODE_VERSION}-linux-x64.tar -C /opt/node \
    && rm node-${NODE_VERSION}-linux-x64.tar \
    && ln -s /opt/node/node-${NODE_VERSION}-linux-x64 /opt/node/latest \
    && zypper rm -y wget xz \
    && zypper clean --all \
    && zypper rr COMMON_BASE_OS_SLES_REPO ADP_DEV_BUILD_ENV_REPO

ENV PATH=${PATH}:/opt/node/latest/bin

RUN npm install -g npm@"${NPM_VERSION}" --registry "${NPM_REGISTRY}" \
    && npm install -g yarn@"${YARN_VERSION}" --registry "${NPM_REGISTRY}"