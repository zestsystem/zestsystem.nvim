local function harpoon()
    local ok_mark, mark = pcall(require, "harpoon.mark")
    local ok_ui, ui = pcall(require, "harpoon.ui")
    if not (ok_mark and ok_ui) then
        vim.schedule(function()
            vim.notify("Skipping harpoon setup: plugin is unavailable", vim.log.levels.WARN, { title = "zestsystem.nvim" })
        end)
        return
    end

    vim.keymap.set("n", "<leader><leader>g", mark.add_file)
    vim.keymap.set("n", "<leader><leader>f", ui.toggle_quick_menu)

    vim.keymap.set("n", "<leader>j", function()
        ui.nav_file(1)
    end)
    vim.keymap.set("n", "<leader>k", function()
        ui.nav_file(2)
    end)
    vim.keymap.set("n", "<leader>l", function()
        ui.nav_file(3)
    end)
    vim.keymap.set("n", "<leader>;", function()
        ui.nav_file(4)
    end)
end


local function init()
    harpoon()
end

return {
    init = init
}
