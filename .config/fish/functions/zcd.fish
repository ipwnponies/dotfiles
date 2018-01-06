function zcd -d 'z autojump with fzf search interface'
    set -l Z_SCRIPT_PATH $OMF_PATH/pkg/z/z/z.sh
    set directory (bash -c "source $Z_SCRIPT_PATH; _z" ^| awk '{print $2}' | fzf --no-sort --tac --query "$argv" --preview 'ls --color=always -F {}')
    if test $status -eq 0
        cd $directory
    end
end
