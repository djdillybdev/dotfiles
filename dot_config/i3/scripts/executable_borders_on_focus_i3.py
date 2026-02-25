#!/usr/bin/env python3
import i3ipc

FOCUSED_BORDER = "pixel 2"   # change to "pixel 1" or "normal"
UNFOCUSED_BORDER = "pixel 0" # or "none"

def all_leaf_nodes(tree):
    # leaf nodes are actual windows
    return tree.leaves()

def set_borders(i3):
    tree = i3.get_tree()
    focused = tree.find_focused()
    if not focused:
        return

    focused_id = focused.id

    # Remove border from all leaf windows
    for n in all_leaf_nodes(tree):
        # Optional: skip floating windows if you want them unchanged
        # if n.floating != 'user_off':  # floating windows
        #     continue
        i3.command(f'[con_id="{n.id}"] border {UNFOCUSED_BORDER}')

    # Add border back to focused window
    i3.command(f'[con_id="{focused_id}"] border {FOCUSED_BORDER}')

def on_any_event(i3, e):
    set_borders(i3)

def main():
    i3 = i3ipc.Connection()

    # Run once at startup
    set_borders(i3)

    # React to focus changes and new windows
    i3.on("window::focus", on_any_event)
    i3.on("window::new", on_any_event)
    i3.on("window::close", on_any_event)
    i3.on("workspace::focus", on_any_event)

    i3.main()

if __name__ == "__main__":
    import fcntl, sys, os

    lockfile = "/tmp/i3-focus-border.lock"
    fp = open(lockfile, "w")

    try:
        fcntl.flock(fp, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        sys.exit(0)
    main()
