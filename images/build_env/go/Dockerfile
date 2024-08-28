
ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles

# CBO PRA version
ARG CBO_VERSION

FROM ${CBO_IMAGE_URL}:${CBO_VERSION}
ARG CBO_VERSION

# CBO ARM BASE URL
ARG ARM_URL="https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local"

ARG GOPATH=/go
ENV GOPATH=${GOPATH}

# GO_SDK Repo
ARG CBO_REPO="$ARM_URL/common_base_os/sles/$CBO_VERSION"
ARG GO_SDK_REPO="$ARM_URL/adp-dev/go-sdk/$CBO_VERSION"
ARG DEV_REPO="$ARM_URL/adp-dev/adp-build-env/$CBO_VERSION"

RUN zypper addrepo --gpgcheck-strict -f $CBO_REPO COMMON_BASE_OS_SLES_REPO  \
    && zypper addrepo --gpgcheck-strict -f $GO_SDK_REPO GO_SDK_REPO \
    && zypper addrepo --gpgcheck-strict -f $DEV_REPO ADP_DEV_BUILD_ENV_REPO \
    && zypper --gpg-auto-import-keys refresh -f \
    && zypper install -l -y go1.19* gcc git make ca-certificates wget xz aaa_base \
    && zypper clean --all \
    && zypper rr COMMON_BASE_OS_SLES_REPO GO_SDK_REPO ADP_DEV_BUILD_ENV_REPO

