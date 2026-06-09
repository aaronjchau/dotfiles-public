require("full-border"):setup()

require("git"):setup {
	order = 1500,
}

-- DuckDB data-file previews (CSV/TSV/JSON/Parquet). This setup() call is required.
require("duckdb"):setup {
	mode = "standard",  -- default to the data-table view (toggle to summary with K at top)
	row_id = "dynamic", -- row-number column that appears once you scroll columns (H/L)
}

-- yatline: header + status line. `hovered_size` = hovered file size (instant).
-- yatline-selected-size adds async cached selected size (recursive dir size + count) on <space> select.
-- Its setup() must run AFTER yatline:setup below — see the note there.
local yatline_theme = {
    -- yatline
    section_separator_open = "",
    section_separator_close = "",

    inverse_separator_open = "",
    inverse_separator_close = "",

    part_separator_open = "",
    part_separator_close = "",

    style_a = {
      fg = "#16161D",
      bg_mode = {
        normal = "#7E9CD8",
        select = "#957FB8",
        un_set = "#E46876",
      },
    },
    style_b = { bg = "#2A2A37", fg = "#DCD7BA" },
    style_c = { bg = "#16161D", fg = "#DCD7BA" },

    permissions_t_fg = "#98BB6C",
    permissions_r_fg = "#E6C384",
    permissions_w_fg = "#E46876",
    permissions_x_fg = "#7FB4CA",
    permissions_s_fg = "#957FB8",

    selected = { icon = "󰻭", fg = "#E6C384" },
    copied = { icon = "", fg = "#98BB6C" },
    cut = { icon = "", fg = "#E46876" },
    files = { icon = "", fg = "#7E9CD8" },
    filtereds = { icon = "", fg = "#957FB8" },

    total = { icon = "", fg = "#E6C384" },
    success = { icon = "", fg = "#98BB6C" },
    failed = { icon = "", fg = "#E46876" },

    -- yatline-githead
    branch_color = "#7FB4CA",
    remote_branch_color = "#7E9CD8",
    tag_color = "#7FB4CA",
    commit_color = "#957FB8",
    behind_remote_color = "#FFA066",
    ahead_remote_color = "#957FB8",
    stashes_color = "#D27E99",
    state_color = "#E46876",
    staged_color = "#E6C384",
    unstaged_color = "#FFA066",
    untracked_color = "#7AA89F",
  }
require("yatline"):setup {
	theme = yatline_theme,
	-- Header: keep tab indicators, drop date/time.
	header_line = {
		left = {
			section_a = {
				{ type = "line", name = "tabs" },
			},
		},
	},
	-- Status line = yatline's default layout + the selected-files-size component (left section_c).
	status_line = {
		left = {
			section_a = {
				{ type = "string", name = "tab_mode" },
			},
			section_b = {
				{ type = "string", name = "hovered_size" },
			},
			section_c = {
				{ type = "string", name = "hovered_path" },
				{ type = "coloreds", name = "count" },
				{ type = "coloreds", custom = false, name = "selected-files-size" },
			},
		},
		right = {
			section_a = {
				{ type = "string", name = "cursor_position" },
			},
			section_b = {
				{ type = "string", name = "cursor_percentage" },
			},
			section_c = {
				{ type = "string", name = "hovered_file_extension", params = { true } },
				{ type = "coloreds", name = "permissions" },
			},
		},
	},
}

-- Register the selected-size component INTO yatline. Must run after yatline:setup() above:
-- the addon guards on the `Yatline` global, which only exists once yatline is set up
-- (called before, it silently no-ops).
require("yatline-selected-size"):setup()

-- macOS Finder color tags shown inline in the file list (keymaps: `b a` add, `b r` remove).
require("mactag"):setup {
	keys = {
		r = "Red",
		o = "Orange",
		y = "Yellow",
		g = "Green",
		b = "Blue",
		p = "Purple",
	},
	colors = {
		Red    = "#ee7b70",
		Orange = "#f5bd5c",
		Yellow = "#fbe764",
		Green  = "#91fc87",
		Blue   = "#5fa3f8",
		Purple = "#cb88f8",
		-- Custom Finder tags map name -> display color here; mactag colors by tag NAME,
		-- not Finder's actual color, so each custom name needs an entry.
		Current  = "#91fc87", -- green
		Secure   = "#ee7b70", -- red
		Archived = "#f5bd5c", -- orange
	},
	order = 500,
}
