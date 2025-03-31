return {
  -- {
  --   "vague2k/vague.nvim",
  --   config = function()
  --     require("vague").setup {
  --       transparent = true,
  --       style = {
  --         comments = "none",
  --         strings = "none",
  --         keywords_return = "none",
  --       }
  --     }
  --     vim.cmd.colorscheme "vague"
  --   end,
  --   lazy = false,
  --   priority = 1000,
  -- },

  {
    "blazkowolf/gruber-darker.nvim",
    config = function()
      require("gruber-darker").setup {
        italic = {
          strings   = false,
          comments  = false,
          operators = false,
          folds     = false,
        },
      }

      local yellow = "#f9de3e"
      local green = "#7bc158"
      local brown = "#9b7d46"

      vim.cmd.colorscheme "gruber-darker"
      vim.api.nvim_set_hl(0, "GruberDarkerYellow", { fg = yellow })
      vim.api.nvim_set_hl(0, "GruberDarkerYellowBold", { fg = yellow })
      vim.api.nvim_set_hl(0, "GruberDarkerYellowSign", { fg = yellow })
      vim.api.nvim_set_hl(0, "GruberDarkerGreen", { fg = green })
      vim.api.nvim_set_hl(0, "GruberDarkerGreenBold", { fg = green })
      vim.api.nvim_set_hl(0, "GruberDarkerGreenSign", { fg = green })
      vim.api.nvim_set_hl(0, "String", { fg = green })
      vim.api.nvim_set_hl(0, "GruberDarkerBrown", { fg = brown })
      vim.api.nvim_set_hl(0, "Comment", { fg = brown })
      vim.api.nvim_set_hl(0, "Normal", { bg = nil })
      vim.api.nvim_set_hl(0, "NormalNC", { bg = nil })
      vim.api.nvim_set_hl(0, "VertSplit", { bg = nil })
      vim.api.nvim_set_hl(0, "Float", { bg = nil })
    end,
    lazy = false,
    priority = 1000,
  },

  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = "BufEnter",
    opts = {
      highlight = {
        pattern = [[.*([@]<(KEYWORDS)(\(.*\))?)\s*:]],
        keyword = "bg",
      },
    },
  },

  {
    "stevearc/oil.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    event = "VeryLazy",
    config = function()
      require("oil").setup({
        columns = { "icon", "size", "mtime" },
        keymaps = {
          ["<C-h>"] = false,
          ["<M-h>"] = "actions.select_split",
          ["<BS>"] = "actions.parent",
        },
        view_options = {
          show_hidden = true,
        },
      })
      vim.keymap.set("n", "-", "<CMD>Oil<CR>", { desc = "Open parent directory" })
      vim.keymap.set("n", "<leader>-", require("oil").toggle_float, { desc = "Toggle oil float" })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VimEnter",
    config = function()
      require("which-key").setup()
      require("which-key").add({
        { "<leader>x", group = "execute" },
        { "<leader>e", group = "errors" },
        { "<leader>m", group = "make" },
        { "g", group = "goto" },
      })
    end
  },

  { "tpope/vim-sleuth", event = "VeryLazy" },
  { "tpope/vim-repeat", event = "VeryLazy" },

  {
    "lewis6991/gitsigns.nvim",
    event = "BufEnter",
    opts = {
      signs = {
        add = { text = "+" },
        change = { text = "~" },
        delete = { text = "_" },
        topdelete = { text = "‾" },
        changedelete = { text = "~" },
      },
    },
  },

  {
    "lukas-reineke/indent-blankline.nvim",
    main = "ibl",
    event = "BufEnter",
    opts = {
      exclude = {
        buftypes = { "nofile", "terminal", "quickfix", "prompt" },
        filetypes = { "help", "TelescopePrompt", "TelescopeResult", "man", "lazy", "lspinfo" },
      },
      scope = {
        enabled = true,
        show_start = false,
        show_end = false,
      },
    },
  },

  {
    "mbbill/undotree",
    event = "VeryLazy",
  },

  {
    "yorickpeterse/nvim-window",
    config = true,
    event = "VimEnter",
    keys = {
      { "<leader>j", function() require("nvim-window").pick() end, desc = "[j]ump to window" },
    },
  },

  {
    "rcarriga/nvim-notify",
    event = "VeryLazy",
    config = true,
  },

  {
    "aserowy/tmux.nvim",
    event = "VimEnter",
    opts = {},
  },
}
