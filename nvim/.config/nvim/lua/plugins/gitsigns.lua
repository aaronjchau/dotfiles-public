-- Always-on inline git blame: faint virt-text at end of the current line.
-- Complements LazyVim's on-demand <leader>ghb / <leader>ghB popups; toggle at
-- runtime with `:Gitsigns toggle_current_line_blame`.
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      current_line_blame = true,
      current_line_blame_opts = {
        delay = 300,
        virt_text_pos = "eol",
      },
    },
  },
}
