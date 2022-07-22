export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Traverse up in directory tree to find folder containing .node-version file
find_node_version_file() {
  local version_file=$1
  local dir="${PWD}"

  while [ "${dir}" != "" ] && [ ! -f "${dir}/${version_file}" ]; do
    dir=${dir%/*}
  done
 
  if [ -e "${dir}/${version_file}" ]; then
    nvm_echo "${dir}/${version_file}"
  fi
}

use_or_install_node_version() {
  local version_file=$1
  local current_node_version=$2

  local file_node_version=$(nvm version "$(cat "${version_file}")")

  if [ "$file_node_version" = "N/A" ]; then
    nvm install "$(cat "${version_file}")"
 #   npm install -g yarn
  elif [ "$file_node_version" != "$current_node_version" ]; then
    nvm use $file_node_version
  fi
}

autoload -U add-zsh-hook
load-nvmrc() {
  local current_node_version="$(nvm version)"
  local nvmrc_path="$(find_node_version_file .nvmrc)"
  local node_version_file_path="$(find_node_version_file .node-version)"

  if [ -n "$nvmrc_path" ]; then
    use_or_install_node_version $nvmrc_path $current_node_version
  elif [ -n "$node_version_file_path" ]; then
    use_or_install_node_version $node_version_file_path $current_node_version
  elif [ "$node_version" != "$(nvm version default)" ]; then
    echo "reverting to nvm default version"
    nvm use default
  fi
}
add-zsh-hook chpwd load-nvmrc
load-nvmrc
