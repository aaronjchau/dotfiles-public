-- Markdown preview: the selimacerbas fork (pure-Lua live-server, no npm) instead of LazyVim's
-- iamcco default. Opens the rendered preview in a new Chrome window so AeroSpace can tile it
-- side-by-side (see aerospace.toml for the rule that keeps it off workspace C).
return {
  { "iamcco/markdown-preview.nvim", enabled = false }, -- LazyVim default; same repo name, so disable
  {
    "selimacerbas/markdown-preview.nvim",
    name = "markdown-preview-fork", -- distinct name: iamcco's repo is also "markdown-preview.nvim"
    dependencies = { "selimacerbas/live-server.nvim" },
    ft = "markdown",
    keys = {
      { "<leader>cp", "<cmd>MarkdownPreview<cr>", ft = "markdown", desc = "Markdown Preview" },
    },
    config = function()
      require("markdown_preview").setup({
        default_theme = "dark",
        -- Full browser command; the URL is appended. New Chrome window = a tileable window, not a tab.
        browser = { "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome", "--new-window" },
      })
    end,
  },
}
