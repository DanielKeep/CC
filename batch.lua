
--[[
    Batch execution program.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: batch SCRIPT [ARG...]
  ]]

local args = {...}
local VERSION = 0.3

function main(args)
    if #args == 0 then
        print "Usage: batch SCRIPT [ARG...]"
        error "no arguments"
    end

    local script = args[1]
    local script_args = {unpack_tail(args,2)}

    -- Read in script lines
    local script_path = shell.resolve(script)
    local script_f = io.open(script_path, "r")
    local lines = {}
    for line in script_f:lines() do
        lines[#lines+1] = line
    end
    script_f:close()

    -- Start processing
    local function exec_fn(args)
        return shell.run(unpack(args))
    end
    if not process_script(lines, script_args, exec_fn) then
        error "error in batch script"
    end
end

function process_script(lines, args, exec_fn)
    local line_i = 1
    while line_i <= #lines do
        local line = lines[line_i]
        local next_line_i = line_i + 1
        local parts = split_line(line)
        parts = sub_vars(parts, args)

        -- Are we at the start of a do block?
        if parts[#parts] == '[[' then
            local block = {}
            local function append_to_block(part)
                if #block > 0 then
                    table.insert(block, ";;")
                end
                if type(part) == "table" then
                    for _,e in ipairs(part) do
                        table.insert(block, e)
                    end
                else
                    table.insert(block, part)
                end
            end

            local do_depth = 1
            local do_line_i = line_i + 1

            while do_depth > 0 do
                if do_line_i > #lines then
                    error("missing `]]' to match `[[' on line "
                        .. tostring(line_i))
                end
                local do_line = lines[do_line_i]
                local do_parts = split_line(do_line)
                if #do_parts == 1 and do_parts[1] == "]]" then
                    do_depth = do_depth - 1
                    if do_depth > 0 then
                        append_to_block ";;;;"
                    end
                else
                    if do_parts[#do_parts] == "[[" then
                        do_depth = do_depth + 1
                    end
                    do_parts = sub_vars(do_parts, args)
                    append_to_block(do_parts)
                end
                do_line_i = do_line_i + 1
            end

            for _,e in ipairs(block) do
                table.insert(parts, e)
            end

            next_line_i = do_line_i
        end

        if #parts > 0 then
            if not exec_fn(parts) then
                return false
            end
        end

        line_i = next_line_i
    end

    return true
end

function split_line(s)
    if string.match(s, "^[ \t]*[#]") then
        return {}
    end
    local parts = {}
    local pattern = "([^ \t]+)"
    string.gsub(s, pattern, function(c) parts[#parts+1] = c end)
    return parts
end

function sub_vars(parts, args)
    local function sub_var(c)
        local i = tonumber(c)
        if i ~= nil and i >= 1 then
            return args[i] or ''
        elseif c == '#' then
            return tostring(#args)
        elseif c == '*' then
            return table.concat(args, " ")
        end
        return false
    end

    local parts = parts
    for i,part in ipairs(parts) do
        local part = string.gsub(part, "[$](.)", sub_var)
        parts[i] = part
    end

    return parts
end

function unpack_tail(table, i)
    if i < #table then
        return table[i], unpack_tail(table, i+1)
    else
        return table[i]
    end
end

function unpack(table)
    return unpack_tail(table, 1)
end

main(args)
