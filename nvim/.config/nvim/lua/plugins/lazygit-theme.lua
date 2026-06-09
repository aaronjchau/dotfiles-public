-- Snacks themes the nvim-launched lazygit (<leader>gg) from nvim highlights; its default
-- inactiveBorderColor -> FloatBorder can be ~bg-colored (black-looking borders). Point at a
-- visible group (config.yml still themes standalone lazygit).
return {
  {
    "folke/snacks.nvim",
    opts = {
      lazygit = {
        theme = {
          inactiveBorderColor = { fg = "Comment" }, -- visible muted gray
        },
      },
    },
  },
}
