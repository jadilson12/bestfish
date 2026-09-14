# Command aliases. Every command is defined exactly once - a later alias for the
# same name silently replaces the earlier one, which used to drop flags here.
#
# In fish an alias *is* a function, and `alias ls='ls ...'` is expanded to
# `command ls ...` automatically, so the self-reference is not a recursion trap.
# Wrapped in `status is-interactive` because aliases are only ever typed.

status is-interactive; or exit 0

# MODIFIED COMMANDS {{{
alias df 'df -h'
alias du 'du -c -h'
alias mkdir 'mkdir -p -v'
alias more less
alias nano 'nano -w'
alias c clear

# free is procps, so it exists on Linux only. macOS would need vm_stat, which
# reports pages rather than megabytes and is not a drop-in replacement.
type -q free; and alias free 'free -m' # show sizes in MB

# colordiff is optional, fall back to plain diff when it is missing.
type -q colordiff; and alias diff colordiff
#}}}

# LISTING {{{
# BSD ls (macOS) has no --color: the flag is -G, and it rejects the long form
# outright rather than ignoring it. Homebrew's coreutils installs GNU ls as
# `gls`, which is preferred when present so the GNU flags work everywhere.
if type -q gls
    alias ls 'gls -hF --color=auto'
else if is_macos
    alias ls 'ls -hFG'
else
    alias ls 'ls -hF --color=auto'
end

alias ll 'ls -alh'
alias la 'll -A'
alias lr 'ls -R'    # recursive ls
alias lm 'la | less' # paged ls

# dir and vdir are GNU coreutils; macOS ships neither.
type -q dir; and alias dir 'dir --color=auto'
type -q vdir; and alias vdir 'vdir --color=auto'
#}}}

# GREP {{{
# -d skip keeps grep from erroring out when a directory is passed by mistake.
# fgrep/egrep are deprecated in GNU grep 3.8+, so they map onto grep -F/-E
# instead of the standalone binaries, which avoids the deprecation warning.
alias grep 'grep --color=auto -d skip'
alias fgrep 'grep -F --color=auto -d skip'
alias egrep 'grep -E --color=auto -d skip'
#}}}

# TYPOS {{{
alias exho echo
#}}}

# SHORTCUTS {{{
alias gcp 'git cherry-pick'

function fishrc --description 'Open the fish configuration in your editor'
    # fish forbids a command substitution in command position, so the editor
    # goes through a variable.
    set -l editor (_bestfish_editor code)
    $editor $__fish_config_dir/config.fish
end
#}}}

# PACMAN ALIASES {{{
if is_arch
    # Without root, every pacman call needs sudo. Bash needed the
    # `alias sudo='sudo '` trick for the aliases below to still expand; fish
    # aliases are functions, so pacupg calls the pacman *function* and picks up
    # the sudo on its own.
    if not is_root
        # sudo runs with env_reset, so OMARCHY_ALLOW_DIRECT_PACMAN exported in
        # 10-env.fish would never reach the ALPM guard hook running as root -
        # which is exactly why omarchy documents the bypass as
        # `sudo env OMARCHY_ALLOW_DIRECT_PACMAN=1 pacman -Syu`. Propagating it
        # here keeps that variable as the single switch: set, and pacupg runs
        # straight through; unset, and the guard is back.
        function pacman --description 'pacman under sudo, carrying the omarchy guard opt-out'
            if set -q OMARCHY_ALLOW_DIRECT_PACMAN
                sudo env OMARCHY_ALLOW_DIRECT_PACMAN=$OMARCHY_ALLOW_DIRECT_PACMAN pacman $argv
            else
                sudo pacman $argv
            end
        end
    end
    alias pacupg 'pacman -Syu'        # Synchronize with repositories and upgrade out of date packages
    alias pacupd 'pacman -Sy'         # Refresh all package lists after updating /etc/pacman.d/mirrorlist
    alias pacin 'pacman -S'           # Install specific package(s) from the repositories
    alias pacinu 'pacman -U'          # Install specific local package(s)
    alias pacind 'pacman -S --asdeps' # Install given package(s) as dependencies of another package
    alias pacre 'pacman -R'           # Remove package(s), keeping configuration and required dependencies
    alias pacun 'pacman -Rcsn'        # Remove package(s), their configuration and unneeded dependencies
    alias pacinfo 'pacman -Si'        # Display information about a given package in the repositories
    alias pacse 'pacman -Ss'          # Search for package(s) in the repositories
    alias pacclean 'pacman -Sc'       # Delete all not currently installed package files
    alias pacmake 'makepkg -fcsi'     # Make package from the PKGBUILD file in the current directory

    # A function rather than an alias: fish has no ${EDITOR:-vim} expansion.
    function changemirror --description 'Edit the pacman mirrorlist'
        set -l editor (_bestfish_editor vim)
        sudo $editor /etc/pacman.d/mirrorlist
    end
end
#}}}

# PRIVILEGED ACCESS {{{
if not is_root
    # `alias sudo='sudo '` is deliberately not ported. The trailing space was a
    # bash-only trick to make the next word expand as an alias; fish resolves
    # `sudo foo` to the foo *binary* no matter what, so the alias would buy
    # nothing and only hide sudo's own completions.
    alias scat 'sudo cat'
    alias svim 'sudo vim'
    alias root 'sudo su'
    alias reboot 'sudo reboot'
    alias halt 'sudo halt'
end
#}}}
