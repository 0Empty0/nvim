return {
	"ThePrimeagen/harpoon",
	branch = "harpoon2",
	lazy = false,
	dependencies = { "nvim-lua/plenary.nvim" },
	config = function()
		local harpoon = require("harpoon")

		harpoon:setup()

		local map = vim.keymap.set

		local normalize_list = function(t)
			local normalized = {}
			for _, v in pairs(t) do
				if v ~= nil then
					table.insert(normalized, v)
				end
			end
			return normalized
		end

		map("n", "<leader>ha", function()
			harpoon:list():add()
		end, { desc = "Add File to Harpoon" })

		map("n", "<leader>hh", function()
			local normalize_list = function(t)
				local normalized = {}
				for _, v in pairs(t) do
					if v ~= nil then
						table.insert(normalized, v)
					end
				end
				return normalized
			end

			Snacks.picker({
				source = "harpoon",
				layout = { border = "rounded" },
				finder = function()
					local file_paths = {}
					local list = normalize_list(harpoon:list().items)
					for i, item in ipairs(list) do
						table.insert(file_paths, {
							text = item.value,
							file = item.value,
						})
					end
					return file_paths
				end,
				win = {
					input = {
						keys = {
							["<C-x>"] = { "harpoon_delete", mode = { "n", "i" } },
							["<C-d>"] = { "harpoon_mark_down", mode = { "n", "i" } },
							["<C-u>"] = { "harpoon_mark_up", mode = { "n", "i" } },
						},
					},
					list = {
						keys = {
							["<C-x>"] = { "harpoon_delete", mode = { "n", "i" } },
							["<C-d>"] = { "harpoon_mark_down", mode = { "n", "i" } },
							["<C-u>"] = { "harpoon_mark_up", mode = { "n", "i" } },
						},
					},
				},
				actions = {
					harpoon_mark_down = function(picker, item)
						local to_move = item or picker:selected()
						local items = harpoon:list().items
						for i, v in ipairs(items) do
							if v and v.value == to_move.text and items[i + 1] then
								items[i], items[i + 1] = items[i + 1], items[i]
								break
							end
						end
						harpoon:list().items = normalize_list(items)
						picker:find({ refresh = true })
					end,
					harpoon_mark_up = function(picker, item)
						local to_move = item or picker:selected()
						local items = harpoon:list().items
						for i, v in ipairs(items) do
							if v and v.value == to_move.text and i > 1 then
								items[i], items[i - 1] = items[i - 1], items[i]
								break
							end
						end
						harpoon:list().items = normalize_list(items)
						picker:find({ refresh = true })
					end,
					harpoon_delete = function(picker, item)
						local to_remove = item or picker:selected()
						harpoon:list():remove({ value = to_remove.text })
						harpoon:list().items = normalize_list(harpoon:list().items)
						picker:find({ refresh = true })
					end,
				},
			})
		end, { desc = "Harpoon Quick Menu" })

		map("n", "<leader>hn", function()
			harpoon:list():next()
		end, { desc = "Next Harpoon Mark" })

		map("n", "<leader>hp", function()
			harpoon:list():prev()
		end, { desc = "Previous Harpoon Mark" })

		map("n", "<leader>1", function()
			harpoon:list():select(1)
		end, { desc = "Harpoon Mark 1" })

		map("n", "<leader>2", function()
			harpoon:list():select(2)
		end, { desc = "Harpoon Mark 2" })

		map("n", "<leader>3", function()
			harpoon:list():select(3)
		end, { desc = "Harpoon Mark 3" })

		map("n", "<leader>4", function()
			harpoon:list():select(4)
		end, { desc = "Harpoon Mark 4" })
	end,
}
