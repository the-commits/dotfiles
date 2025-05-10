function vim_replace
    if test (count $argv) -lt 3
        echo "Usage: vim_replace <pattern> <replacement> <file_pattern>"
        return 1
    end

    set pattern $argv[1]
    set replacement $argv[2]
    set file_pattern $argv[3]

    for file in (find . -name "$file_pattern")
        echo "Processing file: $file"
        vim -c "argdo %s/$pattern/$replacement/gc" -c 'wq' $file
    end
end

