# Environment variables: PATH, shell history and SDK locations.
#
# Not guarded by `status is-interactive`: PATH and SDK variables have to be
# right for scripts and editors that spawn a non-interactive fish too.

# HOMEBREW {{{
# Runs before the PATH block so the entries prepended below still outrank brew.
#
# Called through an absolute path on purpose: on Apple Silicon /opt/homebrew/bin
# is not on the default PATH, so `brew` is not findable until shellenv has run.
# The shell is passed explicitly - `brew shellenv fish` - rather than letting
# brew guess from $SHELL, which is wrong whenever fish is not the login shell.
#
# shellenv also sets MANPATH and INFOPATH, which is why this is worth doing
# instead of just adding the bin directory by hand.
for brew_prefix in /opt/homebrew /usr/local /home/linuxbrew/.linuxbrew $HOME/.linuxbrew
    if test -x $brew_prefix/bin/brew
        $brew_prefix/bin/brew shellenv fish | source
        break
    end
end
#}}}

# PATH {{{
# `fish_add_path -gpP` replaces the hand written _prepend_path/_append_path
# helpers: it refuses to add a duplicate, so re-sourcing never grows PATH.
#   -g  set it as a global variable, not a universal one - a universal
#       fish_user_paths would persist behind this repository's back
#   -P  operate on $PATH itself, the way the bash version did
#   -p / -a  prepend / append
#
# fish_add_path happily adds directories that do not exist, so the `test -d`
# guard from the original stays.
#
# Prepending one at a time, in this order, keeps the resulting priority
# identical to bash: ~/.local/bin, then ~/bin, then /usr/local/bin.
for dir in /usr/local/bin $HOME/bin $HOME/.local/bin
    test -d $dir; and fish_add_path -gpP $dir
end
#}}}

# SHELL HISTORY {{{
# Nothing to port. HISTSIZE/HISTFILESIZE/HISTCONTROL/HISTIGNORE are bash
# variables; fish reads none of them and already does most of what they bought:
#
#   HISTSIZE=100000        fish history is unbounded
#   HISTCONTROL=ignoreboth fish drops commands prefixed with a space and
#                          deduplicates on recall
#   HISTIGNORE='ls:cd:...' no equivalent - fish stores everything and relies on
#                          deduplication plus prefix search instead
#
# The history file is ~/.local/share/fish/fish_history. To keep a shell out of
# it entirely, start it with `fish --private`.
#}}}

# MISE {{{
# Replaces the NVM block from bestbash. nvm is a bash function - neither
# /usr/share/nvm/init-nvm.sh nor ~/.nvm/nvm.sh can be sourced from fish - and
# mise already manages node, java, npm, yarn and the rest here, so there is
# nothing left for nvm to do.
#
# `mise activate` is the interactive integration: it hooks the prompt so the
# tool versions follow the directory you are in. Non-interactive shells get the
# shims on PATH instead, which is what mise recommends for scripts and editors.
#
# The mise package ships its own vendor snippet - /usr/share/fish/vendor_conf.d/
# mise-activate.fish on Arch, the same under $HOMEBREW_PREFIX on macOS - which
# activates unconditionally, with no interactive/shims split. fish runs user
# conf.d before vendor conf.d (by directory, regardless of filename), so setting
# its documented opt-out here lands in time to stop it and keeps a single
# activation, on our terms.
# The opt-out is set unconditionally, outside the `type -q` guard: when mise is
# gone but the vendor snippet is left behind, the vendor file still tries to run
# it and every shell starts with an `Unknown command: mise` error.
set -g MISE_FISH_AUTO_ACTIVATE 0

if type -q mise
    if status is-interactive
        mise activate fish | source
    else
        mise activate fish --shims | source
    end
end
#}}}

