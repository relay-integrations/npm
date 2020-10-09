#!/bin/bash
set -euo pipefail

# NPM credentials (required for commands like `publish`)
NPM_TOKEN=$(ni get -p '{.npm.token}')
ORGANIZATION=$(ni get -p '{.npm.organization}')
USER=$(ni get -p '{.user}')
ROLE=$(ni get -p '{.role}')
[ "$ROLE" ] || ROLE="developer"

# Create .npmrc with credentials
if [ -n "${NPM_TOKEN}" ]; then
  echo "//registry.npmjs.org/:_authToken=${NPM_TOKEN}" >> ./.npmrc
fi

npm org set $ORGANIZATION $USER $ROLE
