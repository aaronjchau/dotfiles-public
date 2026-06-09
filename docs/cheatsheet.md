# Keymap Cheat Sheet

Frequently used keys for this setup.

## Foundation

- **Caps Lock**: tap = `Esc`, hold = `Ctrl` (Karabiner). Makes `Ctrl-a`, `Ctrl-hjkl` home-row holds.
- **Esc on the home row**: tap Caps (everywhere), or `jj` in nvim insert mode and zsh vi-mode (needs `KEYTIMEOUT=20`).
- **Modifiers**: `Option`/`alt` = AeroSpace (macOS windows), `Ctrl` (Caps) = tmux + cross-pane nav, `Space` = nvim leader.
- **Discovery**: in nvim, press `<leader>` and wait for the which-key menu (browse by pressing). `<leader>sk` searches all keymaps.

## Mental model

"Window" means different things: a tab in tmux, a split in nvim. Collapse to three ideas:

| Think of it as | Which is | Switch with |
|---|---|---|
| A box on screen | tmux pane or nvim split | `Ctrl-h/j/k/l` (same for both) |
| An open file | nvim buffer | `Shift-h` / `Shift-l` |
| A project | tmux session | `prefix s` (sesh) |

`Ctrl-hjkl` (Caps+hjkl) crosses nvim splits and tmux panes (vim-tmux-navigator), so the same keys work whichever you are in. Convention: panes for programs, splits for files; one tmux session per project; macOS apps on AeroSpace workspaces.

> **Buffers vs tab pages (nvim).** bufferline is disabled, so there is no buffer tab bar. Cycle open files (buffers) with `Shift-h` / `Shift-l` (native `:bprevious` / `:bnext`). Tab pages use `gt` / `gT` / `{N}gt`; the native tabline auto-shows only with more than one tab page (e.g. when diffview opens its own tab, `1gt` returns to your code).

## AeroSpace
Modifier: Option/alt.

| Key | Action |
|---|---|
| `alt + h/j/k/l` | focus window left / down / up / right |
| `alt + shift + h/j/k/l` | move focused window left / down / up / right |
| `alt + shift + ←/↓/↑/→` | join window into neighbor (build a split) |
| `alt + - / =` | resize smaller / larger |
| `alt + 1`…`9` | switch to workspace 1-9 |
| `alt + a/c/d/i/m/n/s` | app workspaces: A Music, C Chrome, D Dev (Ghostty/Zed/Code), I AI (Claude/ChatGPT), M Msg (Messages/Mail/Notion Mail), N Notion/Cron, S Safari |
| `alt + shift + <1-9 / letter>` | move window to that workspace |
| `alt + tab` | back-and-forth to last workspace |
| `alt + shift + tab` | move workspace to next monitor (wraps) |
| `alt + shift + f` | toggle window floating / tiled |
| `alt + ctrl + f` | fullscreen |
| `alt + slash` / `alt + comma` | layout tiles / accordion |
| `alt + shift + ;` | service mode (`esc` reload, `r` reset tree, `f` float toggle, `backspace` close others, `alt-shift-h/j/k/l` join) |

No auto-reload: after editing `aerospace.toml`, reload via service mode (`alt-shift-;` then `esc`) or `aerospace reload-config`. `alt-*` are macOS global hotkeys and silently lose to other apps' hotkeys (e.g. Raycast on `Option+L`); diagnose with `aerospace focus right`, and if the CLI works the key is being stolen upstream.

## tmux

Prefix: Ctrl-a (Caps+a).

**Sessions and windows**
| Key | Action |
|---|---|
| `prefix s` / `prefix S` | sesh picker (sessions first) / jump to last session |
| `prefix w` | window picker (tv) |
| `prefix H` / `prefix L` | prev / next window (`prefix N` also prev) |
| `prefix Ctrl-a` / `prefix Tab` | last window (toggle between two) |
| `prefix Ctrl-c` | new window (current dir) |
| `prefix R` | rename window |
| `prefix d` | detach client |
| `prefix p` | floating terminal (floax) |

