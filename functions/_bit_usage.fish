function _bit_usage --description 'Print bit usage and return 1'
    echo "Usage: bit [options]"
    echo "  --init                                              # Autoconfigure git options"
    echo "  a, [add] <files> [--all]                            # Add git files"
    echo "  c, [commit] <text> [--undo]                         # Commit staged files, or undo the last commit"
    echo "  C, [cherry-pick] <commit> <url> [branch]            # Cherry-pick a commit from another remote"
    echo "  b, [branch] feature|hotfix|<name>                   # Add/Change Branch"
    echo "  d, [delete] <branch>                                # Delete Branch"
    echo "  l, [log]                                            # Display Log"
    echo "  m, [merge] feature|hotfix|<name> <commit>|<version> # Merge branches"
    echo "  p, [push] <branch>                                  # Push files"
    echo "  P, [pull] <branch> [--force]                        # Pull files"
    echo "  r, [release] <version>                              # Merge unstable branch on master and tag it"
    return 1
end
