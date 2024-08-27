#!/bin/bash

# First we append the saved layout of worspace N to workspace M

# And finally we fill the containers with the programs they had
(kitty -1 --name kitty_term_1 --listen-on "/tmp/kitty-instance-$DISPLAY" &)
(kitty -1 --name kitty_term_2 --listen-on "/tmp/kitty-instance-$DISPLAY" &)
(kitty -1 --name kitty_term_3 --listen-on "/tmp/kitty-instance-$DISPLAY" &)
(kitty -1 --name kitty_term_4 --listen-on "/tmp/kitty-instance-$DISPLAY" &)

(kitty -1 --name kitty_dev_1 --listen-on "/tmp/kitty-instance-$DISPLAY" --session $HOME/.config/i3/kitty-dev-session &)

(signal-desktop --password-store="gnome-libsecret" &)

(krusader &)

(firefox &)
(nm-applet &)
(flameshot &)
(nextcloud &)
(/home/marc/bin/display-watcher.sh &)
