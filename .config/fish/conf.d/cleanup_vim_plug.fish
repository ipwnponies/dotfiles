# vim-plug detection and cleanup script
# This will check for vim-plug and clean it up if it's no longer needed

function cleanup_vim_plug --description "Detect and clean up vim-plug"
    set detected false

    # Check if plug.vim is installed
    if test -f ~/.vim/autoload/plug.vim
        echo "Found plug.vim at ~/.vim/autoload/plug.vim"
        set detected true
    end

    # If vim-plug was detected, provide cleanup instructions
    if test "$detected" = true
        echo "vim-plug appears to be deprecated in your setup."
        echo "To clean up vim-plug:"
        echo "1. Delete ~/.vim/autoload/plug.vim if it exists"
        echo ""
        echo "Run cleanup_vim_plug --remove to automatically clean up"
    else
        echo "✓ No vim-plug remnants detected"
    end

    argparse 'r/remove' -- $argv
    # Handle automatic removal if --remove flag is provided
    if set -q _flag_remove
        # Remove plug.vim if it exists
        if test -f ~/.vim/autoload/plug.vim
            rm ~/.vim/autoload/plug.vim
            echo "✓ Removed ~/.vim/autoload/plug.vim"

            # Clean up empty directories
            if test -d ~/.vim/autoload; and test (count (ls -A ~/.vim/autoload 2>/dev/null)) -eq 0
                rmdir ~/.vim/autoload
                echo "✓ Removed empty ~/.vim/autoload directory"
            end

            if test -d ~/.vim; and test (count (ls -A ~/.vim 2>/dev/null)) -eq 0
                rmdir ~/.vim
                echo "✓ Removed empty ~/.vim directory"
            end
        end
    end
end

status --is-interactive; and cleanup_vim_plug
