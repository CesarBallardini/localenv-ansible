#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive
export APT_LISTCHANGES_FRONTEND=none
export APT_OPTIONS=' -y --allow-downgrades --allow-remove-essential --allow-change-held-packages -o Dpkg::Options::=--force-confdef -o Dpkg::Options::=--force-confold '


export MY_PYTHON_VERSION=3.10.2
export MY_VENV_BASE_DIR="$HOME/venv"
export MY_ANSIBLE_VERSION=5.9.0


install_python_version_with_pyenv() {

  # https://github.com/pyenv/pyenv/wiki#suggested-build-environment
  sudo apt-get install \
    libreadline-dev \
    make \
    build-essential \
    libssl-dev \
    zlib1g-dev \
    libbz2-dev \
    libsqlite3-dev \
    wget \
    curl \
    llvm \
    libncursesw5-dev \
    xz-utils \
    tk-dev \
    libxml2-dev \
    libxmlsec1-dev \
    libffi-dev \
    liblzma-dev \
    ${APT_OPTIONS}


  curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

  cat | tee -a ~/.bashrc <<'EOF'

# pyenv
export PATH="$HOME/.pyenv/bin:$PATH"
eval "$(pyenv init --path)"
eval "$(pyenv virtualenv-init -)"

EOF

  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"

  # install Python version requested
  pyenv install ${MY_PYTHON_VERSION}
  pyenv local ${MY_PYTHON_VERSION}

}


pip_virtualenv_install() {
  sudo apt-get install python3-pip -y
  pip3 install virtualenv
  export PATH=/home/vagrant/.local/bin:$PATH
}


create_ansible_virtualenv() {

  ansible_version=$1
  virtualenv_dir="${MY_VENV_BASE_DIR}/ansible-${ansible_version}"

  if [ -d "${virtualenv_dir}" ]
  then
    echo "venv directory exists: ${virtualenv_dir}" 2>&1
    exit 1
  else
    mkdir -p "${virtualenv_dir}"
  fi

  rm -f "${virtualenv_dir}"/requirements.txt
  cat | tee -a "${virtualenv_dir}"/requirements.txt <<EOF
pip
ansible==$ansible_version
ansible-lint
EOF



  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init --path)"
  eval "$(pyenv virtualenv-init -)"
  pyenv local ${MY_PYTHON_VERSION}

  virtualenv -p $(which python3) "${virtualenv_dir}"

  "${virtualenv_dir}"/bin/python3 -m  pip install pip --upgrade --ignore-installed
  "${virtualenv_dir}"/bin/python3 -m  pip install -r "${virtualenv_dir}"/requirements.txt --ignore-installed


}


##
# main
#
# some needful things:
sudo apt-get install git mc vim tree screen ${APT_OPTIONS}

install_python_version_with_pyenv
pip_virtualenv_install
create_ansible_virtualenv "${MY_ANSIBLE_VERSION}"

