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
# Cómo usar una instalación de Virtualenv en un nodo controlado por Ansible

En este caso, el Virtualenv reside en un nodo controlado por Ansible desde un nodo de control.

El nodo de control tiene Ansible instalado de alguna manera.  El nodo controlado tiene Ansible instalado en un Virtualenv.

Las tareas que requieren correr con la versión de Python y las bibliotecas instaladas/referenciadas en el virtualenv del nodo controlado deben 
referir esos detalles. Ejemplos:

```yaml
- name: "Instala paquetes Python con la instancia local de Pip en el nodo controlado"
   shell: "{{virtualenv_path}}/bin/pip3 install package_name"
   become: no
```

Vale notar que para instalar un paquete Python en un virtualenv, no es necesario activar el virtualenv si usamos
la ruta completa de los binarios como `python3`, `pip3`, etc.

y para instalar paquetes referenciados en el proyecto, dentro del Virtualenv: 

```yaml
- name: Instala los requerimientos del proyecto en el virtualenv
  pip:
    requirements: '{{project_path}}/requirements.txt'
    virtualenv: '{{virtualenv_path}}'
    virtualenv_python: python3

```

De la misma manera, se deben instalar roles y colecciones que usará el playbook que corre en el nodo controlado, dentro del virtualenv del nodo controlado

# Qué pasa con los módulos Ansible que se ejecutan en el nodo controlador, y no en el nodo controlado.


Existen módulos que consumen APIs, por ejemplo la gestión de VMs en VMware, Proxmox PVE, etc.  Estos módulos se comunican con el servidor mediante HTTP, por ejemplo.
Esas conexiones HTTP se originan en el nodo controladory llegan hasta un servidor, ninguno de los cuales es en principio el nodo controlado.

Cuando el nodo de control tiene Ansible instalado en un virtualenv, se deben dar dos cosas:
1. los módulos, y colecciones que interactúan con la API deben instalarse en el virtualenv mencionado,
y 2. se debe usar el Python del virtualenv para ejecutar esos módulos.

Se recomienda usar `delegate_to: localhost` para esas tareas, y no `connection: local`.  Delegate hereda las propiedades de conexión del host al cual se delega, por lo tanto
si en el inventario tenemos configurado el intérprete de Python apuntando al virtualenv, ése será el entorno utilizado para correr los módulos ya mencionados.


Los módulos que se ejecutan localmente en el nodo de control, utilizarán el Python que se consigue como *fact* para el nodo *localhost*.
Por eso debemos especificar el virtualenv en esta configuración, en los casos que no se use el Python del sistema.  Eso se hace en 
las variables de inventario, donde para `localhost` usaremos algo como:


* en un playbook

```yaml
- set_fact:
    ansible_python_interpreter: "{{virtualenv_path}}/bin/python"

```

* en las variables de inventario de localhost (ejemplo en archivo formato INI) debe reemplazar la ruta al virtualenv en el nodo controlador:

```yaml
localhost ansible_python_interpreter=/path/to/virtualenv/bin/python
```

# TODO

Dockerizar la instalación usando como base Alpine.

# Referencias

* https://stackoverflow.com/questions/70638759/how-to-activate-python-virtual-environment-on-remote-machine-with-ansible
* http://willthames.github.io/2018/07/01/connection-local-vs-delegate_to-localhost.html una referencia para distinguir entre conexiones locales, y delegar al localhost.
* https://github.com/ansible/ansible/issues/16724 connection: local and ansible_connection result in incorrect python being used

