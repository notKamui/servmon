#!/bin/sh

function rollback {
  echo "Rolling back changes..."
  rm -rf /tmp/servmon
  rm -rf ~/.local/bin/servmon
  rm -rf ~/.local/bin/_servmon
  rm -rf ~/services/web-proxy
  echo "Changes have been rolled back."
}

# check if git is installed
if ! [ -x "$(command -v git)" ]; then
  echo 'Error: git is not installed.' >&2
  rollback
  exit 1
fi

# check if docker is installed
if ! [ -x "$(command -v docker)" ]; then
  echo 'Error: docker is not installed.' >&2
  rollback
  exit 1
fi 

# pull the latest version from github
git clone https://github.com/notKamui/servmon /tmp/servmon

# check if the pull was successful
if [ $? -ne 0 ]; then
  echo 'Error: failed to pull the latest version from github.' >&2
  rollback
  exit 1
fi

# copy the executable files to the correct location
mkdir -p ~/.local/bin
cp -f /tmp/servmon/servmon ~/.local/bin/servmon && cp -f /tmp/servmon/_servmon ~/.local/bin/_servmon
if [ $? -ne 0 ]; then
  echo 'Error: failed to copy the executable files to the correct location.' >&2
  rollback
  exit 1
fi

echo "Servmon has been updated successfully."

# create the services folder
mkdir ~/services

# copy the web proxy docker configuration
cp -rf /tmp/servmon/web-proxy ~/services/web-proxy
if [ $? -ne 0 ]; then
  echo 'Error: failed to copy the web proxy docker configuration.' >&2
  rollback
  exit 1
fi

echo "Web proxy has been installed successfully."

# get the current shell
CURRENT_SHELL=$(echo $SHELL | awk -F'/' '{print $3}')

# check if ~/.local/bin is in PATH, if not, append it to the user's profile depending on the current shell
case $CURRENT_SHELL in
  "bash")
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
      echo '~/.local/bin has been added to PATH.'
    fi
    ;;
  "zsh")
    if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
      echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
      echo '~/.local/bin has been added to PATH.'
    fi
    ;;
  *)
    echo "Unsupported shell: $CURRENT_SHELL, you need to add '~/.local/bin' to your PATH yourself."
    ;;
esac

# append servmon completion to user's profile depending on the current shell
case $CURRENT_SHELL in
  "bash")
    echo "" >> ~/.bashrc
    echo "[ -s "~/.local/bin/_servmon" ] && source "~/.local/bin/_servmon"" >> ~/.bashrc
    echo "Servmon autocompletion has been added to your shell."
    ;;
  "zsh")
    echo "" >> ~/.zshrc
    echo "[ -s "~/.local/bin/_servmon" ] && source "~/.local/bin/_servmon"" >> ~/.zshrc
    echo "Servmon autocompletion has been added to your shell."
    ;;
  *)
    echo "Unsupported shell: $CURRENT_SHELL, you need to source '~/.local/bin/_servmon' yourself to get autocompletion."
    ;;
esac

# remove the temporary folder
rm -rf /tmp/servmon

echo "Servmon has been installed successfully. Please restart your shell to apply the changes."
