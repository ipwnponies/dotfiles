function up -d 'cd up directory with int param'
    set levels (math $argv[1] + 0)
    for i in (seq $levels)
        set path "../$path"
    end
    cd $path
end
