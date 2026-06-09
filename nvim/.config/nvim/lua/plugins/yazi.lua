-- Use yazi as the file manager from inside Neovim.
-- https://github.com/mikavilpas/yazi.nvim
---@type LazySpec
return {
  {
    "mikavilpas/yazi.nvim",
    version = "*", -- track stable releases
    event = "VeryLazy",
    dependencies = { { "nvim-lua/plenary.nvim", lazy = true } },
    keys = {
      { "<leader>e", "<cmd>Yazi<cr>", desc = "File explorer (yazi, at current file)" },
      { "<leader>cw", "<cmd>Yazi cwd<cr>", desc = "Yazi (in nvim's cwd)" },
      { "<c-up>", "<cmd>Yazi toggle<cr>", desc = "Resume the last yazi session" },
    },
    ---@type YaziConfig
    opts = {
      -- Leave open_for_directories at default (false): true caused E21 on selecting a dir
      -- (re-opened it as yazi into a non-modifiable buffer).
      keymaps = {
        show_help = "<f1>",
      },
      integrations = {
        grep_in_directory = "snacks.picker", -- in-yazi grep (<c-s>)
        bufdelete_implementation = "bundled-snacks",
      },
    },
  },

  -- One file manager only: turn off LazyVim's neo-tree sidebar.
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
