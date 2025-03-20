#!/bin/sh

set -eo pipefail

VERSION=$1
SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)

if [ -z "$VERSION" ]; then
  echo "Usage: $0 <version>"
  exit 1
fi

echo "Verify code quality"
yarn format
yarn lint
yarn check
yarn workspace demo build

echo "Bump version"
yarn workspace demo version --new-version $VERSION --no-git-tag-version
yarn workspace astro-typewriter version --new-version $VERSION --no-git-tag-version

echo "Commit version"
git add "$SCRIPT_DIR/demo/package.json" "$SCRIPT_DIR/packages/astro-typewriter/package.json"
git commit -m "[FEAT]: update version in package.json"
git tag -a "$VERSION" -m "[RELEASE]: bump version to $VERSION"

echo "Version $VERSION is ready to be pushed"
read -p "Do you want to push the changes? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  git push origin --follow-tags
fi

echo "Done"
echo
echo "Don't forget to MERGE and PUBLLISH the package"
echo "You have to do BOTH manually on GitHub"