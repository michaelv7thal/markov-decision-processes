FROM mcr.microsoft.com/devcontainers/base:ubuntu

# Install system dependencies
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
  && apt-get -y install --no-install-recommends \
  build-essential \
  curl \
  ca-certificates \
  git \
  gnupg \
  lsb-release \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get install -y nodejs \
  && npm install -g npm@latest

# Install Python 3.12 (default in Ubuntu Noble)
RUN apt-get update && apt-get install -y \
  python3 \
  python3-venv \
  python3-pip \
  && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Install uv (fast Python package installer)
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.cargo/bin:${PATH}"

# Set working directory
WORKDIR /workspace

# Create vscode user if it doesn't exist
RUN if ! id -u vscode > /dev/null 2>&1; then \
  useradd -m -s /bin/bash vscode && \
  echo "vscode ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers; \
  fi

USER vscode
