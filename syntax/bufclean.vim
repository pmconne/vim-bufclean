" Vim syntax file
" Language:	BufClean command window
" Maintainer:	Paul Connelly
" Last change:	2013 Jun 29

" Quit when a syntax file was already loaded
if exists("b:current_syntax")
  finish
endif

syn match bcBufferId 	"^[^>]*" nextgroup=bcSelector
syn match bcSelector	">> " nextgroup=bcShortName contained
syn match bcShortName	"[^|]*" contained contains=bcSeparator
syn match bcSeparator	"   |" contained

" highlight selected buffers
hi def link bcShortName Macro

let b:current_syntax = "bufclean"

