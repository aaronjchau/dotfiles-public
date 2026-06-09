-- Auto-save: writes ~1s after edits settle, plus on focus loss / buffer leave.
-- Skips special and unnamed buffers. Toggle with :ASToggle.
-- Format-on-save suppressed for AUTO writes only (manual :w still formats), via
-- LazyVim's conform gate vim.b.autoformat.
return {
  {
    "okuuva/auto-save.nvim",
    event = { "InsertLeave", "TextChanged" },
    cmd = "ASToggle",
    opts = {
      debounce_delay = 1000,
      condition = function(buf)
        return vim.bo[buf].buftype == ""
          and vim.bo[buf].modifiable
          and vim.api.nvim_buf_get_name(buf) ~= ""
      end,
    },
    config = function(_, opts)
      require("auto-save").setup(opts)
      local grp = vim.api.nvim_create_augroup("auto_save_no_format", { clear = true })
      vim.api.nvim_create_autocmd("User", {
        group = grp,
        pattern = "AutoSaveWritePre",
        callback = function()
          vim.b.auto_save_autoformat = vim.b.autoformat
          vim.b.autoformat = false
        end,
      })
      vim.api.nvim_create_autocmd("User", {
        group = grp,
        pattern = "AutoSaveWritePost",
        callback = function()
          vim.b.autoformat = vim.b.auto_save_autoformat
          vim.b.auto_save_autoformat = nil
        end,
      })
    end,
  },
}
