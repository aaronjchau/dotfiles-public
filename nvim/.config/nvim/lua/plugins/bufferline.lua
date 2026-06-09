-- No buffer tab bar; navigate via harpoon, the pickers, or <S-h>/<S-l>
-- (fall back to native :bprevious/:bnext). With bufferline off, nvim's native
-- tabline auto-shows only with >1 tab page, i.e. when diffview opens its tab.
return {
  { "akinsho/bufferline.nvim", enabled = false },
}
