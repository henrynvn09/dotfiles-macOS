## What to do after upgrade
- Yabai: replace hash
```
echo "$(whoami) ALL=(root) NOPASSWD: sha256:$(shasum -a 256 $(which yabai) | cut -d " " -f 1) $(which yabai) --load-sa" | sudo tee /private/etc/sudoers.d/yabai

# start yabai
yabai --start-service
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

