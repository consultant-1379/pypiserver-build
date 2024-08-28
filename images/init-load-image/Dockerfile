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

ARG COMMON_BASE_OS_VERSION
FROM armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles:$COMMON_BASE_OS_VERSION

LABEL org.opencontainers.image.title=$IMAGE_PRODUCT_TITLE \
    org.opencontainers.image.created=$BUILD_DATE \
    org.opencontainers.image.revision=$COMMIT \
    org.opencontainers.image.vendor=Ericsson \
    org.opencontainers.image.version=$APP_VERSION \
    com.ericsson.product-revision=$RSTATE \
    com.ericsson.product-number=$IMAGE_PRODUCT_NUMBER \
    com.ericsson.product-3pp-name="pypiserver" \
    com.ericsson.product-3pp-version=${PYPISERVER_VERSION}

ARG USER_UID_GID=10000

ARG COMMON_BASE_OS_VERSION
ARG PYTHON3_PKG_VERSION
ENV COMMON_BASE_OS_VERSION $COMMON_BASE_OS_VERSION
RUN zypper addrepo -C -G -f "https://arm.sero.gic.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/$COMMON_BASE_OS_VERSION?ssl_verify=no" COMMON_BASE_OS_SLES_REPO; \
    zypper install -l -y python311 python311-pip; \
    zypper clean --all; \
    ln -s /usr/bin/python3.11 /usr/bin/python3; \
    ln -s /usr/bin/python3.11 /usr/bin/python; \
    set -ex;                                                     \
    python3 -m pip install --upgrade --no-cache-dir pip;          \
    python3 -m pip install --upgrade --no-cache-dir wheel;         \
    python3 -m pip install --upgrade --no-cache-dir setuptools;     \
    echo "$USER_UID_GID:x:$USER_UID_GID:$USER_UID_GID::/home/pyuser:/bin/bash" >> /etc/passwd; \
    echo "$USER_UID_GID:x:$USER_UID_GID:" >> /etc/group;                            \
    mkdir -p /home/pyuser;                                          \
    chown $USER_UID_GID:$USER_UID_GID /home/pyuser

ENV PATH=${PATH}:/home/pyuser

WORKDIR /home/pyuser

COPY requirements.txt .

RUN python3 -m pip download --only-binary=:all: --python-version=38  --dest /data/packages --no-cache-dir -r requirements.txt

RUN python3 -m pip download --only-binary=:all: --python-version=39  --dest /data/packages --no-cache-dir -r requirements.txt

RUN python3 -m pip download --only-binary=:all: --python-version=310  --dest /data/packages --no-cache-dir -r requirements.txt

RUN python3 -m pip download --only-binary=:all: --python-version=311  --dest /data/packages --no-cache-dir -r requirements.txt

USER $USER_UID_GID


