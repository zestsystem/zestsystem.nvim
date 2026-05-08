-- Builtin
local function init()
    local gitsigns = require 'gitsigns'

    gitsigns.setup {
        on_attach = function(bufnr)
            local opts = { buffer = bufnr, remap = false }

            vim.keymap.set("n", "]c", function()
                if vim.wo.diff then
                    return "]c"
                end
                vim.schedule(gitsigns.next_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, expr = true, remap = false })

            vim.keymap.set("n", "[c", function()
                if vim.wo.diff then
                    return "[c"
                end
                vim.schedule(gitsigns.prev_hunk)
                return "<Ignore>"
            end, { buffer = bufnr, expr = true, remap = false })

            vim.keymap.set("n", "<leader>hp", gitsigns.preview_hunk, opts)
            vim.keymap.set("n", "<leader>hb", gitsigns.blame_line, opts)
            vim.keymap.set("n", "<leader>hd", gitsigns.diffthis, opts)
        end,
    }

    vim.keymap.set('n', '<leader>gs', '<CMD>Git<CR>')
    vim.keymap.set('n', '<leader>gl', '<CMD>DiffviewOpen HEAD~1..HEAD<CR>')
    vim.keymap.set('n', '<leader>gm', '<CMD>DiffviewOpen origin/main...HEAD<CR>')
    vim.keymap.set('n', '<leader>gq', '<CMD>DiffviewClose<CR>')

    vim.api.nvim_create_autocmd("BufWinEnter", {
        pattern = "*",
        callback = function()
            if vim.bo.ft ~= "fugitive" then
                return
            end

            local bufnr = vim.api.nvim_get_current_buf()
            local opts = { buffer = bufnr, remap = false }
            vim.keymap.set("n", "<leader>p", function()
                vim.cmd.Git("push")
            end, opts)

            -- rebase always
            vim.keymap.set("n", "<leader>P", function()
                vim.cmd.Git("pull --rebase")
            end, opts)

            -- NOTE: It allows me to easily set the branch i am pushing and any tracking
            -- needed if i did not set the branch up correctly
            vim.keymap.set("n", "<leader>t", ":Git push -u origin ", opts)
        end,
    })

    vim.keymap.set('n', '<leader>uu', vim.cmd.UndotreeToggle)
end


return {
    init = init
}
