function zx-hook
    set zx "$HOME/zx0.0.0"

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
