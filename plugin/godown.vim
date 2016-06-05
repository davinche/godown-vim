command! GodownPreview :call s:GodownPreview()
command! GodownKill :call s:GodownKill()
command! GodownToggle :call s:GodownToggle()

let s:path = fnamemodify(resolve(expand('<sfile>:p')), ':h')

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
	endif
endif

function! s:GodownPreview()
	if has('win32')
		silent! call system("start /B godown_win.exe -p " . g:godown_port .
					\ " start \"" . expand('%:p') . "\"")
	else
		if has('nvim')
			let s:job = jobstart(s:godown_bin . " -p " . g:godown_port .
						\ " start \"" . expand('%:p') . "\"")
			if !exists("g:godown_daemon")
				let g:godown_daemon = s:job
			endif
		else
			call system(s:godown_bin . " -p " . g:godown_port .
						\ " start \"" . expand('%:p') . "\" & ")
		endif
	endif
endfunction

function! s:GodownKill()
	if has('win32')
		silent! call system("start /B godown_win.exe -p " . g:godown_port . " stop")
	else
		call system(s:godown_bin. " -p " . g:godown_port . " stop")
		if has('nvim')
			if exists('g:godown_daemon')
				call jobstop(g:godown_daemon)
				unlet g:godown_daemon
			endif
		endif
	endif
endfunction

function! s:GodownToggle()
	if !exists('s:toggle')
		call s:GodownPreview() | let s:toggle = 1
	else
		call s:GodownKill() | unlet s:toggle
	endif
endfunction