**Panes**
| Key | Action |
|---|---|
| `prefix v` / `prefix h` | split side-by-side / stacked (`prefix \|` side-by-side too) |
| `prefix e` | flip layout side-by-side / stacked |
| `Ctrl-h/j/k/l` | move between panes (crosses nvim splits) |
| `Ctrl-\` | previous pane (last active) |
| `prefix , . - =` | resize pane left / right / down / up (repeatable) |
| `prefix z` / `prefix x` | zoom / swap pane |
| `prefix c` | kill pane (no confirm; new-window is `prefix Ctrl-c`) |

> Split key naming is inverted vs the tmux flag, named by visual result: `prefix v` = side-by-side (`-h`), `prefix h` = stacked (`-v`).

**Tools and misc**
| Key | Action |
|---|---|
| `prefix Space` | tmux-thumbs, hint-jump to copy on-screen text (paths, SHAs, URLs) |
| `prefix u` | tmux-fzf-url, pick an on-screen URL and open in browser |
| `prefix [` / `v` / `y` | enter copy-mode / begin selection / yank (to macOS clipboard via OSC52) |
| `prefix r` / `prefix I` / `prefix U` | reload config / install / update plugins |
| `prefix Ctrl-l` | clear screen (plain `Ctrl-l` is taken by pane-nav) |

**Shell aliases:** `ts` = sesh picker (`tv sesh`). `sclone <url>` = clone a git repo into a new session (`sesh clone`).

## television (`tv`)
Fuzzy finder. Grammar: `tv [channel] [path]`; `tv` alone = files.

| Channel | What it does | Extra keys |
|---|---|---|
| `tv files` (`f1`) | find files, open in nvim | `Ctrl-s` cycles tracked / +hidden / +ignored |
| `tv text` | ripgrep contents, open in nvim at the matched line | `Ctrl-s` cycles visible / +hidden |
| `tv dirs` (`f2`) | dir, open shell there | |
| `tv zoxide` | frecency dir jump, open shell there | `Ctrl-d` removes dir from zoxide db |
| `tv git-log` | browse commits (preview = full patch) | `Ctrl-y` cherry-pick, `Ctrl-o` checkout (detaches HEAD) |
| `tv sesh` (`prefix s`) | session picker | `Ctrl-s` cycles MRU / all / zoxide / `fd` scan of ~, `Ctrl-d` kills session |
| `tv tmux-windows` (`prefix w`) | switch windows in the current session | `Ctrl-d` kills window |

Inside a picker (global defaults): `Ctrl-j`/`Ctrl-k` move, `Enter` confirm, `Ctrl-d`/`Ctrl-u` scroll preview half-page, `Ctrl-s` cycle sources, `Ctrl-r` switch channel, `Ctrl-o` toggle preview, `Ctrl-f` cycle previews, `Ctrl-y` copy entry, `Ctrl-up`/`Ctrl-down` history, `Tab`/`Shift-Tab` multi-select, `Esc` quit. Some channels rebind these: `Ctrl-d` kills/removes in sesh, zoxide, and tmux-windows; `Ctrl-o`/`Ctrl-y` are checkout/cherry-pick in git-log (the per-channel keys above).

Don't run `tv <channel>` from a dir that has a same-named subdir (tv parses the bareword as the path positional and falls back to files). `prefix s`/`prefix w` force `-d "#{HOME}"`; manual equivalent is `cd ~ && tv sesh`.

## Neovim (LazyVim)

Leader: Space.

### Discovery & setup
Leader = `Space`. Snacks is the default picker (LazyVim auto-imports `editor.snacks_picker`), so the `<leader>f*` / `<leader>s*` picker maps below are live.

| Key | Action |
|---|---|
| `<leader>` then wait | which-key menu (browse by pressing, not searchable) |
| `<leader>sk` | search all keymaps (fuzzy) |
| `<leader>?` | buffer-local keymaps |
| `<c-w><space>` | window hydra mode |
| `jj` (insert) | exit to normal mode (Esc) |
| `:Lazy` / `:LazyExtras` / `:Mason` / `:Tutor` | plugins / features / LSP servers / learn vim |

Inside the which-key popup: `<c-d>`/`<c-u>` scroll, `<bs>` up a level, `<esc>` close. Navigate by pressing the next key.

### Find & search
Snacks pickers.

| Key | Action |
|---|---|
| `<leader>ff` / `<leader>fF` / `<leader>fg` | find files (root / cwd / git-files) |
| `<leader><space>` | find files (root) |
| `<leader>fr` / `<leader>fR` | recent files (all / cwd) |
| `<leader>fb` / `<leader>,` | buffers picker |
| `<leader>fc` / `<leader>fp` | config file / projects |
| `<leader>/` / `<leader>sg` / `<leader>sG` | grep project (root) / grep root / grep cwd |
| `<leader>sw` / `<leader>sW` | grep word or selection (root / cwd) |
| `<leader>sb` / `<leader>sB` | grep current buffer lines / grep open buffers |
| `<leader>sk` / `<leader>sR` | keymaps picker / resume last picker |
| `<leader>sd` / `<leader>sD` / `<leader>sj` / `<leader>sm` | diagnostics all / buffer / jumps / marks |
| `<leader>su` / `<leader>sq` / `<leader>sl` | undotree / quickfix / location pickers |
| `<leader>sr` | search and replace (grug-far) |
| `<leader>e` | yazi file browser |

Inside a Snacks picker: scroll the list with `<c-d>`/`<c-u>`, scroll the preview with `<c-f>`/`<c-b>`. `<Tab>` select item, `<c-q>` send to quickfix, `<c-s>`/`<c-v>` open in split/vsplit, `<c-t>` open in tab, `<a-h>`/`<a-i>` toggle hidden/ignored, `<a-w>` cycle window.

### Navigate
Splits, buffers, tabs.

| Key | Action |
|---|---|
| `Ctrl-h/j/k/l` | move across splits and tmux panes |
| `Ctrl-\` | previous split/pane |
| `<leader>\|` / `<leader>-` | split right / below |
| `<leader>wd` / `<leader>uz` / `<leader>uZ` | close window / zen / zoom |
| `Shift-h` / `Shift-l` (`[b`/`]b`) | prev / next buffer |
| `<leader>bd` | close buffer |
| `<C-/>` | toggle terminal |
| `gt` / `gT` / `{N}gt` | next / prev tab page / jump to tab N (diffview opens its own tab, `1gt` returns to code) |
| `<leader><tab>…` | tab-page management |

### Jumping & motion
| Key | Action |
|---|---|
| `s` / `S` | flash jump (screen / treesitter node), high-contrast label |
| `r` (o-mode) / `R` (o/x) | remote flash / treesitter-search flash |
| `<c-s>` (cmdline) | toggle flash in search |
| `Ctrl-o` / `Ctrl-i` | jumplist back / forward |
| `g;` / `g,` | changelist back / forward (recent edits) |
| `` `` `` / `` `. `` | spot before last jump / last change |
| `ma` then `` `a `` | set / jump to mark |
| `*` / `#` | next / prev use of word under cursor |
| `gf` | open file under cursor |
| `zz` · `Ctrl-d` / `Ctrl-u` | recenter · half-page down / up |
| `]q` / `[q` · `]t` / `[t` | next/prev quickfix · next/prev TODO comment |
| `%` · `[{` / `]}` | matching bracket · enclosing brackets |

### Edit & read code (LSP)
Leader is Space.
| Key | Action |
|---|---|
| `gd` | definition |
| `gr` · `gD` | references · declaration |
| `gI` | implementation (interface/abstract to concrete; returns nothing on a plain function) |
| `gy` | type definition |
| `K` / `gK` | hover docs / signature help (`<C-k>` in insert) |
| `gai` / `gao` · `]]` / `[[` | incoming / outgoing calls · next / prev reference |
| `<leader>ss` / `<leader>sS` | symbols in file / project |
| `<leader>cs` · `<leader>cd` | symbols outline (Trouble) · line diagnostics float |
| `<leader>cr` / `<leader>cR` | rename symbol / rename file |
| `<leader>ca` / `<leader>cA` / `<leader>co` | code action / source action / organize imports |
| `<leader>cl` · `<leader>cc` / `<leader>cC` | LSP info · run / refresh codelens |
| `]d` / `[d` · `]e` / `[e` · `]w` / `[w` | next/prev diagnostic · error · warning |
| `<leader>xx` / `<leader>xX` | diagnostics / buffer diagnostics (Trouble) |
| `gcc` / `gc` (visual) · `<C-s>` · `<leader>cf` | toggle comment · save · format |
| motions | `w`/`b` word · `0`/`$` line · `gg`/`G` top/bottom · `f<char>` to char |

No LSP for shell scripts (`.sh`/`.zsh`); `gd` errors ("no LSP"). With-LSP langs: Lua, Python (pyright, needs node), TS/JS, Svelte, Tailwind, JSON, YAML, TOML, Markdown (marksman), Docker, SQL. To add shell LSP, run `:LazyExtras` and enable `util.dot` (enables bashls; there is no `lang.sh` extra).

### Textobjects
mini.ai, with `v`/`d`/`c`/`y` + `i`nner / `a`round.
| Key | Object |
|---|---|
| `if`/`af` · `ic`/`ac` | function · class |
| `io`/`ao` · `it`/`at` | code block (cond/loop) · HTML/XML tag |
| `id`/`ad` · `ie`/`ae` | digits · word-with-case |
| `iu`/`au` · `iU`/`aU` | function-call usage (U = no dot in name) |
| `ig`/`ag` · `ih` | whole buffer · git hunk (`ih` from gitsigns, `o`/`x` modes) |
| standard | `iw aw ip ap i( i{ i[ i" i'` ... |

mini.surround: `gsa` add · `gsd` delete · `gsr` replace · `gsf`/`gsF` find right/left · `gsh` highlight · `gsn` update-n-lines.

### Git review & hunks
Four review surfaces:

| Surface | Key / cmd | What it does |
|---|---|---|
| Git status | `<leader>gs` | changed files + diff preview, pick a file (Snacks) |
| Git log | `<leader>gl` · `<leader>gL` | browse commits, preview only (Enter checks out the commit, detaches HEAD); `gL` = cwd scope |
| Diffview | `<leader>gv` / `<leader>gV` | full-window diff in its own tab page (see below) |
| lazygit | `<leader>gg` / `<leader>gG` | full TUI: stage/commit/rebase/branch (root / cwd) |

| Key | Action |
|---|---|
| `<leader>gf` · `<leader>gb` | current file history · blame line |
| `<leader>gd` / `<leader>gD` · `<leader>gS` | git diff hunks / vs origin · git stash (Snacks) |
| `<leader>gi` / `<leader>gI` · `<leader>gp` / `<leader>gP` | GitHub issues open / all · PRs open / all (Snacks, needs gh) |
| `<leader>gB` / `<leader>gY` | open on GitHub / copy GitHub URL |
| `]h` / `[h` · `]H` / `[H` | next/prev hunk · last/first hunk (gitsigns) |
| `<leader>ghp` · `<leader>go` | preview hunk inline · mini.diff overlay (all changes inline) |
| `gh` / `gH` | mini.diff apply-hunk / reset-hunk operators (+ `gh` hunk textobject; `ih` is the gitsigns hunk textobject) |
| `<leader>ghs` / `<leader>ghr` | stage / reset hunk |
| `<leader>ghS` / `<leader>ghu` / `<leader>ghR` | stage buffer / undo stage hunk / reset buffer |
| `<leader>ghb` / `<leader>ghB` | blame line (full) / blame buffer |
| `<leader>ghd` / `<leader>ghD` | diff this / diff this ~ |
| `<leader>uG` | toggle git signs |

> mini.diff and gitsigns coexist. gitsigns owns the sign-column hunks, `]h`/`[h`/`]H`/`[H`, `<leader>gh*` stage/reset, blame, and minimap; mini.diff adds only the `<leader>go` overlay, `gh`/`gH` operators, and the `gh` textobject (its hunk-jump maps are blanked). In vim-diff / Diffview the hunk nav is `]c`/`[c`.

### Diffview
diffview-plus (fork of sindrets/diffview, same module + `Diffview*` commands). Opens in its own tab page (`gt`/`1gt` to switch tabs).

| Key / cmd | Action |
|---|---|
| `<leader>gv` | toggle: open uncommitted-changes review, or close a live view (from any tab) |
| `<leader>gV` | working-tree history (commit-timeline panel; repo-wide, not the current file. Use `:DiffviewFileHistory %` for current file) |
| `:DiffviewOpen main...<branch>` | branch review: file panel + cumulative diff |
| `q` | close (from the file panel or the file-history panel) |
| `<Tab>` / `<S-Tab>` | next / prev file's diff |
| `]c` / `[c` | next / prev change (hunk) |
| `zM` / `zR` | collapse all folds / expand all folds |
| `gf` · `g?` | open the real file · help panel |
| *file panel:* `j`/`k` · `<CR>` · `-` (or `s`) | move · open diff · stage/unstage file |
| *history panel:* `j`/`k` · `<CR>` · `y` | move commits · open commit · copy hash |
| `:DiffviewClose` | close and return |

### Inline images

- `Snacks.image` renders images inline: image files, Markdown image links, LaTeX/mermaid (via Ghostty kitty-graphics, tunnels through tmux). SVG/PDF/LaTeX need `imagemagick` plus `tectonic`/`mmdc`; raster and Markdown links work off kitty-graphics alone.

### Claude Code
Leader `<leader>a…`.

| Key | Action |
|---|---|
| `<leader>ac` | toggle Claude |
| `<leader>af` | focus Claude |
| `<leader>ar` | resume Claude |
| `<leader>aC` | continue Claude |
| `<leader>ab` | add current buffer |
| `<leader>as` (v) | send selection |
| `<leader>aa` / `<leader>ad` | accept / deny diff |

### UI toggles
Leader `<leader>u…`.

| Key | Action |
|---|---|
| `<leader>uf` / `<leader>uF` | format-on-save (buffer / global) |
| `<leader>ud` | diagnostics |
| `<leader>uS` / `<leader>ua` | smooth scroll / animations |
| `<leader>uw` | wrap |
| `<leader>ul` / `<leader>uL` | line / relative numbers |
| `<leader>uh` / `<leader>uT` | inlay hints / treesitter highlight |
| `<leader>uc` | conceal |
| `<leader>ug` | indent guides |
| `<leader>ub` / `<leader>uD` | background / dim |
| `<leader>uG` / `<leader>uM` | git signs / minimap (mini.map) |
| `<leader>uC` | colorscheme picker |
| `<leader>ur` | clear hlsearch |

## yazi

### From inside Neovim
yazi.nvim; leader = `Space`.

| Key | Action |
|---|---|
| `<leader>e` | open yazi at current file |
| `<leader>cw` | open yazi in nvim's cwd |
| `<C-up>` | resume last yazi session |
| `Enter` | open file in nvim (folder = enter it) |
| `<C-v>` / `<C-x>` / `<C-t>` | open in vsplit / split / tab |
| `<C-s>` | grep current dir (Snacks picker) |
| `q` | quit |
| `F1` | help |

### Standalone
Custom keymaps in `yazi/.config/yazi/keymap.toml`.

| Key | Action |
|---|---|
| `y` | yank + copy to macOS clipboard |
| `g p` | paste file(s) from system clipboard |
| `Ctrl-g` | open lazygit in current dir |
| `Ctrl-p` | read hovered Markdown in mdterm |
| `b a` / `b r` | add / remove macOS Finder tag (then pick a color) |
| `g s` | size of selection (or cwd) |
| `H` / `L` | DuckDB scroll one column left / right |
| `g o` / `g u` | open in DuckDB / DuckDB web UI |

Rich previews: CSV/TSV/JSON/Parquet render as an interactive DuckDB table (`J`/`K` rows, `H`/`L` cols), `.md` via mdterm, `.ipynb` via nbpreview. After any `ya pkg upgrade`, re-run `./scripts/apply-patches.sh` to re-patch duckdb / nbpreview / yatline-selected-size.
