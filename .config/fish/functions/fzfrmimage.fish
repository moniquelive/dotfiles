function fzfrmimage
    set -l images (docker image ls | tail -n +2 | fzf | while read l; echo $l | string split -n -f3 ' '; end)
    test -n "$images"; and docker image rm $images
end
