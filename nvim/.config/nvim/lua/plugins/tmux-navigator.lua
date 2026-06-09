-- Ctrl-h/j/k/l navigation across Neovim splits and tmux panes. Pairs with the
-- tmux-side plugin (~/.tmux.conf); overrides LazyVim's Ctrl-hjkl so edges cross into tmux.
-- https://github.com/christoomey/vim-tmux-navigator
return {
  {
    "christoomey/vim-tmux-navigator",
    cmd = {
      "TmuxNavigateLeft",
      "TmuxNavigateDown",
      "TmuxNavigateUp",
      "TmuxNavigateRight",
      "TmuxNavigatePrevious",
      "TmuxNavigatorProcessList",
    },
    keys = {
      { "<c-h>", "<cmd>TmuxNavigateLeft<cr>", desc = "Go to left split/pane" },
      { "<c-j>", "<cmd>TmuxNavigateDown<cr>", desc = "Go to lower split/pane" },
      { "<c-k>", "<cmd>TmuxNavigateUp<cr>", desc = "Go to upper split/pane" },
      { "<c-l>", "<cmd>TmuxNavigateRight<cr>", desc = "Go to right split/pane" },
      { "<c-\\>", "<cmd>TmuxNavigatePrevious<cr>", desc = "Go to previous split/pane" },
    },
  },
}
