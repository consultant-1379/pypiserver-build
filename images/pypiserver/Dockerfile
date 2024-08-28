#
# COPYRIGHT Ericsson 2023
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles
ARG PYPI_SERVER=https://arm.sero.gic.ericsson.se/artifactory/api/pypi/pypi-remote/simple

# CBO PRA version
ARG CBO_VERSION
ARG BUILD_DATE
ARG IMAGE_TAG
ARG CI_USER
ARG ARM_API_TOKEN
ARG COMMIT
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG PYPISERVER_VERSION


ARG PY_BUILD_ENV_IMG=lib-manager-py-build-env
ARG APP_VERSION
ARG ARM_URL="https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local"
#COMMON_BASE_OS_REPO_VERSION set to older CBOS version due to non-compatability gevent 
ARG COMMON_BASE_OS_REPO_VERSION=5.25.0-18
ARG CBO_REPO="$ARM_URL/common_base_os/sles/$COMMON_BASE_OS_REPO_VERSION"
ARG DEV_REPO="$ARM_URL/adp-dev/adp-build-env/$CBO_VERSION"

FROM ${CBO_IMAGE_URL}:${CBO_VERSION} AS cbo_base

ARG CBO_VERSION
ARG PYTHON3_PKG_VERSION
ARG USER_UID_GID=10000

ARG CBO_REPO
ARG DEV_REPO


RUN zypper addrepo --gpgcheck-strict -f $CBO_REPO COMMON_BASE_OS_SLES_REPO  \
    && zypper --gpg-auto-import-keys refresh -f \
    && zypper install -l -y python310 python310-pip \
    && zypper clean --all \
    && ln -s /usr/bin/python3.10 /usr/bin/python3   \
    && ln -s /usr/bin/python3.10 /usr/bin/python   \
    && zypper rr COMMON_BASE_OS_SLES_REPO \
    && set -ex                                                      \
    #&& python -m pip install --upgrade --no-cache-dir wheel         \
    #&& python -m pip install --upgrade --no-cache-dir setuptools     \
    echo "$USER_UID_GID:x:$USER_UID_GID:$USER_UID_GID::/home/pypi:/bin/bash" >> /etc/passwd; \
    echo "$USER_UID_GID:x:$USER_UID_GID:" >> /etc/group;                            \
    mkdir -p /home/pypi;                                          \
    chown $USER_UID_GID:$USER_UID_GID /home/pypi                  \
    && mkdir -p /data/packages                                        \
    && chown $USER_UID_GID:0 /home/pypi                                \
    && chown -R $USER_UID_GID:0 /data/packages


####################################################################################################

FROM cbo_base AS builder_dependencies

ARG PYPI_SERVER

WORKDIR /home/pypi/code


COPY ./images/pypiserver/requirements.txt .
COPY ./build/stdout-redirect /tmp/

RUN mkdir /install \
    && if [ -z "$PYPI_SERVER" ] ; then echo PypiServer is not set; exit 1; fi \
    && python3 -m pip install -i ${PYPI_SERVER}\
        --no-warn-script-location \
        --prefix=/install \
        --requirement requirements.txt
    #&& sed -i -e '$apypiserver=${PYPISERVER_VERSION}' filename

# Install pypiserver
# - do this separately from deps so that when developing, every change does not
#   require reinstalling deps
# COPY pypiserver pypiserver
# COPY setup.cfg .
# COPY setup.py .
# COPY README.rst .
#RUN python3 -m pip install --no-warn-script-location --prefix=/install .

####################################################################################################

FROM cbo_base AS pypiserver

ARG PYPISERVER_VERSION
ARG BUILD_DATE
ARG COMMIT
ARG RSTATE
ARG IMAGE_PRODUCT_NUMBER
ARG IMAGE_PRODUCT_TITLE
ARG APP_VERSION

LABEL org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="pypiserver" \
    com.ericsson.product-3pp-version=${PYPISERVER_VERSION}

WORKDIR /data

COPY --from=builder_dependencies --chown=$USER_UID_GID /install /usr/local
COPY --from=builder_dependencies --chown=$USER_UID_GID /tmp/stdout-redirect /usr/local/bin/stdout-redirect


RUN chown -R "$USER_UID_GID":"$USER_UID_GID" /data/packages
RUN chmod -R g+rw /data/packages

VOLUME /data/packages

ENV PATH=${PATH}:/home/pypi

USER $USER_UID_GID

EXPOSE 8080

ENTRYPOINT ["pypi-server"]

####################################################################################################