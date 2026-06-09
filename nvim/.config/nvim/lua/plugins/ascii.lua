-- Saturn ASCII art (from ascii.nvim) as the Snacks dashboard header.
-- ascii.nvim is require-loaded; nui.nvim is only needed for its :preview popup.
return {
  {
    "MaximilianLloyd/ascii.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    lazy = true,
  },
  {
    "folke/snacks.nvim",
    opts = function(_, opts)
      -- ascii.nvim nests art as <category>.<subcategory>.<name>; the planets
      -- category's subcategory is also "planets". Guard so a bad lookup can't
      -- break the dashboard.
      local ok, ascii = pcall(require, "ascii")
      local planets = ok and ascii.art.planets and ascii.art.planets.planets
      if not (planets and planets.saturn) then
        return
      end
      opts.dashboard = opts.dashboard or {}
      opts.dashboard.preset = opts.dashboard.preset or {}
      opts.dashboard.preset.header = table.concat(planets.saturn, "\n")
    end,
  },
}
