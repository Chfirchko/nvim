vim.opt.nu = true
vim.opt.relativenumber = true

vim.cmd([[syntax on]])
vim.cmd([[set cursorline]])
vim.cmd([[set ignorecase]])
vim.cmd([[set wildmenu ]])
vim.cmd([[set showmatch ]])

vim.cmd([[set showmode]])
vim.cmd([[set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx]])
--vim.cmd([[syntax on]])

vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true

vim.opt.smartindent = true

vim.opt.wrap = true 

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true

vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true

vim.opt.scrolloff = 10 
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")

vim.opt.updatetime = 50

--vim.opt.colorcolumn = "80"

