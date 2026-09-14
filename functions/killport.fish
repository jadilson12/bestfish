function killport --description 'Kill whatever is listening on a TCP port'
    if test (count $argv) -eq 0
        echo "Usage: killport <port>" >&2
        return 1
    end

    if type -q fuser
        sudo fuser -k $argv[1]/tcp
    else
        set -l pids (sudo lsof -t -i:$argv[1])
        test -n "$pids"; and sudo kill $pids
    end
end
