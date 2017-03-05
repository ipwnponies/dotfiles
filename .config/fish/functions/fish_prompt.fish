function fish_prompt --description 'Write out the prompt'
	#Save the return status of the previous command
    set stat $status

# Just calculate these once, to save a few cycles when displaying the prompt
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
    end

if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

if not set -q __fish_color_blue
        set -g __fish_color_blue (set_color -o blue)
    end

#Set the color for the status depending on the value
    #set __fish_color_status (set_color -o green)
    if test $stat -gt 0
        set stat (printf '%s:(' (set_color -o red))
    else
        set stat ''
    end

switch $USER

case root toor

if not set -q __fish_prompt_cwd
            if set -q fish_color_cwd_root
                set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
            else
                set -g __fish_prompt_cwd (set_color $fish_color_cwd)
            end
        end

printf '%s@%s %s%s%s# ' $USER $__fish_prompt_hostname "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal"

case '*'

if not set -q __fish_prompt_cwd
            set -g __fish_prompt_cwd (set_color $fish_color_cwd)
        end

printf '╭─[%s] %s%s%s@%s%s%s: %s%s %s(%s)%s%s \f\r╰─➤ ' (date "+%Y-%m-%d %H:%M:%S") "$__fish_color_blue" $USER $__fish_prompt_normal (set_color -o green) $__fish_prompt_hostname $__fish_prompt_normal (set_color -o yellow) (prompt_pwd $PWD) (set_color -o cyan) (__fish_prompt_git) "$stat" "$__fish_prompt_normal"

end
end

function __fish_prompt_git
    set git_root_dir (git rev-parse --git-dir 2>/dev/null)
    if [ -n $git_root_dir ];
        if [ -d "$git_root_dir/../.dotest" ];
            set r "|AM/REBASE"
            set b (git symbolic-ref HEAD 2>/dev/null)
        else if [ -f "$git_root_dir/.dotest-merge/interactive" ];
            set r "|REBASE-i"
            set b (cat $git_root_dir/.dotest-merge/head-name)
        else if [ -d "$git_root_dir/.dotest-merge" ];
            set r "|REBASE-m"
            set b (cat $git_root_dir/.dotest-merge/head-name)
        else if [ -f "$git_root_dir/MERGE_HEAD" ];
            set r "|MERGING"
            set b (git symbolic-ref HEAD 2>/dev/null)
        else;
            if [ -f $git_root_dir/BISECT_LOG ];
                set r "|BISECTING"
            end
            set b (git symbolic-ref HEAD 2>/dev/null)
            if [ ! $status ];
                set b (cut -c1-7 $git_root_dir/HEAD)...
            end
        end

        printf "%s%s" (string replace "refs/heads/" "" "$b") "$r"
    end
end
