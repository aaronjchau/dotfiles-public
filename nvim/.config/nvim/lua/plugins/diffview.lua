-- Full-window git diff review: file panel left, diff right.
-- The maintained fork diffview-plus.nvim (drop-in: same `diffview` module,
-- Diffview* commands, setup() opts). https://github.com/dlyongemallo/diffview-plus.nvim
return {
  {
    "dlyongemallo/diffview-plus.nvim",
    cmd = {
      "DiffviewOpen",
      "DiffviewFileHistory",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
    },
    keys = {
      -- Toggle: open when no view is live, close when one is (works from any tabpage).
      {
        "<leader>gv",
        function()
          if next(require("diffview.lib").views) then
            vim.cmd("DiffviewClose")
          else
            vim.cmd("DiffviewOpen")
          end
        end,
        desc = "Diffview: toggle changes",
      },
      { "<leader>gV", "<cmd>DiffviewFileHistory<cr>", desc = "Diffview: branch history" },
    },
    opts = {
      enhanced_diff_hl = true, -- nicer intra-line highlights
      -- q closes the whole view from the file-list panels. Not bound in the diff buffers:
      -- the working-tree side is editable, where q must stay macro-record.
      keymaps = {
        file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
        file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
      },
    },
  },
}
