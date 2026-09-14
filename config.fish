# bestfish - entry point.
#
# Unlike bash, fish needs no `source` line to bootstrap this configuration:
# everything under conf.d/ is loaded automatically, in alphabetical order,
# *before* this file runs. The numeric prefixes are what encode the load order
# that init.sh used to spell out by hand:
#
#     conf.d/00-settings.fish   platform detection (is_linux, is_arch, ...)
#     conf.d/10-env.fish        PATH, NVM, SDKs
#     conf.d/20-aliases.fish    command aliases
#     conf.d/99-local.fish      machine specific overrides (untracked)
#
# Functions live in functions/ and are autoloaded on first use, so svc, bit and
# killport cost nothing at startup.
#
# Keep this file for interactive tweaks that are yours alone - prompt, colors,
# greeting. Anything reusable belongs in a conf.d/ module.

if status is-interactive
    # Your interactive settings go here.
end
