require("asswecan.set")
require("asswecan.remap")
require("asswecan.packer")

local pyproj = require('pyproj')
local pyprojo = require('pyprojopen')

vim.api.nvim_create_user_command('PyProjCreate', function()
  pyproj.create_pyproj()
end, {})

vim.api.nvim_create_user_command('PyProjOpen', function()
  pyprojo.open_pyproj()
end, {})
