# Use 1Password even while its socket is unavailable; never start a fallback agent.
switch (uname -s)
    case Darwin
        set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
    case Linux
        set -gx SSH_AUTH_SOCK "$HOME/.1password/agent.sock"
end
set -e SSH_AGENT_PID
