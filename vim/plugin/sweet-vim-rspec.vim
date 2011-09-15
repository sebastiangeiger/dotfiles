" Find the path to this script so that the links
" to formatter don't need to be hard coded.
if !exists('g:SweetVimRspecPlugin')
  let g:SweetVimRspecPlugin = fnamemodify(expand("<sfile>"), ":p:h") 
endif

function! SweetVimRspecRun(kind,signs)
  echomsg "Running Specs..."
  sleep 10m " Sleep long enough so MacVim redraws the screen so you can see the above message

  if !exists('g:SweetVimRspecUseBundler')
    let g:SweetVimRspecUseBundler = 1
  endif

  if !exists('t:SweetVimRspecVersion')
    let l:cmd = ""
    if g:SweetVimRspecUseBundler == 1
      let l:cmd .= "bundle exec "
    endif
    let l:cmd .=  "spec --version 2>/dev/null"
    " Execute the spec --version command which, if returns without error
    " means that the version of rspec is ONE otherwise assume rspec2
    cgete system( l:cmd ) 
    let t:SweetVimRspecVersion = v:shell_error == 0 ? 1 : 2
  endif

  if !exists('t:SweetVimRspecExecutable') || empty(t:SweetVimRspecExecutable)
    let t:SweetVimRspecExecutable =  g:SweetVimRspecUseBundler == 0 ? "" : "bundle exec " 
    if  t:SweetVimRspecVersion  > 1
      let t:SweetVimRspecExecutable .= "rspec -r " . g:SweetVimRspecPlugin . "/sweet_vim_rspec2_formatter.rb" . " -f RSpec::Core::Formatters::SweetVimRspecFormatter "
    else
      let t:SweetVimRspecExecutable .= "spec -br " . g:SweetVimRspecPlugin . "/sweet_vim_rspec1_formatter.rb" . " -f Spec::Runner::Formatter::SweetVimRspecFormatter "
    endif
  endif
  
  if a:kind !=  "Previous" 
    let t:SweetVimRspecTarget = expand("%:p") . " " 
    if a:kind == "Focused"
      let t:SweetVimRspecTarget .=  "-l " . line(".") . " " 
    endif
  endif

  if !exists('t:SweetVimRspecTarget')
    echo "Run a Spec first"
    return
  endif

  cclose

  if exists('g:SweetVimRspecErrorFile') 
    execute 'silent! bdelete ' .  g:SweetVimRspecErrorFile
  endif

  let g:SweetVimRspecErrorFile = tempname()
  execute 'silent! wall'
  let t:SweetVimRspecResult = system(t:SweetVimRspecExecutable . t:SweetVimRspecTarget . " 2>" . g:SweetVimRspecErrorFile)
  if (a:signs == 1 && t:SweetVimRspecVersion > 1)
    call s:AddSweetSigns(t:SweetVimRspecResult)
  endif
  cgete t:SweetVimRspecResult
  botright cwindow
  cw
  setlocal foldmethod=marker
  setlocal foldmarker=+-+,-+-

  if getfsize(g:SweetVimRspecErrorFile) > 0 
    execute 'silent! split ' . g:SweetVimRspecErrorFile
    setlocal buftype=nofile
  endif

  call delete(g:SweetVimRspecErrorFile)

  let l:oldCmdHeight = &cmdheight
  let &cmdheight = 2
  echo "Done"
  let &cmdheight = l:oldCmdHeight
endfunction

function! s:AddSweetSigns(RspecResult)
  " Defining a sign type for failed tests and one for pending tests
  execute(":sign define RSpecFailed text=!! linehl=RSpecFailed icon=".$HOME."/.vim/plugin/rspec-failed.png")
  execute(":sign define RSpecPending text=?? linehl=RSpecPending icon=".$HOME."/.vim/plugin/rspec-pending.png")
  " Cleaning up any old signs
  call s:UnplaceSigns("RSpecFailed")
  call s:UnplaceSigns("RSpecPending")
  let lines = split(a:RspecResult, "\n") " Split into lines
  let i = 0
  while i < len(lines)
    if lines[i] =~ '\(\[FAIL\]\)'
      " Look in the next line, it should have the location where the spec failed
      call s:PlaceSign(lines[i+1], "RSpecFailed")
    elseif lines[i] =~ '\(\[PEND\]\)'
      " Look in the next line, it should have the location where the spec is pending
      call s:PlaceSign(lines[i+1], "RSpecPending")
    endif
    let i+=1
  endwhile
  redraw!  " Needed otherwise lines are duplicated
endfunction

function! s:PlaceSign(Line,SignType)
    let fragments = split(a:Line, ":")  " a:Line will have the format '/some/path/to/file:123 ...'
    let file_name = fragments[0]
    let line_nr = fragments[1]
    execute(":sign place ".line_nr." line=".line_nr." name=".a:SignType." file=".file_name."")
endfunction

function! s:UnplaceSigns(SignType)
  let signs = s:Execute(":sign place") " Returns type and location of all signs
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

command! SweetVimRspecRunFile call SweetVimRspecRun("File",0)
command! SweetVimRspecRunFocused call SweetVimRspecRun("Focused",0)
command! SweetVimRspecRunPrevious call SweetVimRspecRun("Previous",0)
command! SweetVimRspecRunFileWithSigns call SweetVimRspecRun("File",1)
command! SweetVimRspecRunFocusedWithSigns call SweetVimRspecRun("Focused",1)
command! SweetVimRspecRunPreviousWithSigns call SweetVimRspecRun("Previous",1)
