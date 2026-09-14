# Platform detection. Every helper defined here is consumed by the other
# modules, so this file is named to sort first in conf.d/.
#
# Bash used string flags (`_isarch=true`) tested with `if $_isarch`. Fish has no
# booleans, so the flags became predicate functions instead: `if is_arch`. The
# two values that cost a fork - `uname` and `id` - are resolved once, here, and
# cached, exactly like the original did at source time.

set -g __bestfish_os (uname -s)
set -g __bestfish_uid (id -u)

# Running on Linux?
function is_linux --description 'True when running on Linux'
    test "$__bestfish_os" = Linux
end

# Running on macOS?
function is_macos --description 'True when running on macOS'
    test "$__bestfish_os" = Darwin
end

# Running on Arch Linux (or a derivative)?
function is_arch --description 'True when running on Arch Linux or a derivative'
    test -f /etc/arch-release
end

# Is there a graphical session attached? Covers X11, Wayland and Aqua.
function is_x_running --description 'True when a graphical session is attached (X11/Wayland/Aqua)'
    # macOS has no DISPLAY: the GUI session is the one launchd calls "Aqua",
    # which is what distinguishes a Terminal.app shell from an ssh one.
    if is_macos
        test (launchctl managername 2>/dev/null) = Aqua
        return
    end
    test -n "$DISPLAY"; or test -n "$WAYLAND_DISPLAY"
end

# Running as root? Used to decide whether commands need to be wrapped in sudo.
function is_root --description 'True when the shell runs as root'
    test "$__bestfish_uid" -eq 0
end
