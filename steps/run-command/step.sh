#!/bin/bash
set -xeuo pipefail

# Variables
COMMAND=$(ni get -p '{.command}')
[ "$COMMAND" ] || COMMAND="test"
PACKAGE_FOLDER=$(ni get -p '{.packageFolder}')
[ "$PACKAGE_FOLDER" ] || PACKAGE_FOLDER="./"
FLAGS=$(ni get | jq -j 'try .flags | to_entries[] | "--\( .key ) \( .value ) "')
NODE_VERSION_TO_INSTALL=$(ni get -p '{.nodeVersion}')

echo "nodeVersion: ${NODE_VERSION_TO_INSTALL}"
echo "command: ${COMMAND}"
echo "flags: ${FLAGS}"
echo "git.repository: $(ni get -p '{.git.repository}')"
echo "packageFolder: ${PACKAGE_FOLDER}"

# NPM credentials (required for commands like `publish`)
export NPM_TOKEN=$(ni get -p '{.npm.token}')

# Clone git repository and cd into it
GIT=$(ni get -p '{.git}')
if [ -n "${GIT}" ]; then
  ni git clone
  NAME=$(ni get -p '{.git.name}')
  DIRECTORY=/workspace/${NAME}

  cd ${DIRECTORY}
else
  ni log fatal "git settings are required to run an NPM step"
fi

cd ${PACKAGE_FOLDER}

# Install a different version of Node.js if version specified
if [ -n "${NODE_VERSION_TO_INSTALL}" ]; then
  echo "Node.js version ${NODE_VERSION_TO_INSTALL} specified. Using nvm to install..."

  # Install nvm
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/master/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

  if [ "${NODE_VERSION_TO_INSTALL}" = "auto" ]; then
    nvm install
    nvm use
  else
    nvm install "${NODE_VERSION_TO_INSTALL}"
    nvm use "${NODE_VERSION_TO_INSTALL}"
  fi
fi

# Update npm credentials
if [ -n "${NPM_TOKEN}" ]; then
  npm config set '//registry.npmjs.org/:_authToken' "${NPM_TOKEN}"
  # printf "\n//registry.npmjs.org/:_authToken=\${NPM_TOKEN}" >> ./.npmrc
fi

# Install npm dependencies
npm install --unsafe-perm

git diff

# Output
npm ${COMMAND} ${FLAGS}
