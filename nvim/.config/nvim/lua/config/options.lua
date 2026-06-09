-- LazyVim options — defaults: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua

-- Treat Zed's config (settings.json/keymap.json, which use // comments) as jsonc
-- so the JSON LSP doesn't flag the comments as errors.
vim.filetype.add({
  pattern = { [".*/zed/.*%.json"] = "jsonc" },
})

-- Tidy native tabline labels (shown only with >1 tab page, e.g. diffview's tab):
-- filename tail, or "Diffview" instead of the raw `diffview://…` URI.
local function tab_label(tabnr)
  local buflist = vim.fn.tabpagebuflist(tabnr)
  for _, b in ipairs(buflist) do
    local ft = (vim.bo[b].filetype or ""):lower()
    if ft:find("diffview") or vim.api.nvim_buf_get_name(b):match("^diffview://") then
      return "Diffview"
    end
  end
  local name = vim.api.nvim_buf_get_name(buflist[vim.fn.tabpagewinnr(tabnr)])
  return name ~= "" and vim.fn.fnamemodify(name, ":t") or "[No Name]"
end

function _G.MyTabline()
  local out = {}
  for i = 1, vim.fn.tabpagenr("$") do
    local hl = i == vim.fn.tabpagenr() and "%#TabLineSel#" or "%#TabLine#"
    local ok, label = pcall(tab_label, i)
    out[#out + 1] = hl .. "%" .. i .. "T " .. i .. " " .. (ok and label or "?") .. " "
  end
  return table.concat(out) .. "%#TabLineFill#%T"
end

vim.o.tabline = "%!v:lua.MyTabline()"
