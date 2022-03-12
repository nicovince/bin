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
