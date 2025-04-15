#!/bin/zsh

# Source nvm
[ -s "$HOME/.nvm/nvm.sh" ] && \. "$HOME/.nvm/nvm.sh"

# Read .nvmrc content
NODE_VERSION=$(cat .nvmrc)

# Use nvm to get the path of the specified version
NODE_PATH=$(nvm which "$NODE_VERSION")

# Update the symlink
ln -sf "$NODE_PATH" ~/.node-for-ide

echo "Updated Node.js symlink to version $NODE_VERSION"