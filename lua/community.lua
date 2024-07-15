-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  -- Colorscheme
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
  -- import/override with your plugins folder
  -- Colorscheme
  { import = "astrocommunity.colorscheme.tokyonight-nvim" },
  { import = "astrocommunity.colorscheme.tokyodark-nvim" },
  {
    "tokyodark.nvim",
    opts = {
      transparent_background = true,
    },
  },
  { import = "astrocommunity.colorscheme.cyberdream-nvim" },
  {
    "cyberdream.nvim",
    opts = {
      transparent = true,
    },
  },
  -- Copilot
  { import = "astrocommunity.completion.copilot-lua-cmp" },
}
