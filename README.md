# README -- Local environment for Ansible


Elige la versión de Python y de Ansible que necesitas usar.

En `provision/install-python-tools.sh` hay tres variables a personalizar:

```bash

export MY_PYTHON_VERSION=3.10.2
export MY_VENV_BASE_DIR="$HOME/venv"
export MY_ANSIBLE_VERSION=5.9.0

```

* `MY_PYTHON_VERSION` versión de Python a instalar mediante Pyenv.
* `MY_ANSIBLE_VERSION` versión de Ansible a instalar en un Virtualenv
* `MY_VENV_BASE_DIR` el directorio base donde se instalará el Virtualenv con Ansible; 
el directorio del virtualenv es un subdirectorio del base, y su nombre es la versión con el prefijo `ansible-`

Edite el archivo para seleccionar los valores adecuados a su caso y levante la VM con:

```bash
vagrant up
```

Puede ingresar a la VM mediante:

```bash
vagrant ssh
```

Allí activa el virtualenv, que en el caso correspondiente a los valores arriba mancionados sería:

```bash
source ~/venv/ansible-5.9.0/bin/activate
```

y ahora en ese entorno se dispone de:

* `python --version`

```text
Python 3.10.2
```

* `pip list| grep -E "^ansible |^ansible-core"`

```text
ansible          5.9.0
ansible-core     2.12.6
```

# TODO

Dockerizar la instalación usando como base Alpine.

