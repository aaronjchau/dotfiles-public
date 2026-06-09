-- Disable blink.cmp's inline ghost-text preview (LazyVim enables it via vim.g.ai_cmp).
-- The dropdown completion menu is unaffected.
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        ghost_text = { enabled = false },
      },
    },
  },
}
