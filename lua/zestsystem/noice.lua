local util = require 'zestsystem.util'

local function init()
    local noice = util.optional_require 'noice'
    local notify = util.optional_require 'notify'

    if noice then
        noice.setup({
            cmdline = {
                format = {
                    cmdline = { icon = ">" },
                    filter = { icon = "$" },
                    help = { icon = "?" },
                    lua = { icon = "☾" },
                    search_down = { icon = "🔍⌄" },
                    search_up = { icon = "🔍⌃" },
                },
            },
            lsp = {
                override = {
                    ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    ["vim.lsp.util.stylize_markdown"] = true,
                    ["cmp.entry.get_documentation"] = true,
                },
            },
            popupmenu = {
                kind_icons = false,
            },
            presets = {
                bottom_search = true,
                command_palette = true,
                inc_rename = false,
                long_message_to_split = true,
                lsp_doc_border = false,
            },
        })
    end

    if notify then
        notify.setup({
            background_colour = "#1e222a",
            render = "minimal",
            stages = "static",
            timeout = 5000,
        })

        vim.cmd [[
            highlight NotifyERRORBorder guifg=#ED8796
            highlight NotifyWARNBorder guifg=#EED49F
            highlight NotifyINFOBorder guifg=#A6DA95
            highlight NotifyDEBUGBorder guifg=#B8C0E0
            highlight NotifyTRACEBorder guifg=#C6A0F6
            highlight NotifyERRORIcon guifg=#ED8796
            highlight NotifyWARNIcon guifg=#EED49F
            highlight NotifyINFOIcon guifg=#A6DA95
            highlight NotifyDEBUGIcon guifg=#B8C0E0
            highlight NotifyTRACEIcon guifg=#C6A0F6
            highlight NotifyERRORTitle guifg=#ED8796
            highlight NotifyWARNTitle guifg=#EED49F
            highlight NotifyINFOTitle guifg=#A6DA95
            highlight NotifyDEBUGTitle guifg=#B8C0E0
            highlight NotifyTRACETitle guifg=#C6A0F6
            highlight link NotifyERRORBody Normal
            highlight link NotifyWARNBody Normal
            highlight link NotifyINFOBody Normal
            highlight link NotifyDEBUGBody Normal
            highlight link NotifyTRACEBody Normal
        ]]
    end
end

return {
    init = init,
}
