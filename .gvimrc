colorscheme ir_black
set guioptions-=T
set guioptions-=m

if &diff
	set lines=50
	set columns=200
endif

"Maximize gvim upon entry, Windows only
if has("win32") | has("win64")
	au GUIEnter * simalt ~x
	set guifont=ProggyCleanTT:h11:cANSI
elseif has("x11")
	set guifont=ProggyCleanTT\ 12
endif
