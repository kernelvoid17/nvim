vim.opt.completeopt = "menu,menuone,noselect"
vim.keymap.set("i", "<C-Space>", "<C-x><C-o>", { silent = true, desc = "Trigger LSP omni completion" })
vim.opt.shortmess:append("c")
vim.lsp.handlers["textDocument/signatureHelp"] = function() end

vim.diagnostic.config({
	virtual_text = false,
	underline = true,
	signs = true,
	update_in_insert = false,
	severity_sort = true,
})

vim.keymap.set("n", "<leader>d", vim.diagnostic.open_float, { desc = "Line diagnostics" })
vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, { desc = "Prev diagnostic" })
vim.keymap.set("n", "]d", vim.diagnostic.goto_next, { desc = "Next diagnostic" })

local root_patterns = {
	"pyproject.toml", "poetry.lock", "setup.py", "requirements.txt",
	"Cargo.toml",
	"compile_commands.json", "compile_flags.txt", "CMakeLists.txt",
	"package.json",
	".git",
}

local capabilities = {
	textDocument = {
		completion = { 
			completionItem = { snippetSupport = true } 
		},
	},
}

vim.lsp.config("*", {
	root_markers = root_patterns,
	capabilities = capabilities,
})

-- Python
vim.lsp.config("pyright", {
	cmd = { "pyright-langserver", "--stdio" },
	filetypes = { "python" },
	settings = {
		python = {
			analysis = {
				typeCheckingMode = "basic",
			},
		},
	},
})

-- Rust
vim.lsp.config("rust_analyzer", {
	cmd = { "rust-analyzer" },
	filetypes = { "rust" },
	settings = {
		["rust-analyzer"] = {
			cargo = {
				allFeatures = true,
				buildScripts = { enable = true },
			},
			procMacro = { enable = true },
			completion = {
				autoimport = { enable = true },
				fullFunctionSignatures = { enable = true },
			},
			imports = {
				granularity = { group = "module" },
				prefix = "by_crate",
			},
			check = { command = "clippy" },
		},
	},
})

-- Lua
vim.lsp.config("lua_ls", {
	cmd = { "lua-language-server" },
	filetypes = { "lua" },
	settings = {
		Lua = {
			runtime = { version = "LuaJIT" },
			diagnostics = { globals = { "vim" } },
			workspace = {
				checkThirdParty = false,
				library = { vim.env.VIMRUNTIME },
			},
			telemetry = { enable = false },
			format = { enable = true },
		},
	},
})

-- C/C++
vim.lsp.config("clangd", {
	cmd = { "clangd", "--background-index", "--clang-tidy" },
	filetypes = { "c", "cpp", "objc", "objcpp" },
})

-- HTML/CSS/JavaScript/TypeScript
vim.lsp.config("ts_ls", {
	cmd = { "typescript-language-server", "--stdio" },
	filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact" },
})

vim.lsp.config("html", {
	cmd = { "vscode-html-language-server", "--stdio" },
	filetypes = { "html" },
})

vim.lsp.config("cssls", {
	cmd = { "vscode-css-language-server", "--stdio" },
	filetypes = { "css", "scss", "less" },
})

-- Enable all LSP servers
vim.lsp.enable({ "pyright", "rust_analyzer", "lua_ls", "clangd", "ts_ls", "html", "cssls" })

vim.api.nvim_create_autocmd("LspAttach", {
	callback = function(args)
		local bufnr = args.buf
		local client = vim.lsp.get_client_by_id(args.data.client_id)
		vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
		
		local function bufmap(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, silent = true, desc = desc })
		end
		
		bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
		bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
		bufmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
		bufmap("n", "gr", vim.lsp.buf.references, "References")
		bufmap("n", "gy", vim.lsp.buf.type_definition, "Go to type definition")
		bufmap("n", "K", vim.lsp.buf.hover, "Hover")
		bufmap({ "n", "v" }, "<leader>ca", vim.lsp.buf.code_action, "Code action")
		bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
		bufmap("n", "<leader>f", function()
			local ft = vim.bo.filetype
			if ft == "python" then
				local filepath = vim.api.nvim_buf_get_name(0)
				local cursor_pos = vim.api.nvim_win_get_cursor(0)
				vim.fn.system({ "black", "--quiet", filepath })
				vim.cmd("checktime")
				vim.api.nvim_win_set_cursor(0, cursor_pos)
			else
				vim.lsp.buf.format({ async = true, timeout_ms = 2000 })
			end
		end, "Format buffer")
	end,
})

-- Format on save
-- vim.api.nvim_create_autocmd("BufWritePre", {
-- 	callback = function(args)
-- 		local filetype = vim.bo[args.buf].filetype
-- 		local filepath = vim.api.nvim_buf_get_name(args.buf)
--
-- 		if filetype == "python" then
-- 			-- Save cursor position
-- 			local view = vim.fn.winsaveview()
--
-- 			-- Run black and capture output
-- 			local output = vim.fn.system({ "black", "--quiet", filepath })
-- 			local exit_code = vim.v.shell_error
--
-- 			if exit_code == 0 then
-- 				-- Reload buffer from disk without creating undo history
-- 				vim.cmd("silent! edit!")
-- 				-- Restore cursor position
-- 				vim.fn.winrestview(view)
-- 			else
-- 				vim.notify("Black formatting failed: " .. output, vim.log.levels.ERROR)
-- 			end
-- 		elseif filetype == "rust" then
-- 			vim.fn.system({ "rustfmt", filepath })
-- 			if vim.v.shell_error == 0 then
-- 				vim.cmd("silent! edit")
-- 			end
-- 		elseif filetype == "c" or filetype == "cpp" then
-- 			vim.fn.system({ "clang-format", "-i", filepath })
-- 			if vim.v.shell_error == 0 then
-- 				vim.cmd("silent! edit")
-- 			end
-- 		elseif filetype == "lua" then
-- 			vim.fn.system({ "stylua", filepath })
-- 			if vim.v.shell_error == 0 then
-- 				vim.cmd("silent! edit")
-- 			end
-- 		elseif filetype == "javascript" or filetype == "typescript" or filetype == "html" or filetype == "css" then
-- 			vim.fn.system({ "prettier", "--write", filepath })
-- 			if vim.v.shell_error == 0 then
-- 				vim.cmd("silent! edit")
-- 			end
-- 		end
-- 	end,
-- })
