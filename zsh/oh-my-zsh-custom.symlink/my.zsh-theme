function prompt_char {
    git branch >/dev/null 2>/dev/null && echo '±' && return
    hg root >/dev/null 2>/dev/null && echo '☿' && return
    svn info >/dev/null 2>/dev/null && echo '⚡' && return
    echo '○'
}

if [ $UID -eq 0 ]; then NCOLOR="red"; else NCOLOR="white"; fi

PROMPT='%{$fg[$NCOLOR]%}%B%n%b%{$reset_color%}:%{$fg[blue]%}%B%c/%b%{$reset_color%} $(git_prompt_info)$(svn_prompt_info)$(svn_get_rev_nr)
 ╰─ $(prompt_char) '
RPROMPT='[%*]'

# git prompt styling
ZSH_THEME_GIT_PROMPT_PREFIX="[git:%{$fg_bold[white]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX=""
ZSH_THEME_GIT_PROMPT_CLEAN="%{$reset_color%}] " 
ZSH_THEME_GIT_PROMPT_DIRTY=" %{$fg[red]%}Δ%{$reset_color%}] "

# svn prompt styling
ZSH_THEME_SVN_PROMPT_PREFIX="[svn:%{$fg_bold[cyan]%}"
ZSH_THEME_SVN_PROMPT_SUFFIX=""
ZSH_THEME_SVN_PROMPT_CLEAN="%{$reset_color%}] " 
ZSH_THEME_SVN_PROMPT_DIRTY=" %{$fg[red]%}Δ%{$reset_color%}] "
