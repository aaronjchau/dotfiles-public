-- Markdown: disable markdownlint; tune render-markdown (LazyVim's lang.markdown renderer).
-- Not markview — it can't render tables while `wrap` is set (documented limitation), and
-- LazyVim enables wrap for markdown.
return {
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = {},
        ["markdown.mdx"] = {},
      },
    },
  },
  {
    "MeanderingProgrammer/render-markdown.nvim",
    opts = {
      debounce = 200, -- viewport re-parse throttle (ms); fewer re-renders while scrolling
      max_file_size = 5.0, -- MB; skip rendering past this
      anti_conceal = { enabled = false }, -- keep the cursor line rendered; no cursor-move re-render
      pipe_table = { preset = "round" }, -- rounded table borders
      heading = {
        sign = false, -- no heading marker in the sign column
        width = "block", -- background only as wide as the heading text, not the window
        border = true, -- rule above/below each heading for separation
        foregrounds = { "MdH1", "MdH2", "MdH3", "MdH4", "MdH5", "MdH6" }, -- bold accent text (colorscheme.lua)
        backgrounds = { "MdH1Bg", "MdH2Bg", "MdH3Bg", "MdH4Bg", "MdH5Bg", "MdH6Bg" },
      },
      code = { sign = false, width = "block", highlight = "MdCode" }, -- no code sign; visible panel bg
    },
  },
}
