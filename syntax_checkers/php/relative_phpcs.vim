if exists("g:loaded_syntastic_php_relative_phpcs_checker")
  finish
endif
let g:loaded_syntastic_php_relative_phpcs_checker = 1

function! s:find_project_dir()
  let l:project_dir = fnamemodify(expand('%:p'), ':h')
  while l:project_dir != '/'
    let l:composer_file = l:project_dir . '/composer.json'
    if filereadable(l:composer_file)
      return l:project_dir
    endif

    let l:project_dir = fnamemodify(l:project_dir, ':h')
  endwhile
  return ''
endfunction

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_php_relative_phpcs_IsAvailable() dict
  let l:project_dir = s:find_project_dir()
  if l:project_dir == ''
    return 0
  end

  let l:sniff_bin = l:project_dir . '/vendor/bin/phpcs'
  if !filereadable(l:sniff_bin)
    return 0
  endif

  return 1
endfunction


function! SyntaxCheckers_php_relative_phpcs_GetLocList() dict
  let l:project_dir = s:find_project_dir()
  let l:sniff_bin = l:project_dir . '/vendor/bin/phpcs'
  let l:sniff_standard = ''
  if filereadable(l:project_dir . '/phpcs.xml')
    let l:sniff_standard = shellescape('--standard=' . l:project_dir . '/phpcs.xml')
  endif

  let makeprg = self.makeprgBuild({
        \ 'exe' : l:sniff_bin,
        \ 'args': '--tab-width=' . &tabstop . ' ' . l:sniff_standard,
        \ 'args_after': '--report=csv' })

  let errorformat =
        \ '%-GFile\,Line\,Column\,Type\,Message\,Source\,Severity%.%#,'.
        \ '"%f"\,%l\,%v\,%t%*[a-zA-Z]\,"%m"\,%*[a-zA-Z0-9_.-]\,%*[0-9]%.%#'

  return SyntasticMake({
        \ 'makeprg': makeprg,
        \ 'errorformat': errorformat,
        \ 'subtype': 'Style' })
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
      \ 'filetype': 'php',
      \ 'name': 'relative_phpcs' })

let &cpo = s:save_cpo
unlet s:save_cpo
