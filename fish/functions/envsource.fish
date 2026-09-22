# envsource: load KEY=value lines from a dotenv file into the current shell
# as exported globals. Skips blank lines and # comments, accepts an optional
# leading "export ", splits only on the first "=" so values may contain "=",
# strips one pair of surrounding quotes.
#
# Re-running mirrors the file: variables that a previous envsource exported
# and that are no longer in the file get unset. Only variables loaded by
# envsource are ever touched (tracked in the shell-global list
# __envsource_loaded), never ones set by hand.
function envsource --description 'Export KEY=value pairs from a dotenv file'
    set -l file $argv[1]
    if test -z "$file"
        set file .env
    end
    if not test -f "$file"
        echo "envsource: $file: no such file" >&2
        return 1
    end
    if not test -r "$file"
        echo "envsource: $file: not readable" >&2
        return 1
    end

    set -l n 0
    set -l lineno 0
    set -l loaded
    for line in (cat "$file")
        set lineno (math $lineno + 1)
        set line (string trim -- $line)
        if test -z "$line"; or string match -q '#*' -- $line
            continue
        end
        set line (string replace -r '^export\s+' '' -- $line)

        set -l kv (string split -m1 '=' -- $line)
        if test (count $kv) -ne 2
            echo "envsource: $file:$lineno: expected KEY=value, got '$line'" >&2
            return 1
        end
        set -l key (string trim -- $kv[1])
        set -l val $kv[2]
        if not string match -qr '^[A-Za-z_][A-Za-z0-9_]*$' -- $key
            echo "envsource: $file:$lineno: invalid variable name '$key'" >&2
            return 1
        end
        set val (string replace -r '^"(.*)"$' '$1' -- $val)
        set val (string replace -r "^'(.*)'\$" '$1' -- $val)

        set -gx $key $val
        set -a loaded $key
        set n (math $n + 1)
    end

    # Unset what a previous run exported and this file no longer has.
    set -l removed 0
    for old in $__envsource_loaded
        if not contains -- $old $loaded
            set -e $old
            set removed (math $removed + 1)
        end
    end
    set -g __envsource_loaded $loaded

    if test $removed -gt 0
        echo "envsource: loaded $n variable(s) from $file, unset $removed stale" >&2
    else
        echo "envsource: loaded $n variable(s) from $file" >&2
    end
end
