#!/usr/bin/env fish

set branch_name (basename $argv[1])
set session_name (tmux display-message -p "#S")
set clean_name (echo $branch_name | tr "./" "__")
set target "$session_name:$clean_name"

if not tmux has-session -t $target ^/dev/null
    tmux neww -dn $clean_name
end

tmux send-keys -t $target "$argv[2..]"

