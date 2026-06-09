-- Minimap: code overview on the right, with git-change and diagnostic markers.
-- Toggle with <leader>uM. https://github.com/nvim-mini/mini.map
return {
  {
    "nvim-mini/mini.map",
    version = false,
    event = "VeryLazy",
    keys = {
      { "<leader>uM", function() require("mini.map").toggle() end, desc = "Toggle minimap" },
    },
    config = function()
      local map = require("mini.map")
      map.setup({
        integrations = {
          map.gen_integration.builtin_search(),
          map.gen_integration.diagnostic({
            error = "DiagnosticFloatingError",
            warn = "DiagnosticFloatingWarn",
            info = "DiagnosticFloatingInfo",
            hint = "DiagnosticFloatingHint",
          }),
          map.gen_integration.gitsigns(), -- shows added/changed/removed lines
        },
        symbols = {
          encode = map.gen_encode_symbols.dot("4x2"), -- fine-grained dots
        },
        window = {
          side = "right",
          width = 10,
          winblend = 25,
          focusable = false,
          show_integration_count = false,
        },
      })
      -- Open on the first real file (not the dashboard).
      local function open()
        pcall(map.open)
      end
      if vim.bo.buftype == "" and vim.api.nvim_buf_get_name(0) ~= "" then
        open()
      else
        vim.api.nvim_create_autocmd("BufReadPost", { once = true, callback = open })
      end
    end,
  },
}
