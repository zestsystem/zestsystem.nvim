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
end
-- Avante setup
return {
    init = init
}
