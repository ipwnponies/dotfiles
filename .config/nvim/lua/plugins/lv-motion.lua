---@type LazyPluginSpec | LazyPluginSpec[]
-- LazyVim motion domain: flash.nvim replaces hop.nvim when vim.g.lv.motion = true.
-- Key differences from hop (`;` prefix) → flash (`s` / standard motions):
--   `;w`/`;W` word-jump   → `s` (flash bidirectional jump)
--   `;j` line-start jump  → `s` then restrict
--   `;f` char-in-line     → `f`/`F` (enhanced by flash)
--   `;t` till-char        → `t`/`T` (enhanced by flash)
--   treesitter-aware jump → `S`
return {
	{
		"folke/flash.nvim",
		enabled = lv_on("motion"),
		event = "VeryLazy",
		---@type Flash.Config
		opts = {
			-- Use uppercase labels to match hop's uppercase_labels = true convention.
			label = {
				uppercase = true,
			},
		},
		-- stylua: ignore
		keys = {
			-- Primary bidirectional jump (replaces ;w / ;W / ;j family).
			{ "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
			-- Treesitter-aware jump (replaces `:e`/`:E` word-end family).
			{ "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
			-- Remote flash: jump then execute operator from there (operator-pending only).
			{ "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
			-- Treesitter remote (operator-pending only).
			{ "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
			-- Toggle flash search during / command-line searches.
			{ "<c-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
		},
	},
}