# OMARCHY {{{
# OMARCHY_PATH is the variable that turns omarchy on: ~/.config/hypr/hyprland.lua
# and the omarchy-* commands all resolve their trees through it.
#
# Upstream exports it from /usr/share/omarchy/default/bash/env-bootstrap, which
# is sourced by /etc/profile.d/omarchy.sh, /etc/skel/.bashrc and the uwsm
# session - all bash, none of which fish ever reads. A terminal opened inside
# the Hyprland session inherits the variable from uwsm, so it looks set; a
# `ssh host fish` or a bare login fish does not get it. This block is the fish
# half of that bootstrap.
if test -d /usr/share/omarchy
    set -gx OMARCHY_PATH /usr/share/omarchy

    # /etc/omarchy.conf is written by `omarchy dev link` to point at a source
    # checkout, as `export OMARCHY_PATH="<path>"`. When it is absent the
    # packaged default wins - upstream deliberately does not keep a stale
    # inherited value.
    if test -r /etc/omarchy.conf
        set -l configured (string replace -rf '^\s*(?:export\s+)?OMARCHY_PATH=' '' </etc/omarchy.conf | string trim | string trim -c '"' | string trim -c "'")
        test -n "$configured"; and set -gx OMARCHY_PATH $configured
    end

    # Only prepend in dev-link mode. On a production install the binaries are
    # already on PATH as /usr/bin/omarchy-*, so this would just be noise.
    test "$OMARCHY_PATH" != /usr/share/omarchy; and fish_add_path -gpP $OMARCHY_PATH/bin

    # Opt out of the omarchy pacman guard - the ALPM pre-transaction hook that
    # aborts a direct `pacman -Syu` to push you towards `omarchy update`.
    #
    # Worth knowing what you give up: `omarchy update` also handles the update
    # transcript, snapshot, keyrings, migrations, post-update hooks and restart
    # checks. Unset this to get the guard back.
    #
    # Exporting it here is not enough on its own: sudo runs with env_reset, so
    # the variable never reaches the hook running as root. The pacman alias in
    # 20-aliases.fish propagates it with `sudo env`, which is what makes it bite.
    set -gx OMARCHY_ALLOW_DIRECT_PACMAN 1
end
#}}}

# CHROME {{{
# Karma and other headless test runners look for $CHROME_BIN. On macOS Chrome
# ships as an app bundle and the binary is not on PATH, so it is located by
# path rather than with `type -q`.
if type -q google-chrome-stable
    set -gx CHROME_BIN /usr/bin/google-chrome-stable
else if test -x "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
    set -gx CHROME_BIN "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
end
#}}}

# ANDROID SDK {{{
# The SDK lands in ~/Library/Android/sdk on macOS and ~/Android/Sdk on Linux.
for sdk in $HOME/Android/Sdk $HOME/Library/Android/sdk
    if test -d $sdk
        set -gx ANDROID_HOME $sdk
        set -gx ANDROID_SDK_ROOT $ANDROID_HOME
        for dir in $ANDROID_HOME/emulator $ANDROID_HOME/tools $ANDROID_HOME/tools/bin $ANDROID_HOME/platform-tools
            test -d $dir; and fish_add_path -gaP $dir
        end
        break
    end
end
#}}}

# ORACLE INSTANT CLIENT {{{
# Linux only. macOS would need DYLD_LIBRARY_PATH instead, and System Integrity
# Protection strips DYLD_* from protected binaries anyway, so an Instant Client
# on a Mac belongs in conf.d/99-local.fish next to whatever tool actually needs
# it.
set -l oracle_client /opt/oracle/instantclient_21_9
if test -d $oracle_client
    # `--path` makes fish treat LD_LIBRARY_PATH as a colon separated list, so it
    # can be prepended as a list and stays a plain string for child processes.
    # The `contains` check is the idempotency the bash version lacked: sourcing
    # it twice in one shell used to stack the same directory up again.
    set -gx --path LD_LIBRARY_PATH $LD_LIBRARY_PATH
    contains -- $oracle_client $LD_LIBRARY_PATH
    or set -gx --path LD_LIBRARY_PATH $oracle_client $LD_LIBRARY_PATH

    set -gx DIAG_ADR_ENABLED OFF # do not write diagnostic dumps next to the app
end
#}}}
