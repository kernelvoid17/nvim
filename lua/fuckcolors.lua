vim.cmd('highlight clear')
vim.cmd('syntax reset')

-- Make all highlights white foreground and transparent background
for _, group in ipairs(vim.fn.getcompletion('', 'highlight')) do
  vim.api.nvim_set_hl(0, group, { fg = '#ffffff', bg = 'NONE' })
end

-- Add certain highlights
vim.api.nvim_set_hl(0, 'Visual', { bg = '#3a3a3a' })
vim.api.nvim_set_hl(0, "Search", { bg = "#3a3a3a" })
vim.api.nvim_set_hl(0, "IncSearch", { bg = "#3a3a3a" })


-- Add highlight for yanking
vim.api.nvim_set_hl(0, "YankHighlight", { bg = "#3a3a3a", fg = "NONE" })
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank({ higroup = "YankHighlight", timeout = 200 })
  end,
})

