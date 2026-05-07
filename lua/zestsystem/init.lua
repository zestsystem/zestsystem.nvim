local function init()
    local modules = {
        'zestsystem.vim',
        'zestsystem.theme',
        'zestsystem.languages',
        'zestsystem.noice',
        'zestsystem.telescope',
        'zestsystem.git-related',
        'zestsystem.snippets',
        'zestsystem.tools',
        'zestsystem.ai',
    }

    for _, module_name in ipairs(modules) do
        local ok, module = pcall(require, module_name)
        if not ok then
            vim.schedule(function()
                vim.notify(
                    ("Failed loading %s: %s"):format(module_name, module),
                    vim.log.levels.ERROR,
                    { title = "zestsystem.nvim" }
                )
            end)
        elseif type(module.init) == "function" then
            module.init()
        end
    end
end

return {
    init = init,
}
