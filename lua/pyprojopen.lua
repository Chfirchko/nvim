local M = {}

-- Функция для открытия проекта с помощью Telescope
function M.open_pyproj()
  -- Проверяем, установлен ли Telescope
  local has_telescope, telescope = pcall(require, "telescope.builtin")
  if not has_telescope then
    vim.notify("Telescope не установлен!", vim.log.levels.ERROR)
    return
  end

  -- Путь к папке с проектами
  local projects_path = vim.fn.expand("~/nvimProjects")

  -- Используем Telescope find_files для выбора папки
  telescope.find_files({
    prompt_title = "Открыть проект",
    cwd = projects_path, -- Указываем папку с проектами
    attach_mappings = function(_, map)
      -- Настраиваем маппинг для выбора папки
      map("i", "<CR>", function(prompt_bufnr)
        -- Получаем выбранный файл/папку
        local selection = require("telescope.actions.state").get_selected_entry()
        if selection then
          local selected_path = projects_path .. "/" .. selection.value

          -- Проверяем, является ли выбранный элемент папкой
          if vim.fn.isdirectory(selected_path) == 1 then
            -- Закрываем Telescope
            require("telescope.actions").close(prompt_bufnr)

            -- Открываем выбранный проект
            vim.cmd("cd " .. selected_path) -- Переходим в папку проекта
            vim.notify("Проект открыт: " .. selected_path, vim.log.levels.INFO)

            -- Открываем Neotree, если он установлен
            local has_neotree, _ = pcall(require, "neo-tree")
            if has_neotree then
              vim.cmd("Neotree " .. selected_path)
              vim.cmd("only") -- Закрываем все другие окна
            else
              vim.notify("Neotree не установлен.", vim.log.levels.WARN)
            end
          else
            vim.notify("Пожалуйста, выберите папку.", vim.log.levels.WARN)
          end
        end
      end)
      return true
    end,
  })
end

-- Регистрируем команду PyProjOpen
vim.api.nvim_create_user_command("PyProjOpen", function()
  M.open_pyproj()
end, {})

return M
