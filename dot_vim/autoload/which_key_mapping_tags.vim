" file: ~/.vim/autoload/which_key_mapping_tags.vim
" source: https://github.com/liuchengxu/vim-which-key 
function! which_key_mapping_tags#Map()
  let g:which_key_map['t'] = {
      \ 'name' : '+tags' ,
      \ 'g' : ['<C-]>'     , 'Go to definition (<C-]>) ']    ,
      \ 'G' : ['<C-T>'     , 'Go back (<C-T>)']    ,
      \ }
  call which_key#register('<Space>', "g:which_key_map")
endfunction
function! which_key_mapping_tags#Init()
  if !exists("g:which_key_map")
    let g:which_key_map = {}
  endif
  call which_key_mapping_tags#Map()
endfunction
