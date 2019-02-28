augroup godown
	if get(g:, 'godown_autorun', 0)
		autocmd! BufWinEnter <buffer> GodownPreview
	endif
	autocmd! BufWinLeave <buffer> GodownClean
	autocmd! VimLeave <buffer> GodownKill
augroup END
