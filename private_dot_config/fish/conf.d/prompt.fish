if type -q starship
    starship init fish | source
else
    set fish_color_cwd yellow
    set fish_color_cwd_root yellow

    function fish_prompt --description "Write out the prompt"
        set -l user_char '$'
        if functions -q fish_is_root_user; and fish_is_root_user
            set user_char '#'
        end

        echo -n -s (set_color -o green) $USER (set_color -o white) '@' (set_color -o blue) $hostname ' ' (set_color -o $fish_color_cwd) (prompt_pwd) (set_color normal) ' ' $user_char ' '
    end
end
