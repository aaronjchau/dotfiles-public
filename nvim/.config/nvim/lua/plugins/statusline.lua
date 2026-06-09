-- mini.statusline with rounded-cap pills (U+E0B6 / U+E0B4) on a transparent bar, dark
-- text on coloured/gray blocks, matching the tmux bar. Shows mode, git, diagnostics,
-- filename, LSP breadcrumb, location, rendered in a single &statusline pass so multi-byte
-- icons don't fragment. Filename is relative to cwd (explorer root).
return {
  { "nvim-lualine/lualine.nvim", enabled = false },
  {
    "nvim-mini/mini.statusline",
    event = "VeryLazy",
    dependencies = { "folke/trouble.nvim" },
    config = function()
      local MiniStatusline = require("mini.statusline")
      local LEFT, RIGHT = vim.fn.nr2char(0xE0B6), vim.fn.nr2char(0xE0B4)
      local SEP = vim.fn.nr2char(0xE0B1) -- powerline thin separator (breadcrumb arrow)

      -- Rounded pill: caps carry the block colour as fg over transparent bg so it floats.
      local function bubble(cap_hl, block_hl, text)
        if not text or text == "" then
          return ""
        end
        return "%#" .. cap_hl .. "#" .. LEFT .. "%#" .. block_hl .. "#" .. text .. "%#" .. cap_hl .. "#" .. RIGHT
      end

      -- Breadcrumb: trouble's LSP symbol path.
      local symbols
      do
        local ok, trouble = pcall(require, "trouble")
        if ok then
          symbols = trouble.statusline({
            mode = "symbols",
            groups = {},
            title = false,
            filter = { range = true },
            format = " " .. SEP .. " {kind_icon}{symbol.name:Normal}",
            hl_group = "MiniStatuslineFilename",
          })
        end
      end
      local function breadcrumb()
        if not symbols or MiniStatusline.is_truncated(60) then
          return ""
        end
        local ok, has = pcall(symbols.has)
        if not ok or not has then
          return ""
        end
        local ok2, s = pcall(symbols.get)
        return (ok2 and s and s ~= "") and ("%#MiniStatuslineFilename#" .. s) or ""
      end

      -- Filename relative to cwd (the explorer's root), with modified/readonly flags.
      local function filename()
        if vim.bo.buftype == "terminal" then
          return "%t"
        end
        local name = vim.api.nvim_buf_get_name(0)
        if name == "" then
          return "%#StlFileName#[No Name]%m%r"
        end
        -- Really tight window: collapse to just the filename, no directory.
        if MiniStatusline.is_truncated(60) then
          local tail = (vim.fn.fnamemodify(name, ":t")):gsub("%%", "%%%%")
          return "%#StlFileName#" .. tail .. "%m%r"
        end
        local rel = vim.fn.fnamemodify(name, ":.")
        local dir = (rel:match("^(.*/)") or ""):gsub("%%", "%%%%")
        local tail = (rel:match("([^/]+)$") or rel):gsub("%%", "%%%%")
        return "%#StlPath#" .. dir .. "%#StlFileName#" .. tail .. "%m%r"
      end

      -- LSP server name(s) for the buffer, or "-" when none is attached.
      local function serverinfo()
        local gear = vim.fn.nr2char(0xEB51)
        local clients = vim.lsp.get_clients({ bufnr = 0 })
        if #clients == 0 then
          return gear .. " -"
        end
        local names = {}
        for _, c in ipairs(clients) do
          names[#names + 1] = c.name
        end
        return gear .. " " .. table.concat(names, " ")
      end

      -- Diagnostics as coloured codicons + counts: error, warning, info, hint.
      local DIAG = {
        { s = vim.diagnostic.severity.ERROR, cp = 0xEA87, hl = "DiagnosticError" },
        { s = vim.diagnostic.severity.WARN, cp = 0xEA6C, hl = "DiagnosticWarn" },
        { s = vim.diagnostic.severity.INFO, cp = 0xEA74, hl = "DiagnosticInfo" },
        { s = vim.diagnostic.severity.HINT, cp = 0xEA61, hl = "DiagnosticHint" },
      }
      local function diagnostics()
        local counts = vim.diagnostic.count(0)
        local parts = {}
        for _, d in ipairs(DIAG) do
          local n = counts[d.s]
          if n and n > 0 then
            parts[#parts + 1] = "%#" .. d.hl .. "#" .. vim.fn.nr2char(d.cp) .. " " .. n
          end
        end
        return table.concat(parts, " ")
      end

      -- Progress through the file by CURSOR line (vim's %P is window-view based:
      -- it only reports the top/bottom visible line, not the cursor).
      local function location()
        local cur, total = vim.fn.line("."), vim.fn.line("$")
        local pct = total <= 1 and 0 or math.floor((cur - 1) / (total - 1) * 100)
        return string.format("%d:%-2d %d%%%%", cur, vim.fn.virtcol("."), pct)
      end

      -- Git branch + change counts from gitsigns; nothing extra when the file is
      -- clean (avoids mini.statusline's "-" no-changes placeholder).
      local function gitinfo()
        local d = vim.b.gitsigns_status_dict
        if not d or not d.head or d.head == "" then
          return ""
        end
        local out = { vim.fn.nr2char(0xE0A0) .. " " .. d.head }
        for _, c in ipairs({ { d.added, "+" }, { d.changed, "~" }, { d.removed, "-" } }) do
          if c[1] and c[1] > 0 then
            out[#out + 1] = c[2] .. c[1]
          end
        end
        return table.concat(out, " ")
      end

      -- Search match position (N/M) while hlsearch is active.
      local function search()
        local s = MiniStatusline.section_searchcount({ trunc_width = 75 })
        return s ~= "" and (vim.fn.nr2char(0xEA6D) .. " " .. s) or ""
      end

      -- Macro recording indicator, e.g. "● REC @q" (red).
      local function macro()
        local r = vim.fn.reg_recording()
        return r ~= "" and ("%#StlMacro#" .. vim.fn.nr2char(0xEBB4) .. " REC @" .. r) or ""
      end

      local function active()
        local mode, mode_hl = MiniStatusline.section_mode({ trunc_width = 120 })
        local cap = mode_hl:gsub("MiniStatuslineMode", "StlCap")
        local diags = diagnostics()
        local gitdiff = gitinfo()
        local rec, find = macro(), search()

        local out = bubble(cap, mode_hl, " " .. vim.trim(mode):upper() .. " ")
        if gitdiff ~= "" then
          out = out .. " " .. bubble("StlSurfaceCap", "StlSurface", " " .. gitdiff .. " ")
        end
        if rec ~= "" then
          out = out .. "  " .. rec
        end
        if diags ~= "" then
          out = out .. "  " .. diags
        end
        out = out .. "  " .. filename() .. "%<" .. breadcrumb()
        out = out .. "%="
        if find ~= "" then
          out = out .. "%#MiniStatuslineDevinfo#" .. find .. "  "
        end
        local srv = serverinfo()
        if srv ~= "" then
          out = out .. bubble("StlSurfaceCap", "StlSurface", " " .. srv .. " ") .. " "
        end
        out = out .. bubble(cap, mode_hl, " " .. location() .. " ")
        return out
      end

      MiniStatusline.setup({
        content = { active = active },
        use_icons = true,
      })

      -- Pill colours: hardcoded Kanagawa Wave hexes to match the tmux bar exactly.
      -- Re-applied on every colorscheme load (a :colorscheme resets highlights).
      local function set_hl()
        local dark, fg = "#16161D", "#DCD7BA"
        local gray_bg, gray_fg = "#2A2A37", "#C8C093"
        local modes = {
          Normal = "#7E9CD8",
          Insert = "#98BB6C",
          Visual = "#957FB8",
          Replace = "#E46876",
          Command = "#E6C384",
          Other = "#7FB4CA",
        }
        local function set(g, o)
          vim.api.nvim_set_hl(0, g, o)
        end
        for name, color in pairs(modes) do
          set("MiniStatuslineMode" .. name, { fg = dark, bg = color, bold = true })
          set("StlCap" .. name, { fg = color, bg = "NONE" })
        end
        set("StlSurface", { fg = gray_fg, bg = gray_bg })
        set("StlSurfaceCap", { fg = gray_bg, bg = "NONE" })
        set("MiniStatuslineDevinfo", { fg = gray_fg, bg = "NONE" })
        set("MiniStatuslineFilename", { fg = fg, bg = "NONE" })
        set("StlPath", { fg = "#727169", bg = "NONE" }) -- dim directory
        set("StlFileName", { fg = fg, bg = "NONE", bold = true }) -- bold filename tail
        set("StlMacro", { fg = "#E46876", bg = "NONE", bold = true }) -- macro recording (red)
        set("MiniStatuslineInactive", { fg = gray_fg, bg = "NONE" })
        set("StatusLine", { bg = "NONE" })
        set("StatusLineNC", { bg = "NONE" })
      end
      set_hl()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = set_hl })

      -- Redraw the statusline so the macro indicator appears/clears immediately.
      vim.api.nvim_create_autocmd("RecordingEnter", {
        callback = function()
          vim.cmd("redrawstatus")
        end,
      })
      vim.api.nvim_create_autocmd("RecordingLeave", {
        callback = function()
          vim.schedule(function()
            vim.cmd("redrawstatus")
          end)
        end,
      })
    end,
  },
}
