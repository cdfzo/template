#!/usr/bin/env bash
version=$(jq -r '.version' package.json)

# Only create release if version changed
[[ $version == $(git describe --tags --abbrev=0) ]] && exit

# Pre-release
[[ $version =~ '-|^0' ]] && preRelease='-p'

# Release on GitHub
if [[ -n $GH_TOKEN ]]; then
  if [[ $(jq -r '.scripts["build:bin"]' package.json) != 'null' ]]; then
    assets=$ASSET_NAME-$version.zip
    bun build:bin
    zip -r $assets dist/*
  fi

  notes='See [CHANGELOG.md](/CHANGELOG.md) for details'
  gh release create v$version -t v$version -n "$notes" $preRelease $assets
fi

# Publish to npm
if [[ -n $NPM_TOKEN ]]; then
  echo '//registry.npmjs.org/:_authToken=${NPM_TOKEN}' > .npmrc
  npm publish
fi
