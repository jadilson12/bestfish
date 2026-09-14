function _bit_has_branch --description 'True when a local branch with the given name exists'
    git rev-parse --verify --quiet refs/heads/$argv[1] >/dev/null 2>&1
end
