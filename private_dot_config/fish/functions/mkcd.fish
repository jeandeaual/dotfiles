function mkcd --argument-names 'dir' --description "Create a directory and enter it"
    mkdir -p "$dir" && cd "$dir"
end
