-- In-buffer merge-conflict resolution. Buffer-local maps when a conflict is detected:
-- co/ct/cb/c0 = ours/theirs/both/none, ]x/[x = next/prev conflict.
return {
  {
    "akinsho/git-conflict.nvim",
    version = "*",
    event = "VeryLazy",
    opts = {},
  },
}
