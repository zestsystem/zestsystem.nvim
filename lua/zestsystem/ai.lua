local util = require 'zestsystem.util'

local function init()
    local copilot = util.optional_require 'copilot'
    if not copilot then
        return
    end

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


return {
    init = init
}
