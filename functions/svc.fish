function svc --description 'Service wrapper: svc <action> <unit>'
    if test (count $argv) -lt 2
        echo "Usage: svc <start|stop|restart|status|enable|disable> <unit>" >&2
        return 1
    end

    set -l action $argv[1]
    set -l unit $argv[2]

    # systemd: the .service suffix is optional.
    if type -q systemctl
        string match -q '*.*' -- $unit; or set unit $unit.service
        sudo systemctl $action $unit
        return
    end

    # macOS. `brew services` is the closest equivalent that shares these verbs;
    # it wraps launchctl and manages the plist for you, which raw launchctl does
    # not. It must NOT run under sudo - that would manage the service for root
    # instead of for you, and brew refuses outright.
    if type -q brew
        switch $action
            case status
                set action info
            case enable
                # brew services has no enable/disable split: `start` both runs
                # the service now and registers it to run at login.
                set action start
            case disable
                set action stop
        end
        brew services $action $unit
        return
    end

    echo "svc: neither systemctl nor brew found - no service manager to drive" >&2
    return 1
end
