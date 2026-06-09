-- LazyVim autocmds — defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua

-- Snacks explorer: track the current file only. On entering a real buffer, collapse the
-- whole tree then reveal that file, so it doesn't accumulate every opened file.
-- Uses Snacks' internal explorer modules (not a public API); guarded with pcall.
local follow_last
vim.api.nvim_create_autocmd("BufEnter", {
  group = vim.api.nvim_create_augroup("snacks_explorer_follow_only", { clear = true }),
  callback = function(ev)
    if vim.bo[ev.buf].buftype ~= "" then
      return
    end
    local file = vim.fs.normalize(vim.api.nvim_buf_get_name(ev.buf))
    if file == "" or file == follow_last then
      return
    end
    follow_last = file
    vim.schedule(function()
      local ok, Snacks = pcall(require, "snacks")
      if not ok then
        return
      end
      local explorer = Snacks.picker.get({ source = "explorer" })[1]
      if not explorer or explorer.closed then
        return
      end
      local cwd = vim.fs.normalize(explorer:cwd())
      if file:sub(1, #cwd + 1) ~= cwd .. "/" then
        return
      end
      pcall(function()
        require("snacks.explorer.tree"):close_all(cwd)
        require("snacks.explorer.actions").update(explorer, { target = file, refresh = true })
      end)
    end)
  end,
})

-- LazyVim enables spell + wrap for markdown; drop spell (keep wrap).
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("md_nospell", { clear = true }),
  pattern = { "markdown", "markdown.mdx" },
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- HTML: <leader>cp opens the current file in the browser, kept in the current AeroSpace
-- space (via the open-here helper) — mirrors markdown's preview keymap.
vim.api.nvim_create_autocmd("FileType", {
  group = vim.api.nvim_create_augroup("html_open_browser", { clear = true }),
  pattern = "html",
  callback = function(ev)
    vim.keymap.set("n", "<leader>cp", function()
      local file = vim.api.nvim_buf_get_name(ev.buf)
      if file == "" then
        return
      end
      vim.cmd("silent update") -- save if modified so the browser shows the latest
      vim.system({ vim.fn.expand("~/.local/bin/open-here"), file })
    end, { buffer = ev.buf, desc = "Open HTML in browser" })
  end,
})
