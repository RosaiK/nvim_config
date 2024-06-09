-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
local has_words_before = function()
  local unpack = unpack or table.unpack
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

-- 设置语法折叠-----------------------------------
require("nvim-treesitter.configs").setup({
  fold = {
    enable = true,
  },
})
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"

---函数标题固定---------------------------------------
require("treesitter-context").setup({
  enable = true, -- Enable this plugin (Can be enabled/disabled later via commands)
  max_lines = 1, -- How many lines the window should span. Values <= 0 mean no limit.
  min_window_height = 0, -- Minimum editor window height to enable context. Values <= 0 mean no limit.
  line_numbers = true,
  multiline_threshold = 20, -- Maximum number of lines to show for a single context
  trim_scope = "outer", -- Which context lines to discard if `max_lines` is exceeded. Choices: 'inner', 'outer'
  mode = "cursor", -- Line used to calculate context. Choices: 'cursor', 'topline'
  -- Separator between context and content. Should be a single character string, like '-'.
  -- When separator is set, the context will only show up when there are at least 2 lines above cursorline.
  separator = nil,
  zindex = 20, -- The Z-index of the context window
  on_attach = nil, -- (fun(buf: integer): boolean) return false to disable attaching
})
---自动缩进---------------------------------------
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.softtabstop = 4
vim.o.expandtab = true

---快捷键---------------------------------------
vim.keymap.set("n", "<leader>t", "<cmd>AerialToggle<CR>")
vim.keymap.set("n", "<leader>tn", "<cmd>AerialNext<CR>")
vim.keymap.set("n", "<leader>tp", "<cmd>AerialPrev<CR>")

---TAB选择下拉框----------------------------------
-- 导入 LuaSnip
local luasnip = require("luasnip")
-- 配置 LuaSnip
luasnip.config.set_config({
  history = true,
  updateevents = "TextChanged,TextChangedI",
})
-- 自动从 Friendly Snippets 加载片段
require("luasnip.loaders.from_vscode").lazy_load()
-- 为 LuaSnip 提供额外的文件类型支持
luasnip.filetype_extend("javascript", { "javascriptreact" })
luasnip.filetype_extend("typescript", { "typescriptreact" })

local cmp = require("cmp")
vim.g.c_no_fold = 0
vim.opt.foldlevelstart = 0
cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
        -- You could replace the expand_or_jumpable() calls with expand_or_locally_jumpable()
        -- that way you will only jump inside the snippet region
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
})
-- 将 Astro 文件类型关联到 HTML
vim.filetype.add({
  extension = {
    astro = "html",
  },
})

local TagConfigs = require("nvim-ts-autotag.config.init")
TagConfigs:add_alias("astro", "html", "tsx")
