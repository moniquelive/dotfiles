function python_venv --on-variable PWD
    set myvenv ./venv
    if test -d $myvenv
        source $myvenv/bin/activate.fish
    else if type -q deactivate
        deactivate
    end
end
