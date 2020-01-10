# vim-bufclean

Quickly close multiple buffers.

# Usage

The plugin exposes a single function, `BufClean()`, which can be bound to a mapping. When invoked it opens a window at the bottom of Vim presenting a list of all open buffers by filename, with full path to the right and a buffer ID to the left. A `>>` to the left of a buffer name indicates that buffer has been selected by the user. e.g., something like:
```
1    BufferNotSelected.h
2 >> BufferSelected.cpp
3    AlsoNotSelected.cpp
--------------------------------------------------------------------------------------------------------------
[1-9a-z] Toggle Buffer [A] Select All [Q] Select None [Enter] Close Selected [Tab] Close Unselected [Esc] Exit
```

With the window open, the following key bindings can be used:
   * 1-9, a-z : toggle selection of buffer by ID
   * Shift-A : select all buffers
   * Shift-Q : deselect all buffers
   * Enter : Close all selected buffers and exit
   * Tab : Close all unselected buffers and exit
   * Esc : exit

I typically open the window, press `A` to select all, deselect a couple of buffers I want to remain open, and press `Enter` to close the rest along with the window itself.

The window will not display hidden or modified buffers, nor more than 36 buffers.

## Sample configuration

A mapping like the following is useful for quickly invoking the plugin. The noequalalways option prevents the plugin's window from occupying more screen space than it needs to.
```vi
" allow window to occupy minimal height
set noequalalways

nnoremap <leader>bd :call BufClean()<cr>
```

