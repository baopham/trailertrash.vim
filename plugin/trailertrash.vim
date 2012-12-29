" trailertrash.vim - Trailer Trash
" Maintainer:   Christopher Sexton
"
" Ideas taken from numerous places like:
" http://vim.wikia.com/wiki/Highlight_unwanted_spaces
" http://vimcasts.org/episodes/tidying-whitespace/
" http://blog.kamil.dworakowski.name/2009/09/unobtrusive-highlighting-of-trailing.html
" and more!
"
" Forked by: Bao Pham

" Exit quickly when:
" - this plugin was already loaded (or disabled)
" - when 'compatible' is set
if exists("g:loaded_trailertrash") || &cp
  finish
endif
let g:loaded_trailertrash = 1

let s:cpo_save = &cpo
set cpo&vim

function! s:init()
    if (&modifiable && !get(g:, 'trailertrash_hide_on_open', 0))
        let b:show_trailer = 1
    else
        let b:show_trailer = 0
    endif
endfunction

call s:init()

function! KillTrailerTrash()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

command! -bar -range=% Trim :call KillTrailerTrash()

" User can override blacklist. This match as regexp pattern.
let s:blacklist = get(g:, 'trailertrash_blacklist', [
\ '__Calendar',
\])

function! HideTrailer()
    match none UnwantedTrailerTrash
    let b:show_trailer = 0
endfunction

command! HideTrailer :call HideTrailer()

function! ShowTrailer()
    if (&modifiable)
        let bufname = bufname('%')
        for ignore in s:blacklist
            if bufname =~ ignore
                return
            endif
        endfor
        let b:show_trailer = 1
        match UnwantedTrailerTrash /\s\+$/
    endif
endfunction

command! ShowTrailer :call ShowTrailer()

function! Trailer()
    if (s:isHighlighting())
        call HideTrailer()
    else
        call ShowTrailer()
    endif
endfunction

command! Trailer :call Trailer()

function! s:isHighlighting()
    if !(exists('b:show_trailer'))
        call s:init()
    endif
    return b:show_trailer
endfunction

function! FindTrailer()
    /\s\+$/
endfunction

command! FindTrailer :call FindTrailer()

hi link UnwantedTrailerTrash ErrorMsg
au ColorScheme * hi link UnwantedTrailerTrash ErrorMsg
au BufEnter    * if s:isHighlighting() | match UnwantedTrailerTrash /\s\+$/ | endif
au InsertEnter * if s:isHighlighting() | match UnwantedTrailerTrash /\s\+\%#\@<!$/ | endif
au InsertLeave * if s:isHighlighting() | match UnwantedTrailerTrash /\s\+$/ | endif

" }}}1

let &cpo = s:cpo_save

" vim:set ft=vim ts=8 sw=4 sts=4:

