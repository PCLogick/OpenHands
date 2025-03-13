# syntax=docker/dockerfile:1

###
FROM ubuntu:22.04 AS dind

# https://docs.docker.com/engine/install/ubuntu/
RUN apt-get update && apt-get install -y \
	ca-certificates \
	curl \
	&& install -m 0755 -d /etc/apt/keyrings \
	&& curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc \
	&& chmod a+r /etc/apt/keyrings/docker.asc \
	&& echo \
		"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
		$(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

RUN apt-get update && apt-get install -y \
	docker-ce \
	docker-ce-cli \
	containerd.io \
	docker-buildx-plugin \
	docker-compose-plugin \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean \
	&& apt-get autoremove -y

###
FROM dind AS openhands

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

#
RUN apt-get update && apt-get install -y \
	bash \
    build-essential \
    curl \
	git \
	git-lfs \
	software-properties-common \
	make \
    netcat \
    sudo \
	wget \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean \
	&& apt-get autoremove -y

# https://github.com/cli/cli/blob/trunk/docs/install_linux.md
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
	&& echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
	&& apt-get update && apt-get -y install \
    gh \
  && rm -rf /var/lib/apt/lists/* \
  && apt-get clean \
  && apt-get autoremove -y

# Python 3.12
RUN add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update \
    && apt-get install -y python3.12 python3.12-venv python3.12-dev python3-pip \
    && ln -s /usr/bin/python3.12 /usr/bin/python

# NodeJS >= 22.x
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs

# Install Playwright dependencies
RUN apt-get update && apt-get install -y \
    libnss3 \
    libnspr4 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libcups2 \
    libdrm2 \
    libxkbcommon0 \
    libxcomposite1 \
    libxdamage1 \
    libxfixes3 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libpango-1.0-0 \
    libcairo2 \
    fonts-liberation \
    libappindicator3-1 \
    libxtst6 \
    xvfb \
    xauth \
    libgconf-2-4 \
    libxss1 \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean \
    && apt-get autoremove -y

# Poetry >= 1.8
RUN curl -fsSL https://install.python-poetry.org | python3.12 - \
    && ln -s /root/.local/bin/poetry /usr/local/bin/poetry

# Create version.sh script
RUN printf '#!/bin/bash\nset +x\nuname -a\ndocker --version\ngh --version | head -n 1\ngit --version\n#\npython --version\necho node $(node --version)\necho npm $(npm --version)\npoetry --version\nnetcat -h 2>&1 | head -n 1' > /version.sh && chmod a+x /version.sh

###
FROM openhands AS dev

RUN apt-get update && apt-get install -y \
	dnsutils \
	file \
	iproute2 \
	jq \
	lsof \
	ripgrep \
	silversearcher-ag \
	vim \
	&& rm -rf /var/lib/apt/lists/* \
	&& apt-get clean \
	&& apt-get autoremove -y

WORKDIR /app

# Install global npm packages
RUN npm install -g npm@latest

# Skip frontend dependencies during build
RUN --mount=type=bind,source=./,target=/app/ \
    bash -c 'cd /app && \
    make -s clean && \
    make -s check-dependencies && \
    make -s install-python-dependencies'

# Add a script to install frontend dependencies at runtime
RUN printf '#!/bin/bash\n\
cd /app\n\
# Ensure cache directories exist with proper permissions\n\
mkdir -p /root/.cache && chmod -R 777 /root/.cache\n\
mkdir -p /app/cache && chmod -R 777 /app/cache\n\
# Install Playwright if not already installed\n\
if [ ! -f /app/cache/playwright_installed ]; then\n\
    poetry run playwright install --with-deps chromium\n\
    touch /app/cache/playwright_installed\n\
fi\n\
# Install frontend dependencies\n\
make -s install-frontend-dependencies\n\
exec "$@"' > /docker-entrypoint.sh && chmod +x /docker-entrypoint.sh

ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["bash"]
