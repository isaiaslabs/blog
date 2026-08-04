#!/usr/bin/env bash
set -euo pipefail

HUGO_VERSION=0.123.7
HUGO_CACHEDIR="${PWD}/.cache/hugo"

main() {
  export HUGO_CACHEDIR

  build_temp_dir=$(mktemp -d)
  mkdir -p "${HOME}/.local"

  echo "Installing Hugo ${HUGO_VERSION}..."
  curl -sfL --output-dir "${build_temp_dir}" -O "https://github.com/gohugoio/hugo/releases/download/v${HUGO_VERSION}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  mkdir -p "${HOME}/.local/hugo"
  tar -C "${HOME}/.local/hugo" -xf "${build_temp_dir}/hugo_${HUGO_VERSION}_linux-amd64.tar.gz"
  export PATH="${HOME}/.local/hugo:${PATH}"

  echo "Configuring Git..."
  git config --global core.quotepath false

  if [[ $(git rev-parse --is-shallow-repository) == true ]]; then
    git fetch --unshallow
  fi

  if [[ -f .gitmodules ]]; then
    git submodule update --init --recursive
  fi

  echo "Building the project..."
  hugo build --gc --minify

  rm -rf "${build_temp_dir}"
}

main "$@"
