local copilot = require 'copilot'
local aider = require 'aider'

local function init()
    -- Copilot setup
    copilot.setup {
        suggestion = {
            auto_trigger = true,
            keymap = {
                accept = "<C-y>",
            }
        }
    }



    -- Aider setup
    aider.setup {}
    vim.api.nvim_set_keymap('n', '<leader>Ao', ':AiderOpen<CR>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>Am', ':AiderAddModifiedFiles<CR>', { noremap = true, silent = true })
end


return {
    init = init
}
