local git_worktree = require('git-worktree')

-- Builtin
local function init()
    vim.keymap.set('n', '<leader>gs', '<CMD>Git<CR>')
    vim.keymap.set('n', '<leader>gd', '<CMD>DiffviewOpen<CR>')
    vim.keymap.set('n', '<leader>gm', '<CMD>DiffviewOpen origin/main...HEAD<CR>')
    vim.keymap.set('n', '<leader>gq', '<CMD>DiffviewClose<CR>')
    vim.keymap.set('n', '<leader>gh', '<CMD>DiffviewFileHistory %<CR>')

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
