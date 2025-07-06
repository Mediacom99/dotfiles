function zx-hook
    set zx "zx: ADD STDIN INPUT TO USE WITH FISH"

    if not test -x $zx
        echo "zx executable not found or not executable: $zx" >&2
        commandline -f repaint
    end

    set out (eval $zx 2>/dev/null)

    if test -n "$out"
        commandline --replace -- $out
    end

    commandline -f repaint
end
