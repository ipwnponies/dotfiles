vim.keymap.set(
	"n",
	"gf",
	"<C-w>v<C-w>HgF",
	{ buffer = true, desc = "Open file:line under cursor in vertical split (left)" }
)
