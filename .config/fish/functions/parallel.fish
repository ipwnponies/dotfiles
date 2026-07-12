function parallel --wraps parallel --description 'GNU parallel (override moreutils collision)'
    set -l bin /nix/store/*-parallel-2*/bin/parallel
    command $bin[1] $argv
end
