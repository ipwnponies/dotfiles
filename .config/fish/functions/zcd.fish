function zcd -d 'z autojump with fzf search interface'
    set -l Z_SCRIPT_PATH $OMF_PATH/pkg/z/z/z.sh
    set directory (bash -c "source $Z_SCRIPT_PATH; _z" ^| awk '{print $2}' | fzf --border --height 40% --min-height 10 --margin 1,5 --reverse +s --tac)
    if test $status -eq 0
        cd $directory
    end
end
