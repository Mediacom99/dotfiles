-- Agent Processes: every process a Claude Code Bash call started on this Mac,
-- traced back to its Rex session and pane, with go-to-pane and kill.

local TERMINAL = "com.superlogical.terminal"

local function seconds(etime) -- ps etime is [[dd-]hh:]mm:ss
    local days, rest = etime:match("^(%d+)-(.+)$")
    local s = 0
    for n in (rest or etime):gmatch("%d+") do s = s * 60 + tonumber(n) end
    return s + (tonumber(days) or 0) * 86400
end

local function age(s)
    if s >= 86400 then return math.floor(s / 86400) .. "d" end
    if s >= 3600 then return math.floor(s / 3600) .. "h" end
    if s >= 60 then return math.floor(s / 60) .. "m" end
    return s .. "s"
end

local function is_claude(p)
    return p ~= nil and (p.cmd:match("^%S+") or ""):match("[^/]+$") == "claude"
end

-- One string per process. A record starts with the pid right-aligned like
-- the first line's; any other line continues the record before it.
local function ps(columns, env)
    local argv = { "ps", "-A", "-ww", "-o", columns }
    if env then table.insert(argv, 2, "-E") end
    local r = rex.exec(argv)
    local out, recs = r and r.stdout or "", {}
    local width = #(out:match("^ *%d+") or "")
    for line in out:gmatch("([^\n]*)\n") do
        local pid = line:match("^ *%d+")
        if pid and #pid == width then
            recs[#recs + 1] = line
        elseif #recs > 0 then
            recs[#recs] = recs[#recs] .. "\n" .. line
        end
    end
    return recs
end

local function collect()
    local procs, kids = {}, {}
    for _, rec in ipairs(ps("pid=,ppid=,pgid=,etime=,rss=,command=")) do
        local pid, ppid, pgid, et, rss, cmd = rec:match("^ *(%d+) +(%d+) +(%d+) +(%S+) +(%d+) (.*)$")
        if pid then
            procs[pid] = { pid = pid, ppid = ppid, pgid = pgid, secs = seconds(et), kb = tonumber(rss), cmd = cmd }
            kids[ppid] = kids[ppid] or {}
            table.insert(kids[ppid], pid)
        end
    end

    -- With -E, ps prints the environment after the command.
    for _, rec in ipairs(ps("pid=,command=", true)) do
        local pid, line = rec:match("^ *(%d+) (.*)$")
        local p = procs[pid]
        if p and line:sub(1, #p.cmd) == p.cmd then p.env = line:sub(#p.cmd + 1) end
    end
    local function var(p, name)
        return p and p.env and p.env:match(" " .. name .. "=(%S+)")
    end

    -- An agent process carries the environment Claude Code gives its Bash calls,
    -- or is the zsh Claude wraps each call in. macOS hides the environment of its
    -- own binaries (zsh, sh, sleep...), so for the wrapper ask its claude parent.
    for _, p in pairs(procs) do
        local parent = procs[p.ppid]
        if var(p, "CLAUDECODE") == "1" then
            p.agent = {
                claude_pid = var(p, "CLAUDE_PID"),
                claude_session = var(p, "CLAUDE_CODE_SESSION_ID"),
                rex_session = var(p, "REX_SESSION"),
                rex_block = var(p, "REX_BLOCK"),
            }
        elseif is_claude(parent) and p.cmd:find("/shell-snapshots/snapshot-", 1, true) then
            p.agent = {
                claude_pid = parent.pid,
                rex_session = var(parent, "REX_SESSION"),
                rex_block = var(parent, "REX_BLOCK"),
            }
        end
    end
    -- Everything a Bash call starts shares its process group, even once orphaned.
    local groups = {}
    for _, p in pairs(procs) do
        if p.agent then groups[p.pgid] = groups[p.pgid] or p.agent end
    end
    for _, p in pairs(procs) do
        if not (p.agent or is_claude(p)) then p.agent = groups[p.pgid] end
    end

    local sessions = {}
    for _, s in ipairs((rex.call("session.list") or {}).sessions or {}) do
        sessions[s.session_id] = s.label
    end
    local titles = {} -- block id -> terminal title, or false when the pane is gone
    local function pane_title(a)
        if not (a.rex_block and sessions[a.rex_session]) then return nil end
        if titles[a.rex_block] == nil then
            local t = rex.block.call(TERMINAL, "title", { session_id = a.rex_session, block_id = a.rex_block })
            titles[a.rex_block] = t and t.title or false
        end
        return titles[a.rex_block] or nil
    end

    local function agent_alive(p)
        if p.agent.claude_pid then return is_claude(procs[p.agent.claude_pid]) end
        local q = procs[p.ppid] -- Claude Code without CLAUDE_PID: look for a claude ancestor
        while q and not is_claude(q) do q = procs[q.ppid] end
        return q ~= nil
    end

    local function subtree(pid, out)
        out[#out + 1] = pid
        for _, k in ipairs(kids[pid] or {}) do subtree(k, out) end
        return out
    end

    -- One row per tree an agent started: an agent process whose parent isn't one.
    local rows = {}
    for _, p in pairs(procs) do
        local parent = procs[p.ppid]
        if p.agent and not (parent and parent.agent) then
            local a, pids, kb = p.agent, subtree(p.pid, {}), 0
            for _, pid in ipairs(pids) do kb = kb + procs[pid].kb end

            -- The wrapper zsh runs: ... && eval '<command>' [< /dev/null] && pwd -P >| ...
            local ran = p.cmd:match("&& eval '(.*)'[^']* && pwd %-P")
            local title = ran and ran:gsub("'\"'\"'", "'"):gsub("'\\''", "'"):gsub("\\012", " ")
                or p.cmd:gsub("^%S*/", "") -- /opt/homebrew/.../Python -c ... -> Python -c ...

            local alive, pane = agent_alive(p), pane_title(a)
            local where = sessions[a.rex_session] or "session gone"
            if sessions[a.rex_session] then where = where .. " › " .. (pane or "pane closed") end
            if a.claude_session then where = where .. " · claude " .. a.claude_session:sub(1, 8) end

            rows[#rows + 1] = {
                pid = p.pid,
                pids = pids,
                secs = p.secs,
                alive = alive,
                pane = pane,
                rex_session = a.rex_session,
                rex_block = a.rex_block,
                title = title:gsub("%s+", " "):sub(1, 160),
                where = where,
                detail = (alive and "running" or "LEFTOVER") .. " · " .. age(p.secs)
                    .. " · " .. math.floor(kb / 1024) .. " MB"
                    .. (#pids > 1 and " · " .. #pids .. " procs" or ""),
            }
        end
    end
    table.sort(rows, function(x, y) -- leftovers first, then oldest first
        if x.alive ~= y.alive then return not x.alive end
        return x.secs > y.secs
    end)
    return rows
end

rex.action {
    name = "agent_processes",
    title = "Agent Processes…",
    category = "Agents",
    keywords = "claude kill process leftover orphan",
    run = function(ctx)
        local rows, byid, items = collect(), {}, {}
        for _, r in ipairs(rows) do
            byid[r.pid] = r
            items[#items + 1] = {
                id = r.pid,
                title = r.title,
                subtitle = r.where,
                detail = r.detail,
                icon = r.alive and "terminal" or "clock",
            }
        end

        local picked = rex.ui.pick {
            title = #rows .. " agent processes", placeholder = "Filter",
            multiple = true, confirm = "Next", items = items,
        }
        if not picked or #picked == 0 then return end

        local first = byid[picked[1]]
        local choices = {
            { id = "TERM", title = "Terminate",  subtitle = "SIGTERM to each process and its children" },
            { id = "KILL", title = "Force kill", subtitle = "SIGKILL to each process and its children" },
        }
        if #picked == 1 and first.pane then
            table.insert(choices, 1, { id = "go", title = "Go to agent pane", subtitle = first.where, icon = "terminal" })
        end

        local what = rex.ui.pick { title = #picked .. " selected", items = choices }
        if what == "go" then
            rex.session.focus_block { session_id = first.rex_session, block_id = first.rex_block }
            rex.client.queue("session.select", { session_id = first.rex_session })
        elseif what then
            local argv = { "kill", "-" .. what }
            for _, id in ipairs(picked) do
                for _, pid in ipairs(byid[id].pids) do argv[#argv + 1] = pid end
            end
            rex.exec(argv)
        end
    end,
}

rex.bind("alt+cmd+p", "agent_processes")
