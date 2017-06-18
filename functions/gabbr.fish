function gabbr -d 'Global abbreviation for fish'

    # parse options
    set -l opts
    while count $argv >/dev/null
        switch $argv[1]
            case -{a,s,l,e} --{add,show,list,erase}
                set opts $opt $argv[1]

            case -h --help
                string trim "
Name: gabbr - Global abbreviation for fish shell

Usage:
    gabbr [options] WORD PHRASE

Options:
    -a, --add       Add abbreviation
    -e, --erase     Erase abbreviation
    -l, --list      Print all abbreviation names
    -s, --show      Print all abbreviations
    -h, --help      Help
"
                return
            case '--'
                break
            case '-*'
                echo "$_: invalid option -- $argv[1]" >&2
            case '*'
                break
        end

        set -e argv[1]
    end

    # check option-conflict
    if test (count $opts) -gt 1
        echo "$_: $opts[2] cannot be specified along with $opts[1]" >&2
        return 1
    else if not count $opts >/dev/null
        # default behavior
        count $argv >/dev/null
        and set opts '--add'
        or set opts '--show'
    end

    # execute
    switch $opts
        case -a --add
            # argument number check
            if test (count $argv) -lt 2
                echo "$_: abbreviation must have a value" >&2
                return 1
            end

            # key value check
            if string match '* *' "$argv[1]"
                echo "$_: abbreviation cannot have spaces in the key" >&2
                return 1
            end
          
            # erase abbreviations
            gabbr --erase "$argv[1]" ^/dev/null

            # use a global variable as default
            if not set -q global_abbreviations
                set -U global_abbreviations
            end

            # add an abbreviation
            set global_abbreviations $global_abbreviations "$argv"

        case -l --list
            # argument number check
            if count $argv >/dev/null
                echo "$_: unexpected argument -- $argv[1]" >&2
                return 1
            end

            # list words
            for abbr in $global_abbreviations
                echo $abbr | read -l word _
                echo "$word"
            end

        case -s --show
            # argument number check
            if count $argv >/dev/null
                echo "$_: unexpected argument -- $argv[1]" >&2
                return 1
            end

            for abbr in $global_abbreviations
                echo $abbr | read -l word phrase
                echo "gabbr $word "(string escape $phrase)
            end

        case -e --erase
            if contains "$argv[1]" (gabbr --list)
                for i in (seq (count $global_abbreviations) 1)
                    echo "$global_abbreviations[$i]" | read word _
                    if test "$word" = "$argv[1]"
                        set -e global_abbreviations[$i]
                    end
                end
            else
                echo "$_: no such abbreviation '$argv[1]'" >&2
            end
    end
end