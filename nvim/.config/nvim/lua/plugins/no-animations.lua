-- Disable snacks animations (indent guides stay; only their animation is off).
return {
  {
    "folke/snacks.nvim",
    -- Global snacks animation kill switch (same as <leader>ua). Set in `init`
    -- before snacks loads so no animation fires; per-module disables below stop their autocmds.
    init = function()
      vim.g.snacks_animate = false
    end,
    opts = {
      scroll = { enabled = false },               -- no smooth scrolling (instant j/k, C-d/C-u)
      indent = { animate = { enabled = false } }, -- no animated indent scope line
    },
  },
}
