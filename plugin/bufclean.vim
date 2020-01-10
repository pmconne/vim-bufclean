" BufClean.vim - Quickly delete buffers
"
" Created June 2013 Paul Connelly
"
" Quickly select buffers to close from list of open buffers.
"
" Usage:
"
" :call BufClean()
"
" Opens a vertical split with up to 35 currently open and unmodified buffers.
" [1-9a-z]  Toggle selection of specified buffer.
" [A]       Select all buffers.
" [Q]       Deselect all buffers.
" [Enter]   Close all selected buffers.
" [Tab]     Close all unselected buffers.
" [Esc]     Cancel
"
" Deleting the last buffer will leave a new empty buffer open.
"
" TODO:
"
" Make more configurable

let s:MaxShortNameLength = 0

" e.g. "1 >> shortName      | longName"   
function! MakeBufLabel (bufIdChar, shortName, longName, isSelected)
    if a:isSelected
        let prefix = ">> "
    else
        let prefix = "   "
    endif

    let nameSep = repeat (" ", s:MaxShortNameLength - len(a:shortName))
    let nameSep .= "   |   "
    return a:bufIdChar . " " . prefix . a:shortName . nameSep . a:longName
endfunction

function! ListBuffers()
    let @a = ""
    let i = 1
    split Delete Buffers
    set syntax=bufclean
    let s:MaxShortNameLength = 0
    let longBufNames = []
    while (i <= bufnr('$'))
        if buflisted(i) && !getbufvar(i, "&mod")
            let longName = bufname(i)
            let shortName = fnamemodify(longName, ":t")
            let shortNameLen = len(shortName)
            if (shortNameLen && !(shortName ==# "Delete Buffers"))
                call add(longBufNames, longName)
                if (shortNameLen > s:MaxShortNameLength)
                    let s:MaxShortNameLength = shortNameLen
                endif
            endif
        endif
        let i += 1
    endwhile

    let nBufs = 0
    let maxBufs = len(longBufNames)
    if (maxBufs >= 35)
        let maxBufs = 35
    endif

    execute "resize " . maxBufs
    wincmd J

    while (nBufs < maxBufs)
        let longName = longBufNames[nBufs]
        let shortName = fnamemodify(longName, ":t")
        if nBufs < 9
            let bufIdChar = nr2char(49 + nBufs)
        else
            let bufIdChar = nr2char(65 + nBufs - 9)
        endif

        let label = MakeBufLabel (bufIdChar, shortName, longName, 0)
        if (0 != nBufs)
            let @a .= "\n"
        endif
        let @a .= label
        let nBufs += 1
    endwhile

    execute("normal! \"aP")
    return nBufs
endfunction

function! IsCurrentLineSelected()
    execute "normal! 02lv2l\"ay"
    return @a == ">>"
endfunction

function! GetShortNameFromCurrentLine()
    execute "normal! 05lvt|bt \"ay"
    return @a
endfunction

function! GetLongNameFromCurrentLine()
    execute "normal! 0f|4lvg_\"ay"
    return @a
endfunction

function! GetBufIdFromCurrentLine()
    execute "normal! 0v\"ay"
    return @a
endfunction

function! SelectAll (nBufs, select)
    execute "normal! gg"
    let i = 0
    let prefix = a:select ? ">>" : "  "
    while i < a:nBufs
        execute "normal! 02lxxi" . prefix
        execute "normal! j"
        let i+= 1
    endwhile
endfunction

" => 0: quit 1: continue 2: close selected 3: close unselected
function! ProcessChar (c, nBufs)
    let lineNo = -1
    if a:c == 27
        return 0
    elseif a:c == 13
        return 2
    elseif a:c == 9
        return 3
    elseif a:c == 65
        call SelectAll (a:nBufs, 1)
        return 1
    elseif a:c == 81
        call SelectAll (a:nBufs, 0)
        return 1
    elseif a:c >= 97 && a:c <= 122
        let lineNo = a:c - 97 + 9
    elseif a:c >= 49 && a:c <= 57
        let lineNo = a:c - 49
    endif

    if (-1 != lineNo && lineNo < a:nBufs)   
        execute "normal! gg" . repeat("j", lineNo)
        let isSelected = !IsCurrentLineSelected()
        let bufIdChar = GetBufIdFromCurrentLine()
        let bufname = GetShortNameFromCurrentLine()
        let longName = GetLongNameFromCurrentLine()

        let @a = MakeBufLabel (bufIdChar, bufname, longName, isSelected)
        execute "normal! cc"
        execute "normal! \"aP"
    endif

    return 1
endfunction

function! CloseBufs (closeSelected, nBufs)
    execute "normal! gg"
    let i = 0
    while (i < a:nBufs)
        let isSelected = IsCurrentLineSelected()
        if isSelected == a:closeSelected
            let bufname = GetLongNameFromCurrentLine()
            let killCmd = "bwipeout " . bufname
            exec killCmd
        endif

        execute "normal! j"
        let i += 1
    endwhile
endfunction

function! BufClean()
    let saved_areg = @a
    let nBufs = ListBuffers()
    redraw

    execute("normal! \"ayy")
    let hilite = @a

    while (1)
        echo "[1-9a-z] Toggle Buffer [A] Select All [Q] Select None [Enter] Close Selected [Tab] Close Unselected [Esc] Exit"
        let pc = ProcessChar (getchar(), nBufs)
        if 0 == pc
            break
        elseif 1 == pc
            redraw
            continue
        endif

        call CloseBufs (2 == pc, nBufs)
        break
    endwhile

    bd!
    let @a = saved_areg
endfunction




