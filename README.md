## What to do after upgrade
- Yabai: replace hash
```
sudo visudo -f /private/etc/sudoers.d/yabai

#  replace <hash> with the sha256 hash of the yabai binary (output of: shasum -a 256 $(which yabai)).

<user> ALL=(root) NOPASSWD: sha256:<hash> <yabai> --load-sa
```

## Switch node version
```sh 
nvm ls 
nvm use ...
```

## What to do after restart
- Do this if yabai laggy
```sh 
sudo yabai --load-sa
yabai --restart-service
```

## TODO
- [ ] nvim config NvChad
    - [ ] for todo
    - [ ] for coding
    - [ ] NvChad change tab to accept, Ctrl P and Ctrl N to move suggestion
- [x] Alacritty
    - [x] map Cmd to Ctrl
        - [x] Ctrl C, Copy, paste, Ctrl R, Ctrl T (fzf)

