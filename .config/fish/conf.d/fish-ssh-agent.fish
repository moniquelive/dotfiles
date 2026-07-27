status is-interactive; or return

if test -z "$SSH_ENV"
    set -xg SSH_ENV $HOME/.ssh/environment
end

if set -q SSH_AUTH_SOCK[1]; and test -S "$SSH_AUTH_SOCK"
    return
end

if not __ssh_agent_is_started
    __ssh_agent_start
end
