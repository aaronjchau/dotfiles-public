-- mini.diff alongside gitsigns (which keeps sign-column hunks, blame, minimap). Here for its
-- inline overlay (<leader>go), gh/gH apply/reset operators, and the `gh` hunk textobject.
-- No gutter clash: its view.style "number" tints the line number, not the sign column.
-- Its hunk-jump maps are blanked below so gitsigns keeps ]h [h ]H [H.
return {
  {
    "nvim-mini/mini.diff",
    event = "VeryLazy",
    keys = {
      {
        "<leader>go",
        function()
          require("mini.diff").toggle_overlay(0)
        end,
        desc = "Toggle mini.diff overlay",
      },
    },
    opts = {
      -- Disable only the hunk-jump maps so gitsigns owns ]h [h ]H [H (apply/reset/textobject kept).
      mappings = {
        goto_first = "",
        goto_prev = "",
        goto_next = "",
        goto_last = "",
      },
    },
    config = function(_, opts)
      require("mini.diff").setup(opts)
      -- Overlay on by default: enable it once per buffer the first time mini.diff
      -- computes a diff. The per-buffer flag means a manual <leader>go off stays off.
      vim.api.nvim_create_autocmd("User", {
        pattern = "MiniDiffUpdated",
        callback = function(ev)
          if vim.b[ev.buf].minidiff_overlay_init then
            return
          end
          vim.b[ev.buf].minidiff_overlay_init = true
          local data = require("mini.diff").get_buf_data(ev.buf)
          if data and not data.overlay then
            require("mini.diff").toggle_overlay(ev.buf)
          end
        end,
      })
    end,
  },
}
