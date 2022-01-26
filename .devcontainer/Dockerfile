# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.202.5/containers/alpine/.devcontainer/base.Dockerfile

# [Choice] Alpine version: 3.14, 3.13, 3.12, 3.11
ARG VARIANT="3.14"
FROM mcr.microsoft.com/vscode/devcontainers/base:0-alpine-${VARIANT}

# hadolint ignore=DL3018
RUN apk update \
    && apk add --no-cache \
    python3 \
    py3-pip \
    ruby \
    fish \
    shellcheck \
    # Required to install Black
    python3-dev \
    gcc \
    musl-dev \
    # https://docs.microsoft.com/en-us/powershell/scripting/install/install-alpine?view=powershell-7.1
    ca-certificates \
    less \
    ncurses-terminfo-base \
    krb5-libs \
    libgcc \
    libintl \
    libssl1.1 \
    libstdc++ \
    tzdata \
    userspace-rcu \
    zlib \
    icu-libs \
    curl \
    && apk -X https://dl-cdn.alpinelinux.org/alpine/edge/main add --no-cache \
    lttng-ust

# Make python3 the default python
RUN ln -s /usr/bin/python3 /usr/bin/python

# Install some Python tools
# hadolint ignore=DL3013
RUN pip --disable-pip-version-check --no-cache-dir install \
    autoflake \
    black \
    flake8 \
    isort \
    mypy \
    pylint \
    pydocstyle \
    && rm -rf /tmp/pip-tmp

# Download Elvish
RUN curl -L \
    https://dl.elv.sh/linux-amd64/elvish-HEAD.tar.gz \
    -o /tmp/elvish.tar.gz

# Install Elvish
RUN tar zxf /tmp/elvish.tar.gz -C /tmp \
    && rm -f /tmp/elvish.tar.gz \
    && mv /tmp/elvish-HEAD /usr/bin/elvish \
    && chmod +x /usr/bin/elvish

# Download PowerShell
RUN curl -L \
    https://github.com/PowerShell/PowerShell/releases/download/v7.2.0-preview.10/powershell-7.2.0-preview.10-linux-alpine-x64.tar.gz \
    -o /tmp/powershell.tar.gz

# Install PowerShell
RUN mkdir -p /opt/microsoft/powershell/7 \
    && tar zxf /tmp/powershell.tar.gz -C /opt/microsoft/powershell/7 \
    && rm -f /tmp/powershell.tar.gz \
    && chmod +x /opt/microsoft/powershell/7/pwsh \
    && ln -s /opt/microsoft/powershell/7/pwsh /usr/bin/pwsh
