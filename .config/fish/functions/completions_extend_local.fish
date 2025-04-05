# Load workspace-specific extensions
function completions_extend_local
    set filename $argv[1]
    set dir (dirname $filename)
    set base (basename --suffix .fish $filename)
    set local $dir/{$base}_local.fish
    test -e $local; and source $local
end
