# mfontc_home (with oh-my-zsh)

## Basic Installation

_OhMyZsh_ y _mfontc_home_ pueden instalarse ejecutando el siguiente comando en tu terminal:

```shell
cd ; bash -c "$(wget -q -O - --header="Authorization: token <READPROJECT_TOKEN>" "https://api.github.com/repos/DFLabsTechSolutions/mfontc_home/contents/tools/install_zsh.sh" | sed -n '/"content"/p' | sed 's/^.*"content": *"//;s/",.*$//' | sed "s/\\\\n/\\n/g" | base64 -d)"
```

## Upgrade

El siguiente script actualiza tanto el _OhMyZsh_ como el propio _mfontc_home_:

```shell
upgrade_oh_my_zsh_mfontc
```

## Important scripts

### Server basic configuration

El siguiente script permite que nuestros servidores, tanto los _sX.orbys.eu_ como los _fsserver_, tengan un conjunto
básico de aplicaciones y servicios instalados y configurados.

```shell
# As root
~/.mfontc_home/tools/configure_server_for_dflabsts.sh
```