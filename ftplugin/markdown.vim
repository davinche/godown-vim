augroup godown
	if g:godown_autorun
		autocmd! BufWinEnter <buffer> GodownPreview
	endif
	autocmd! VimLeave <buffer> GodownKill
augroup END
