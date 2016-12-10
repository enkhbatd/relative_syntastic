if exists("g:loaded_syntastic_ruby_bundle_rubocop_checker")
    finish
endif
let g:loaded_syntastic_ruby_bundle_rubocop_checker = 1

function! s:find_project_dir()
    let l:project_dir = fnamemodify(expand('%:p'), ':h')
    while l:project_dir != '/'
        let l:gemfile = l:project_dir . '/Gemfile'
        if filereadable(l:gemfile)
            return l:project_dir
        endif
        let l:project_dir = fnamemodify(l:project_dir, ':h')
    endwhile
    return ''
endfunction

let s:save_cpo = &cpo
set cpo&vim

function! SyntaxCheckers_ruby_bundle_rubocop_IsAvailable() dict
    let l:project_dir = s:find_project_dir()
    if l:project_dir == ''
        return 0
    end

    let ver = syntastic#util#system('cd ' . l:project_dir . '; bundle exec rubocop --version')
    call self.log(self.getExec() . ' version =', ver)

    return syntastic#util#versionIsAtLeast(ver, [0, 12, 0])
endfunction

function! SyntaxCheckers_ruby_bundle_rubocop_GetLocList() dict
    let l:project_dir = s:find_project_dir()
    let makeprg = self.makeprgBuild({
                \ 'exe': 'cd ' . l:project_dir . '; bundle exec rubocop',
                \ 'args_after': '--format emacs' })

    let errorformat = '%f:%l:%c: %t: %m'

    let loclist = SyntasticMake({
                \ 'makeprg': makeprg,
                \ 'errorformat': errorformat,
                \ 'subtype': 'Style'})

    " convert rubocop severities to error types recognized by syntastic
    for e in loclist
        if e['type'] ==# 'F'
            let e['type'] = 'E'
        elseif e['type'] !=# 'W' && e['type'] !=# 'E'
            let e['type'] = 'W'
        endif
    endfor

    return loclist
endfunction

call g:SyntasticRegistry.CreateAndRegisterChecker({
            \ 'filetype': 'ruby',
            \ 'name': 'bundle_rubocop'})

let &cpo = s:save_cpo
unlet s:save_cpo

" vim: set et sts=4 sw=4:
