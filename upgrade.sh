#!/usr/bin/env bash

set -euo pipefail

function version_of() {
  echo "$(node -e "console.log(require('./package.json')$1)")"
}

LIB_CURRENT="$(version_of '.version')"
LIB_NEXT="$1"
if [[ -z "$LIB_NEXT" ]]; then
  echo "Missing version argument"
  exit 1
fi

BICON_CURRENT="$(version_of ".devDependencies['bootstrap-icons']")"

echo "Upgrading from v$LIB_CURRENT to v$LIB_NEXT..."

yarn upgrade --latest || { echo '`yarn upgrade` failed'; exit 1; }
yarn build || { echo '`yarn build` failed'; exit 1;}

pushd dev-vite
yarn upgrade --latest || { echo '`yarn upgrade` failed'; exit 1; }
popd

BICON_NEXT="$(version_of ".devDependencies['bootstrap-icons']")"

sed -i "s/$LIB_CURRENT/$LIB_NEXT/g" package.json README.md

echo 'Finished.'

if [[ "$BICON_NEXT" != "$BICON_CURRENT" ]]; then
  sed -i "s/$BICON_CURRENT/$BICON_NEXT/g" README.md
  echo "New bootstrap-icons version v$BICON_NEXT."
else
  echo 'bootstrap-icons not upgraded.'
fi

echo 'Run `yarn dev:cdn` and `yarn dev:vite` to make sure everything works.'
