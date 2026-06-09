-- Kanagawa (Wave) — matches ghostty, tmux, yazi, lazygit, gh-dash.
return {
  {
    "rebelot/kanagawa.nvim",
    opts = {
      theme = "wave",
      -- Transparent bg: let Ghostty's 0.95 opacity + blur 20 show through inside nvim.
      transparent = true,
      overrides = function(colors)
        return {
          -- flash.nvim jump label: dark bold letter on bright peachRed so it stands out from matches.
          FlashLabel = { fg = "#16161D", bg = "#FF5D62", bold = true },
          -- Blank the gutter bg: kanagawa tints sign/number/fold columns grey even in transparent mode.
          SignColumn = { bg = "none" },
          LineNr = { bg = "none" },
          FoldColumn = { bg = "none" },
          -- render-markdown: bold Kanagawa-accent heading text on subtle theme-tinted blocks, and a
          -- visible code panel. render-markdown blends its own colors against the (transparent) bg,
          -- which renders washed out — so set explicit palette colors. Custom groups (referenced from
          -- markdown.lua) so the plugin doesn't recompute over them; defined here to survive reloads.
          MdH1 = { fg = "#7E9CD8", bold = true },
          MdH1Bg = { bg = "#223249" }, -- crystalBlue / waveBlue1
          MdH2 = { fg = "#98BB6C", bold = true },
          MdH2Bg = { bg = "#2B3328" }, -- springGreen / winterGreen
          MdH3 = { fg = "#E6C384", bold = true },
          MdH3Bg = { bg = "#49443C" }, -- carpYellow / winterYellow
          MdH4 = { fg = "#7FB4CA", bold = true },
          MdH4Bg = { bg = "#252535" }, -- springBlue / winterBlue
          MdH5 = { fg = "#957FB8", bold = true },
          MdH5Bg = { bg = "#363646" }, -- oniViolet / sumiInk
          MdH6 = { fg = "#D27E99", bold = true },
          MdH6Bg = { bg = "#43242B" }, -- sakuraPink / winterRed
          MdCode = { bg = "#2A2A37" }, -- code block panel (sumiInk gray)
          -- Heading TEXT color comes from this treesitter capture (render-markdown's foregrounds
          -- only color the icon), and kanagawa leaves it empty — link to the bold accent groups.
          ["@markup.heading.1.markdown"] = { link = "MdH1" },
          ["@markup.heading.2.markdown"] = { link = "MdH2" },
          ["@markup.heading.3.markdown"] = { link = "MdH3" },
          ["@markup.heading.4.markdown"] = { link = "MdH4" },
          ["@markup.heading.5.markdown"] = { link = "MdH5" },
          ["@markup.heading.6.markdown"] = { link = "MdH6" },
        }
      end,
    },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "kanagawa-wave" } },
}
