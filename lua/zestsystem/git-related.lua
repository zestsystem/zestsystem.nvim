local diffview_review = {
    index = nil,
}

local function git_lines(args)
    local lines = vim.fn.systemlist(vim.list_extend({ "git" }, args))
    if vim.v.shell_error ~= 0 then
        return nil
    end
    return lines
end

local function branch_upstream()
    local upstream = git_lines({ "rev-parse", "--abbrev-ref", "--symbolic-full-name", "@{upstream}" })
    if upstream and upstream[1] and upstream[1] ~= "" then
        return upstream[1]
    end
    return "origin/main"
end

local function branch_commits()
    local base = branch_upstream()
    local lines = git_lines({ "log", "--reverse", "--format=%H%x09%h%x09%s", base .. "..HEAD" })
    if not lines then
        return nil, base
    end

    local commits = {}
    for _, line in ipairs(lines) do
        local hash, short_hash, subject = line:match("([^\t]+)\t([^\t]+)\t(.*)")
        if hash then
            table.insert(commits, {
                hash = hash,
                label = ("%s %s"):format(short_hash, subject),
            })
        end
    end

    return commits, base
end

local function open_branch_commit(index, commits, base)
    if not commits then
        commits, base = branch_commits()
    end

    if not commits or #commits == 0 then
        vim.notify(("No commits to review in %s..HEAD"):format(base or "upstream"), vim.log.levels.WARN)
        diffview_review.index = nil
        return
    end

    diffview_review.index = math.max(1, math.min(index, #commits))

    local commit = commits[diffview_review.index]
    vim.cmd(("DiffviewOpen %s^..%s"):format(commit.hash, commit.hash))
    vim.notify(("Diffview commit %d/%d: %s"):format(diffview_review.index, #commits, commit.label))
end

local function open_newest_branch_commit()
    local commits, base = branch_commits()
    open_branch_commit(commits and #commits or 1, commits, base)
end

local function step_branch_commit(delta)
    if diffview_review.index then
        open_branch_commit(diffview_review.index + delta)
    elseif delta > 0 then
        open_branch_commit(1)
    else
        open_newest_branch_commit()
    end
end

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
    vim.keymap.set('n', '<leader>go', function()
        open_branch_commit(1)
    end)
    vim.keymap.set('n', '<leader>gl', open_newest_branch_commit)
    vim.keymap.set('n', '<leader>g]', function()
        step_branch_commit(1)
    end)
    vim.keymap.set('n', '<leader>g[', function()
        step_branch_commit(-1)
    end)
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
