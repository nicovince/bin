# User binaries
## Download

```
git clone https://nicovince@github.com/nicovince/bin.git $HOME/bin
```

Create One branch per machine named `${HOSTNMAME}_bin` or `<company>_bin`

## Hooks
Install `pre-commit`:
```
pip install pre-commit
cd $HOME/bin
pre-commit install --hook-type pre-commit --hook-type commit-msg
```

## Gonzalez:
```
_konsole_dbus_session_name()
{
  echo org.kde.konsole-$(pstree -p -s $(ps | grep $(basename $(echo $0)) | head -1 | awk '{print $1}') | grep -o 'konsole([0-9]\+)' | grep -o '[0-9]\+')
}
gonzalez.py -s $(_konsole_dbus_session_name) ~/.dotfiles/gonzalez_config/vog_zephyr.json
```
