command! GodownPreview :call s:GodownPreview()
command! GodownKill :call s:GodownKillServer()
command! GodownToggle :call s:GodownToggle()
command! GodownLiveToggle :call s:GodownLiveToggle()
command! GodownClean :call s:cleanup()

nnoremap <silent> <Plug>(GodownPreview) :call <SID>GodownPreview()<CR>
nnoremap <silent> <Plug>(GodownKill) :call <SID>GodownKillServer()<CR>
nnoremap <silent> <Plug>(GodownToggle) :call <SID>GodownToggle()<CR>
nnoremap <silent> <Plug>(GodownLiveToggle) :call <SID>GodownLiveToggle()<CR>
nnoremap <silent> <Plug>(GodownClean) :call <SID>cleanup()<CR>

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h:h') . '/build'

if !exists('g:godown_port')
	let g:godown_port = 1337
endif

if !exists('g:godown_autorun')
	let g:godown_autorun = 0
endif

if !exists('s:godown_bin')
	if has('unix')
		if has('mac')
			let s:godown_bin = s:path . '/godown_mac'
		else
			let s:godown_bin = s:path . '/godown_linux'
		endif
	elseif has('win')
		let s:godown_bin = 'start /B ' . s:path . '/godown_win.exe'
	endif
endif

function! s:GodownPreview()
	let l:path = expand('%:p')
	if has('nvim')
		let l:job = jobstart(s:godown_bin . ' -p ' . g:godown_port . ' -l ' .
					\ ' start "' . l:path . '"')
		if !exists("s:godown_daemon")
			let s:godown_daemon = l:job
		endif
	else
		call system(s:godown_bin . ' -p ' . g:godown_port . ' -l ' .
					\ ' start "' . l:path . '" &')
	endif
endfunction

function! s:GodownKillServer()
	call system(s:godown_bin. " -p " . g:godown_port . " stop")
	if has('nvim')
		if exists('s:godown_daemon')
			call jobstop(s:godown_daemon)
			unlet s:godown_daemon
		endif
	endif
endfunction

function! s:GodownToggle()
	if !exists('b:toggle')
		call s:addCleanup(expand('%:p'))
		call s:GodownPreview() | let b:toggle = 1
		echo "GodownToggle[ON]"
	else
		call s:delCleanup(expand('%:p'))
		unlet b:toggle
		echo "GodownToggle[OFF]"
	endif
endfunction

" ----------------------------------------------------------------------------
" Live Refresh ---------------------------------------------------------------
" ----------------------------------------------------------------------------

function! s:refresh(shouldLaunch)
	let l:bufnr = bufnr('%')
	let l:content = join(getline(1, "$"), "\n")
	if has('nvim')
		let l:cmd = s:godown_bin . ' -p ' . g:godown_port .
					\(a:shouldLaunch ?' -l ' : ' ') .
					\'send ' . string(l:bufnr)
		let l:job = jobstart(l:cmd)
		let l:stat = jobsend(l:job, l:content)
		call jobclose(l:job, 'stdin')

		if !exists("s:godown_daemon")
			let s:godown_daemon = l:job
		endif
	else
		call system(s:godown_bin . ' -p ' . g:godown_port .
					\(a:shouldLaunch ?' -l ' : ' ') .
					\'send ' . string(l:bufnr) . ' &', l:content)
	endif
endfunction

function! s:shouldRefresh()
	if exists('b:livetoggle')
		if b:livetoggle != b:changedtick
			let b:livetoggle = b:changedtick
			call s:refresh(0)
		endif
	endif
endfunction

function! s:GodownLiveToggle()
	if !exists('b:livetoggle')
		call s:addCleanup(string(bufnr('%')))
		let b:livetoggle = b:changedtick
		augroup livetoggle
			autocmd! * <buffer>
			autocmd CursorHold,CursorHoldI,CursorMoved,CursorMovedI <buffer> call s:shouldRefresh()
		augroup END
		call s:refresh(1)
		echo "GodownLiveToggle[ON]"
	else
		autocmd! livetoggle
		unlet b:livetoggle
		call s:delCleanup(string(bufnr('%')))
		echo "GodownLiveToggle[OFF]"
	endif
endfunction


function! s:cleanup()
	if exists('b:cleanup')
		for item in b:cleanup
			call s:removeRefCount(item)
		endfor
		unlet b:cleanup
	endif
endfunction

function! s:addCleanup(item)
	if !exists('b:cleanup')
		let b:cleanup = [a:item]
	else
		if index(b:cleanup, a:item) == -1
			call add(b:cleanup, a:item)
		endif
	endif
	call s:addRefCount(a:item)
endfunction

function! s:delCleanup(item)
	if exists('b:cleanup')
		let l:index = index(b:cleanup, a:item)
		if l:index >= 0
			call remove(b:cleanup, l:index)
			call s:removeRefCount(a:item)
		endif
	endif
endfunction

function! s:addRefCount(item)
	if !exists('s:refcount')
		let s:refcount = {}
	endif

	if !has_key(s:refcount, a:item)
		let s:refcount[a:item] = 1
	else
		let s:refcount[a:item] = s:refcount[a:item] + 1
	endif
endfunction

function! s:removeRefCount(item)
	if exists('s:refcount')
		if has_key(s:refcount, a:item)
			let s:refcount[a:item] = s:refcount[a:item] - 1
			if s:refcount[a:item] == 0
				call remove(s:refcount, a:item)
				call system(s:godown_bin . ' -p ' . g:godown_port .
							\' stop ' . a:item . ' &')
			endif
		endif
	endif
endfunction
