local copilot = require 'copilot'

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


    -- Avante setup
    require('avante').setup({
        -- Your config here!
    })
end
-- Avante setup
return {
    init = init
}
