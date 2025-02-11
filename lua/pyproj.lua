local M = {}

-- Функция для генерации уникального имени проекта
local function generate_project_name(base_path)
    local project_name = "nvimProject"
    local counter = 0
    local full_path = base_path .. "/" .. project_name

    -- Проверяем, существует ли папка с таким именем
    while vim.fn.isdirectory(full_path) == 1 do
        counter = counter + 1
        project_name = "nvimProject" .. counter
        full_path = base_path .. "/" .. project_name
    end

    return project_name
end

-- Функция для создания папки
local function create_project(path, create_venv, create_hello)
    -- Создаем папку
    local handle = io.popen("mkdir -p " .. path)
    handle:close()

    -- Создаем .venv, если включено
    if create_venv then
        local venv_path = path .. "/.venv"
        local venv_handle = io.popen("python3 -m venv " .. venv_path)
        venv_handle:close()
        vim.notify("Виртуальное окружение создано: " .. venv_path, vim.log.levels.INFO)
    end

    -- Создаем hello.py, если включено
    if create_hello then
        local hello_path = path .. "/hello.py"
        local hello_file = io.open(hello_path, "w")
        if hello_file then
            hello_file:write('print("Hello, World!")\n')
            hello_file:close()
            vim.notify("Файл создан: " .. hello_path, vim.log.levels.INFO)
        else
            vim.notify("Не удалось создать файл: " .. hello_path, vim.log.levels.ERROR)
        end
    end

    vim.notify("Проект создан: " .. path, vim.log.levels.INFO)

    -- Активируем .venv, если он был создан
    if create_venv then
        local activate_cmd = "source " .. path .. "/.venv/bin/activate"
        vim.cmd("!echo '" .. activate_cmd .. "' > " .. path .. "/activate.sh")
        vim.notify("Виртуальное окружение активировано.", vim.log.levels.INFO)
    end

    -- Открываем проект в Neovim
    vim.cmd("cd " .. path)
    vim.notify("Проект открыт: " .. path, vim.log.levels.INFO)

    -- Открываем Neotree, если он установлен
    local has_neotree, _ = pcall(require, "neo-tree")
    if has_neotree then
        vim.cmd("Neotree " .. path)
        vim.notify("Neotree открыт в папке: " .. path, vim.log.levels.INFO)
        vim.cmd("only")
    else
        vim.notify("Neotree не установлен.", vim.log.levels.WARN)
    end

    -- Закрываем плавающее окно
    vim.api.nvim_win_close(0, true)
end

-- Функция для создания плавающего окна
local function create_floating_window()
    local width = 50
    local height = 8

    -- Вычисляем позицию для центрирования окна
    local ui = vim.api.nvim_list_uis()[1]
    local row = (ui.height - height) / 2
    local col = (ui.width - width) / 2

    -- Создаем буфер и окно
    local buf = vim.api.nvim_create_buf(false, true)
    local win = vim.api.nvim_open_win(buf, true, {
        relative = "editor",
        width = width,
        height = height,
        row = row,
        col = col,
        style = "minimal",
        border = "rounded",
    })

    -- Устанавливаем текст в буфере
    local base_path = vim.fn.expand("~/nvimProjects") -- Базовая папка для проектов
    local default_project_name = generate_project_name(base_path)
    local default_path = base_path .. "/" .. default_project_name

    vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
        "Путь для создания проекта:",
        default_path,
        "",
        "[x] Создать .venv", -- Чекбокс включен по умолчанию
        "[x] Создать hello.py", -- Чекбокс включен по умолчанию
        "",
        "Нажмите <Enter> для создания или <Esc> для отмены.",
    })

    -- Добавляем чекбоксы
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 3, 0, -1) -- Подсветка для чекбоксов
    vim.api.nvim_buf_add_highlight(buf, -1, "Comment", 4, 0, -1)

    -- Настройка маппингов
    vim.api.nvim_buf_set_keymap(buf, "n", "<CR>", ":lua require('pyproj').confirm_create()<CR>",
        { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Esc>", ":q!<CR>", { noremap = true, silent = true })
    vim.api.nvim_buf_set_keymap(buf, "n", "<Space>", ":lua require('pyproj').toggle_checkbox()<CR>",
        { noremap = true, silent = true })

    -- Возвращаем буфер и окно
    return buf, win
end

-- Функция для переключения чекбоксов
function M.toggle_checkbox()
    local buf = vim.api.nvim_get_current_buf()
    local cursor_pos = vim.api.nvim_win_get_cursor(0)
    local row = cursor_pos[1] - 1 -- Строка (0-based)

    -- Определяем, какой чекбокс переключать
    if row == 3 then -- Строка с .venv
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        if line:find("%[ %]") then
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { "[x] Создать .venv" })
        else
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { "[ ] Создать .venv" })
        end
    elseif row == 4 then -- Строка с hello.py
        local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, false)[1]
        if line:find("%[ %]") then
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { "[x] Создать hello.py" })
        else
            vim.api.nvim_buf_set_lines(buf, row, row + 1, false, { "[ ] Создать hello.py" })
        end
    end
end

-- Функция для подтверждения создания папки
function M.confirm_create()
    local buf = vim.api.nvim_get_current_buf()

    -- Получаем путь
    local path = vim.api.nvim_buf_get_lines(buf, 1, 2, false)[1]

    -- Проверяем, включены ли чекбоксы
    local create_venv = false
    local create_hello = false

    local venv_line = vim.api.nvim_buf_get_lines(buf, 3, 4, false)[1]
    local hello_line = vim.api.nvim_buf_get_lines(buf, 4, 5, false)[1]

    if venv_line:find("%[x%]") then
        create_venv = true
    end
    if hello_line:find("%[x%]") then
        create_hello = true
    end

    -- Создаем проект
    if path and path ~= "" then
        create_project(path, create_venv, create_hello)
    else
        vim.notify("Путь не может быть пустым!", vim.log.levels.ERROR)
    end
end

-- Основная функция для создания проекта
function M.create_pyproj()
    create_floating_window()
end

return M
