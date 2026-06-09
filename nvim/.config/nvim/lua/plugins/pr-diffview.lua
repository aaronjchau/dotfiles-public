-- Adds "Open in diffview" entries to the <leader>gp PR actions menu, alongside Snacks'
-- "View PR diff". Reviews a PR without checking it out: fetches the PR head into a
-- throwaway ref (refs/diffview/pr-<n>) and diffviews against a base. No branch switch,
-- working tree untouched. Assumes the `origin` remote; stale refs/diffview/* are safe to delete.

local function diffview_pr(item, base)
  if not (item and item.number) then
    return Snacks.notify.error("No PR selected")
  end
  local n = item.number
  local prref = "refs/diffview/pr-" .. n
  Snacks.notify("Fetching PR #" .. n .. " …")
  vim.system(
    { "git", "fetch", "--no-tags", "origin", "+refs/pull/" .. n .. "/head:" .. prref },
    { text = true },
    function(out)
      vim.schedule(function()
        if out.code ~= 0 then
          return Snacks.notify.error("Fetch failed for PR #" .. n .. ":\n" .. (out.stderr or ""))
        end
        -- Wipe stale unloaded diffview:// buffers first: stable ref/commit shas make
        -- buffer names collide on re-review (often resurrected by session restore),
        -- which errors "Found unloaded diffview:// buffer".
        for _, b in ipairs(vim.api.nvim_list_bufs()) do
          if not vim.api.nvim_buf_is_loaded(b) and vim.api.nvim_buf_get_name(b):find("^diffview://") then
            pcall(vim.api.nvim_buf_delete, b, { force = true })
          end
        end
        vim.cmd(("DiffviewOpen %s...%s"):format(base, prref))
      end)
    end
  )
end

local function default_base()
  local out = vim.system({ "git", "rev-parse", "--abbrev-ref", "origin/HEAD" }, { text = true }):wait()
  local b = out.code == 0 and vim.trim(out.stdout or "") or ""
  return b ~= "" and b or "origin/main"
end

local function pick_base(item)
  local remotes = {}
  for _, r in ipairs(vim.split((vim.system({ "git", "remote" }, { text = true }):wait().stdout or ""), "\n", { trimempty = true })) do
    remotes[r] = true
  end
  local out = vim.system({ "git", "for-each-ref", "--format=%(refname:short)", "refs/heads", "refs/remotes" }, { text = true }):wait()
  local branches = {}
  for _, b in ipairs(vim.split(out.stdout or "", "\n", { trimempty = true })) do
    if not b:match("HEAD") and not remotes[b] then
      branches[#branches + 1] = b
    end
  end
  vim.ui.select(branches, { prompt = "Diffview PR #" .. item.number .. " against:" }, function(choice)
    if choice then
      diffview_pr(item, choice)
    end
  end)
end

return {
  {
    "folke/snacks.nvim",
    optional = true,
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        once = true,
        callback = function()
          local ok, gh = pcall(require, "snacks.gh.actions")
          if not ok then
            return
          end
          gh.actions.gh_diffview = {
            desc = "Open in diffview",
            icon = vim.fn.nr2char(0xEAFD) .. " ", -- cod-git_compare (codicon, renders)
            priority = 95,
            type = "pr",
            title = "Diffview: PR #{number} vs default branch",
            action = function(item)
              diffview_pr(item, default_base())
            end,
          }
          gh.actions.gh_diffview_branch = {
            desc = "Open in diffview (pick base)",
            icon = vim.fn.nr2char(0xEAE1) .. " ", -- cod-diff (codicon, renders)
            priority = 94,
            type = "pr",
            title = "Diffview: PR #{number} vs a branch…",
            action = function(item)
              pick_base(item)
            end,
          }
        end,
      })
    end,
  },
}
