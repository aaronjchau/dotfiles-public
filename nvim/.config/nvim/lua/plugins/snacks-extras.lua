-- Extra Snacks tweaks on top of LazyVim's defaults (animations live in
-- no-animations.lua; lazy deep-merges these snacks specs).
return {
  {
    "folke/snacks.nvim",
    opts = {
      -- Inline image rendering (image files, Markdown images, LaTeX/mermaid) via the
      -- terminal graphics protocol; tunnels through tmux due to `allow-passthrough on`.
      -- Raster + Markdown links work off the protocol alone; SVG/PDF/LaTeX need
      -- imagemagick plus tectonic/mmdc.
      image = { enabled = true },
      -- Show dotfiles + gitignored files by default across the pickers below.
      picker = {
        -- Plain-letter git status to match yazi's theme.toml signs (M/A/?/I/D/U), not Snacks' glyphs.
        icons = {
          git = {
            staged    = "A", -- Snacks collapses any staged change to one mark; A ≈ yazi's "added"
            added     = "A",
            modified  = "M",
            deleted   = "D",
            renamed   = "R",
            unmerged  = "U", -- yazi calls this "updated"
            untracked = "?",
            ignored   = "I",
          },
        },
        sources = {
          explorer = {
            hidden = true,
            ignored = true,
            diagnostics_open = true, -- roll LSP error/warn markers up to parent folders

            -- Narrow sidebar (must override min_width too, floored at 40) and hide the input bar.
            layout = { hidden = { "input" }, layout = { width = 30, min_width = 30 } },
            -- `.` toggles hidden (matches yazi); its default "focus dir as root" moves to `F`.
            -- Hide the sign column: unused here and its bg shows as a grey strip over the transparent explorer.
            win = { list = {
              wo = { signcolumn = "no" },
              keys = {
                ["."] = "toggle_hidden",
                ["F"] = "explorer_focus",
              },
            } },
          },
          -- Find Files (<leader><space>): show dotfiles so fd descends into `.config/` dirs.
          -- `.git/` stays excluded (finder hardcodes `-E .git`); ignored=false avoids flooding
          -- other projects with node_modules/.venv.
          files = { hidden = true },
          -- Grep (<leader>/): also search hidden files/dirs (covers the `.config/` trees).
          grep = { hidden = true },
          -- Buffers (<leader>fb): tab order (by buffer number), not most-recently-used,
          -- so the list matches the bufferline left-to-right.
          buffers = { sort_lastused = false },
        },
      },
    },
    -- <leader>gs: Snacks git-status picker (changed files + diff preview). LazyVim only
    -- binds this via the snacks_picker extra (not enabled), so wire it up here.
    keys = {
      { "<leader>gs", function() Snacks.picker.git_status() end, desc = "Git Status (Snacks)" },
      -- Symbol picker that works with or without an LSP: document symbols when a server
      -- provides them, else a treesitter outline. LazyVim's own <leader>ss is gated on an
      -- LSP, so it is absent in shell/config buffers that have none.
      {
        "<leader>ss",
        function()
          for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
            if c.server_capabilities and c.server_capabilities.documentSymbolProvider then
              return Snacks.picker.lsp_symbols()
            end
          end
          Snacks.picker.treesitter()
        end,
        desc = "Symbols (LSP / Treesitter)",
      },
    },
  },
}
