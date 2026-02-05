-- Finds and lists all of the TODO, HACK, BUG, etc comment
-- in your project and loads them into a browsable list.
return {
  {
    "folke/todo-comments.nvim",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
    keys = {
      { "]t",         function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t",         function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>xt", function() Snacks.picker.todo_comments() end,        desc = "Todo (Picker)" },
      {
        "<leader>xT",
        function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end,
        desc = "Todo/Fix/Fixme (Picker)"
      },
      { "<leader>st", function() Snacks.picker.todo_comments() end, desc = "Todo (Picker)" },
      {
        "<leader>sT",
        function() Snacks.picker.todo_comments({ keywords = { "TODO", "FIX", "FIXME" } }) end,
        desc = "Todo/Fix/Fixme (Picker)"
      },
    },
  },
}
