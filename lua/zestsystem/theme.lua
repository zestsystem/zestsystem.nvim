local util = require 'zestsystem.util'

local function init()
    local rosepine = util.optional_require 'rose-pine'
    local colorizer = util.optional_require 'colorizer'
    local gitsigns = util.optional_require 'gitsigns'
    local lualine = util.optional_require 'lualine'
    local noice = util.optional_require 'noice'

    if rosepine then
        rosepine.setup({
            disable_background = true,
        })
    end

    if colorizer then
        colorizer.setup {}
    end

    if gitsigns then
        gitsigns.setup {}
    end

    if lualine then
        local lualine_x = {}

        if noice then
            lualine_x = {
                {
                    noice.api.status.message.get_hl,
                    cond = noice.api.status.message.has,
                },
                {
                    noice.api.status.command.get,
                    cond = noice.api.status.command.has,
                    color = { fg = "#EED49F" },
                },
                {
                    noice.api.status.mode.get,
                    cond = noice.api.status.mode.has,
                    color = { fg = "#EED49F" },
                },
                {
                    noice.api.status.search.get,
                    cond = noice.api.status.search.has,
                    color = { fg = "#EED49F" },
                },
            }
        end

        lualine.setup {
            options = {
                component_separators = { left = '', right = '' },
                extensions = { "fzf", "quickfix" },
                icons_enabled = false,
                section_separators = { left = '', right = '' },
                theme = "rose-pine"
            },
            sections = {
                lualine_x = lualine_x,
            }
        }
    end

    if rosepine then
        vim.cmd.colorscheme "rose-pine"
    end
end

return {
    init = init,
}
