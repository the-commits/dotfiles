" file: ~/.vim/autoload/line_numbers.vim
" source: https://jeffkreeftmeijer.com/vim-number/
" modified: Removed the mode() != "i"
function! line_numbers#ToggleLineNumbers()
  set ruler
  set number
  augroup numbertoggle
    autocmd!
    autocmd BufEnter,FocusGained,InsertLeave,WinEnter * if &nu | set rnu | endif
    autocmd BufLeave,FocusLost,InsertEnter,WinLeave   * if &nu | set nornu | endif
  augroup END
endfunction

