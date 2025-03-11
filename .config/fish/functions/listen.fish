function listen
    lsof -nP -i :$argv | grep LISTEN
end
