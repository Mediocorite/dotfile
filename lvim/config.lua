-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Glogbal keybindings
vim.opt.relativenumber = true;

-- Autocomplete modifications
local cmp = require('cmp')
lvim.builtin.cmp.mapping["<CR>"] = cmp.mapping.confirm({ select = true })

-- Copilot
lvim.plugins = {
  { "github/copilot.vim" },
  { "hrsh7th/cmp-copilot" }
}


-- Configure Copilot

-- Add Copilot as a completion source
table.insert(lvim.builtin.cmp.sources, { name = "copilot" })

-- Customize the display name in completion menu
lvim.builtin.cmp.formatting.source_names["copilot"] = "(Cop)"

-- Fixing the shift arrow behavior

lvim.plugins = {
  {
    "jakobkhansen/journal.nvim",
    config = function()
        require("journal").setup({
    filetype = 'md',                    -- Filetype to use for new journal entries
    root = '~/Documents/journal',                 -- Root directory for journal entries
    date_format = '%d/%m/%Y',           -- Date format for `:Journal <date-modifier>`
    autocomplete_date_modifier = "end", -- "always"|"never"|"end". Enable date modifier autocompletion

    -- Configuration for journal entries
    journal = {
        -- Default configuration for `:Journal <date-modifier>`
        format = '%Y/%m-%B/daily/%d-%A',
        template = '# %A %B %d %Y\n',
        frequency = { day = 1 },

        -- Nested configurations for `:Journal <type> <type> ... <date-modifier>`
        entries = {
            day = {
                format = '%Y/%m-%B/daily/%d-%A', -- Format of the journal entry in the filesystem.
                template = '# %A %B %d %Y\n',    -- Optional. Template used when creating a new journal entry
                frequency = { day = 1 },         -- Optional. The frequency of the journal entry. Used for `:Journal next`, `:Journal -2` etc
            },
            week = {
                format = '%Y/%m-%B/weekly/week-%W',
                template = "# Week %W %B %Y\n",
                frequency = { day = 7 },
                date_modifier = "monday" -- Optional. Date modifier applied before other modifier given to `:Journal`
            },
            month = {
                format = '%Y/%m-%B/%B',
                template = "# %B %Y\n",
                frequency = { month = 1 }
            },
            year = {
                format = '%Y/%Y',
                template = "# %Y\n",
                frequency = { year = 1 }
            },
        },
    }
})
    end,
},
}
