-- Read the docs: https://www.lunarvim.org/docs/configuration
-- Example configs: https://github.com/LunarVim/starter.lvim
-- Video Tutorials: https://www.youtube.com/watch?v=sFA9kX-Ud_c&list=PLhoH5vyxr6QqGu0i7tt_XoVK9v-KvZ3m6
-- Forum: https://www.reddit.com/r/lunarvim/
-- Discord: https://discord.com/invite/Xb9B4Ny

-- Glogbal keybindings
vim.opt.relativenumber = true;
vim.opt.wrap = true;
-- Autocomplete modifications
local cmp = require('cmp')
lvim.builtin.cmp.mapping["<CR>"] = cmp.mapping.confirm({ select = true })
lvim.builtin.noice.active = false;
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
        filetype = 'md',          -- Filetype to use for new journal entries
        root = '~/Documents/journal', -- Root directory for journal entries
      })
    end,
  },
}
