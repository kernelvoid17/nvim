-- Basic Editor Options
-- vim.opt.number = true
-- vim.opt.relativenumber = true
-- vim.opt.statuscolumn = "%l  "
vim.opt.number = false
vim.opt.relativenumber = false
vim.opt.showmode = true
vim.opt.tabstop = 2
vim.opt.shiftwidth = 2

-- UI/UX Enhancements
vim.opt.guicursor = 'n-v-i-c:block-Cursor'
vim.opt.cursorline = false
vim.opt.laststatus = 0
vim.opt.ruler = false
vim.opt.showmode = false
vim.opt.signcolumn = 'no'
vim.opt.inccommand = 'split'
vim.g.have_nerd_font = true
vim.opt.fillchars:append({ eob = " " })

-- Editing Experience
vim.opt.confirm = true
vim.opt.scrolloff = 7
vim.opt.breakindent = true
vim.opt.undofile = true

vim.opt.hlsearch = true
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>')

-- vim.opt.autoread = true

-- Search and Pattern Matching
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Clipboard and Mouse Integration
vim.opt.mouse = 'a'

-- Split Window Behavior
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Disable next line comment
vim.api.nvim_create_autocmd("FileType", {
	pattern = "*",
	callback = function()
		vim.opt_local.formatoptions:remove({ "c", "r", "o" })
	end,
})
