-- LazyVim keymaps — defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua

-- `jj` exits insert mode (home-row Esc). `jj` (not `jk`) since double-j never
-- appears in normal prose, so it won't false-trigger while typing.
vim.keymap.set("i", "jj", "<Esc>", { desc = "Exit insert mode" })
