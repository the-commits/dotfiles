function rename_files
    # Kontrollera argument
    if test (count $argv) -ne 3
        echo "Usage: rename_files <pattern> <replacement> <file_glob>"
        echo "Example: rename_files '[:+]' '' '*.wav'"
        return 1
    end

    set pattern     $argv[1]
    set replacement $argv[2]
    set glob_pat    $argv[3]

    # Loopa över alla filer som matchar globben (rekursivt via fd)
    for file in (fd --type f --glob "$glob_pat")
        # Hämta bara filnamnet (utan sökväg)
        set base (basename -- "$file")
        # Gör regex-ersättning på filnamnet
        set newbase (string replace -r "$pattern" "$replacement" -- $base)
        # Hämta katalogen så vi kan flytta tillbaka rätt
        set dir (dirname -- "$file")
        # Utför själva flytten
        mv -- "$file" "$dir/$newbase"
        echo "Renamed: '$file' → '$dir/$newbase'"
    end
end

