require("empty")

-- Lua Snippet Tester plugin
local function setup_lua_snippet_tester()
	local M = {}

	-- Configuration
	local config = {
		split_direction = "vertical",
		split_size = 0.4,
		preserve_context = true,
		capture_print = true,
		capture_return = true,
		auto_execute = false,
		key_mappings = {
			toggle = "<leader>lx",
			execute = "<leader>le",
			clear = "<leader>lc",
		},
	}

	-- State
	local state = {
		is_open = false,
		left_buf = nil,
		right_buf = nil,
		left_win = nil,
		right_win = nil,
		layout = nil,
		context = {},
	}

	-- Create or get existing buffers
	local function get_buffers()
		if not state.left_buf then
			state.left_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(state.left_buf, "lua_snippet_test")
			vim.api.nvim_buf_set_option(state.left_buf, "filetype", "lua")
			vim.api.nvim_buf_set_option(state.left_buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(state.left_buf, "bufhidden", "hide")
			vim.api.nvim_buf_set_option(state.left_buf, "swapfile", false)

			-- Load saved content if exists
			local saved_content = vim.fn.getbufvar(state.left_buf, "saved_content")
			if saved_content and saved_content ~= "" then
				local lines = vim.fn.json_decode(saved_content)
				vim.api.nvim_buf_set_lines(state.left_buf, 0, -1, false, lines)
			end
		end

		if not state.right_buf then
			state.right_buf = vim.api.nvim_create_buf(false, true)
			vim.api.nvim_buf_set_name(state.right_buf, "lua_snippet_output")
			vim.api.nvim_buf_set_option(state.right_buf, "filetype", "output")
			vim.api.nvim_buf_set_option(state.right_buf, "buftype", "nofile")
			vim.api.nvim_buf_set_option(state.right_buf, "bufhidden", "wipe")
			vim.api.nvim_buf_set_option(state.right_buf, "swapfile", false)
			vim.api.nvim_buf_set_option(state.right_buf, "modifiable", false)
		end

		return state.left_buf, state.right_buf
	end

	-- Create the split layout
	local function create_layout()
		local left_buf, right_buf = get_buffers()

		-- Get editor dimensions
		local width = vim.api.nvim_get_option("columns")
		local height = vim.api.nvim_get_option("lines")

		-- Create left window (60% width)
		state.left_win = vim.api.nvim_open_win(left_buf, true, {
			relative = "editor",
			width = math.floor(width * 0.6),
			height = height - 2,
			col = 0,
			row = 1,
			border = "rounded",
			style = "minimal",
			zindex = 50,
		})

		-- Configure left window options
		vim.api.nvim_win_set_option(state.left_win, "wrap", false)
		vim.api.nvim_win_set_option(state.left_win, "number", true)
		vim.api.nvim_win_set_option(state.left_win, "relativenumber", true)

		-- Create right window (40% width)
		state.right_win = vim.api.nvim_open_win(right_buf, false, {
			relative = "editor",
			width = width - math.floor(width * 0.6) - 1,
			height = height - 2,
			col = math.floor(width * 0.6),
			row = 1,
			border = "rounded",
			style = "minimal",
			zindex = 50,
		})

		-- Configure right window options
		vim.api.nvim_win_set_option(state.right_win, "wrap", false)
		vim.api.nvim_win_set_option(state.right_win, "number", false)
		vim.api.nvim_win_set_option(state.right_win, "relativenumber", false)
		vim.api.nvim_win_set_option(state.right_win, "signcolumn", "no")
		vim.api.nvim_win_set_option(state.right_win, "modifiable", false)
		vim.api.nvim_win_set_option(state.right_win, "readonly", true)
	end

	-- Save buffer content when closing
	local function save_buffer_content()
		if state.left_buf then
			local lines = vim.api.nvim_buf_get_lines(state.left_buf, 0, -1, false)
			local saved_content = vim.fn.json_encode(lines)
			vim.fn.setbufvar(state.left_buf, "saved_content", saved_content)
		end
	end

	-- Execute Lua code
	local function execute_code()
		if not state.left_buf then
			return
		end

		-- Clear output buffer
		vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, { "" })

		-- Get code from buffer
		local code_lines = vim.api.nvim_buf_get_lines(state.left_buf, 0, -1, false)
		local code = table.concat(code_lines, "\n")

		-- Execute code
		local function execute()
			local results = { stdout = "", stderr = "", return_value = nil }

			-- Capture stdout
			local stdout_handler = function(_, data)
				results.stdout = results.stdout .. table.concat(data, "\n") .. "\n"
			end

			-- Capture stderr
			local stderr_handler = function(_, data)
				results.stderr = results.stderr .. table.concat(data, "\n") .. "\n"
			end

			-- Execute the code
			local cmd = {
				"nvim",
				"--headless",
				"-c",
				"lua " .. code,
				"-c",
				"qa",
			}

			local job_id = vim.fn.jobstart(cmd, {
				on_stdout = stdout_handler,
				on_stderr = stderr_handler,
				stdout_buffered = true,
				stderr_buffered = true,
				on_exit = function(_, exit_code)
					-- Format output
					local output_lines = {}

					if results.stderr ~= "" then
						table.insert(output_lines, "ERROR:")
						table.insert(output_lines, results.stderr)
					end

					if results.stdout ~= "" then
						table.insert(output_lines, "OUTPUT:")
						table.insert(output_lines, results.stdout)
					end

					-- Show return value if any
					if exit_code == 0 and results.stdout == "" and results.stderr == "" then
						table.insert(output_lines, "Executed successfully")
					end

					-- Update output buffer
					vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, output_lines)

					-- Scroll to bottom
					if state.right_win and vim.api.nvim_win_is_valid(state.right_win) then
						vim.api.nvim_set_current_win(state.right_win)
						vim.cmd("normal! G")
						vim.cmd("redraw")
					end
				end,
			})
		end

		-- Execute in protected mode
		local ok, err = pcall(execute)
		if not ok then
			vim.notify("Error executing Lua code: " .. err, vim.log.levels.ERROR)
		end
	end

	-- Toggle the interface
	function M.toggle()
		if state.is_open then
			-- Close the interface
			if state.left_win and vim.api.nvim_win_is_valid(state.left_win) then
				vim.api.nvim_win_close(state.left_win, true)
			end
			if state.right_win and vim.api.nvim_win_is_valid(state.right_win) then
				vim.api.nvim_win_close(state.right_win, true)
			end

			-- Save buffer content
			save_buffer_content()

			state.is_open = false
			state.left_buf = nil
			state.right_buf = nil
			state.left_win = nil
			state.right_win = nil

			-- Show notification
			if require("snacks").notifier then
				require("snacks").notifier.show("Lua Snippet Tester closed", vim.log.levels.INFO)
			else
				vim.notify("Lua Snippet Tester closed", vim.log.levels.INFO)
			end
		else
			-- Open the interface
			create_layout()
			state.is_open = true

			-- Show notification
			if require("snacks").notifier then
				require("snacks").notifier.show("Lua Snippet Tester opened", vim.log.levels.INFO)
			else
				vim.notify("Lua Snippet Tester opened", vim.log.levels.INFO)
			end
		end
	end

	-- Execute current buffer
	function M.execute()
		if state.is_open then
			execute_code()
		else
			-- Open and execute
			M.toggle()
			vim.defer_fn(execute_code, 100)
		end
	end

	-- Clear output buffer
	function M.clear()
		if state.right_buf then
			vim.api.nvim_buf_set_lines(state.right_buf, 0, -1, false, { "" })
		end
	end

	-- Reset context
	function M.reset()
		state.context = {}
		if require("snacks").notifier then
			require("snacks").notifier.show("Lua execution context reset", vim.log.levels.INFO)
		else
			vim.notify("Lua execution context reset", vim.log.levels.INFO)
		end
	end

	-- Setup key mappings
	local function setup_mappings()
		local keymap = config.key_mappings

		-- Toggle
		vim.keymap.set("n", keymap.toggle, M.toggle, { desc = "Toggle Lua Snippet Tester" })

		-- Execute
		vim.keymap.set("n", keymap.execute, M.execute, { desc = "Execute Lua Snippet" })

		-- Clear
		vim.keymap.set("n", keymap.clear, M.clear, { desc = "Clear Output Buffer" })
	end

	-- Setup
	setup_mappings()

	return M
end

-- Initialize the plugin
local lua_snippet_tester = setup_lua_snippet_tester()

-- Add to snacks picker
local function setup_snacks_picker()
	if require("snacks") and require("snacks").picker then
		require("snacks").picker.actions.lua_snippet_tester_toggle = function(picker)
			lua_snippet_tester.toggle()
			picker:close()
		end
	end
end

-- Setup snacks picker if available
if pcall(require, "snacks") then
	-- setup_snacks_picker()
end

-- Export the plugin for testing
-- return {
-- 	toggle = lua_snippet_tester.toggle,
-- 	execute = lua_snippet_tester.execute,
-- 	clear = lua_snippet_tester.clear,
-- 	reset = lua_snippet_tester.reset,
-- }
