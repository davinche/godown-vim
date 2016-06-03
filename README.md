godown.vim
==========

A vim plugin for [Godown][gd].

Godown.vim and Godown are both heavily inspired by [Livedown][ld].

## Commands

The following commands are available

```vim
" launch the Godown server and preview your markdown
:GodownPreview

" stop the Godown server
:GodownKill

" Toggle the Godown server
:GodownToggle
```

## Configuration

The following are variables you can customize.

```vim
" should the preview be shown automatically when a markdown buffer is opened
let g:godown_autorun = 0

" the port to run the Godown server on
let g:godown_port = 1337
```

## License

MIT

[gd]: https://github.com/davinche/GoDown
[ld]: https://github.com/shime/livedown
