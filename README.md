# dotfiles
I'm using oh-my-zsh and custom zsh scripts. 
All files and dirs that should be linked into the home-folder have the following naming convention:

    "file.symlink"

or

    "dir.symlink"

## setup
To create symlinks simply execute:
    
    setup/bootstrap

Perhaps you have to execute

    git submodule init

## structure
In order to sepearte configuration and aliases belonging to different appliations, each application gets it own subfolder. For example "php" inside of application folders there are the following naming conventions:

- aliases.zsh - used for aliases
- config.zsh

System configurations like PATH variable are initialized inside of:
    
    system/path.zsh


