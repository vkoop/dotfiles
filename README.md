# dotfiles
I'm using oh-my-zsh and custom zsh scripts. The concept is based on ideas from:

* https://github.com/holman/dotfiles
* https://github.com/robbyrussell/oh-my-zsh

## setup
To create symlinks simply execute:
    
    setup/setup_with_ruby

or

    setup/setup_with_php


Perhaps you have to execute

    git submodule init
    git submodule update
    
To clone repo with all deps

    git clone --recursive https://github.com/vkoop/dotfiles.git

## structure
In order to sepearte configuration and aliases belonging to different appliations, each application gets it own subfolder. For example "php" inside of application folders there are the following naming conventions:

- aliases.zsh - used for aliases
- config.zsh

System configurations like PATH variable are initialized inside of:
    
    system/path.zsh

All files and dirs that should be linked into the home-folder have the following naming convention:

    "file.symlink"

or

    "dir.symlink"


## how it works
Beside of oh-my-zsh, inside of zshrc zsh-scripts are loaded recursivly from all directories inside of "dotfiles". Scripts inside of "load_excluded" are not loaded seperatily. The folder is used mainly for oh-my-zsh.
