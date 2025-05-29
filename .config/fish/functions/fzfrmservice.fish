function fzfrmservice
    set -l services (docker service ls | tail -n +2 | fzf | while read l; echo $l | string split -n -f1 ' '; end)
    test -n "$services"; and docker service rm $services
end
