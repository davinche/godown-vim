augroup godown
	if g:godown_autorun
		autocmd! BufWinEnter <buffer> GodownPreview
	endif
	autocmd! BufWinLeave <buffer> GodownClean
	autocmd! VimLeave <buffer> GodownKill
augroup END
