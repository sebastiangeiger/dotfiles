function! SignLines()
  let n = 0
  execute(":sign define Fixme text=!? linehl=Fixme icon=".$HOME."/.vim/todo.png")
  call s:UnplaceSigns("Fixme",expand("%:p"))
  while n <= line("$")
    if getline(n) =~ '\(TODO\|FIXME\)'
      execute(":sign place ".n." line=".n." name=Fixme file=".expand("%:p"))
    endif
    let n = n + 1
  endwhile  
  highlight Fixme guibg=#222222
  highlight SignColumn guibg=#111111
endfunction

function! s:UnplaceSigns(SignType,FileName)
  let signs = s:Execute(":sign place file=".a:FileName."") " Returns type and location of all signs
  for line in split(signs,"\n")
    if line =~ "name=".a:SignType
      let id = matchstr(line, '\cid=\zs\(\d\{1,}\)\ze')
      if !empty(id)
        execute(":sign unplace ".id."")
      endif
    endif
  endfor
endfunction

" To avoid dependencies this was shamelessly copied from http://code.google.com/p/lh-vim/source/browse/vim-lib/trunk/autoload/lh/askvim.vim#54
function! s:Execute(command)
  let save_a = @a
  try 
    silent! redir @a
    silent! exe a:command
    redir END
  finally
    " Always restore everything
    let res = @a
    let @a = save_a
    return res
  endtry
endfunction

