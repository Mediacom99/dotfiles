# conf.d runs before config.fish adds Homebrew to PATH, so fall back to its path.
set -l fnm (command -s fnm; or echo /opt/homebrew/bin/fnm)
test -x $fnm; and $fnm env --use-on-cd | source
