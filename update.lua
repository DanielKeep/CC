
--[[
    Software updating tool.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

--[[
    Usage: update [PACKAGE ...]
  ]]

local __args__ = {...}
local VERSION = 0.1

local CONFIG_DEFAULT=
{
    repository = 'DanielKeep/CC',
    branch = 'master',
    packages =
    {
        ['update'] = true
    }
}

function main(args)
    local config = loadConfig()

    -- Fetch remote list of packages.
    local pkgs = getPackages(config.repository, config.branch)

    if #args == 0 then
        -- If no packages were specified, then we should just update everything.
        for _,name in ipairs(pkgs.packages) do
            installPackage(pkgs, name)
        end
    else
        -- Otherwise, update only the specified packages.
        for _,name in ipairs(args) do
            installPackage(pkgs, name)
        end
    end
end

function loadConfig()
    local path = relpath 'update.conf'
    if not fs.exists(path) then
        return CONFIG_DEFAULT
    end
    local f = io.open(path, 'r')
    local s = f:read("*a")
    f:close()
    return textutils.unserialize(s)
end

function saveConfig(t)
    local path = relpath 'update.conf'
    local s = textutils.serialize(t)
    local f = io.open(path, 'w')
    f:write(s)
    f:close()
end

function getPackages(repo, branch)
    local pkgs = githubGet(repo, branch, 'packages.lua')
    pkgs.repository = repo
    pkgs.branch = branch
end

function installPackage(pkgs, name)
    if pkgs[name] == nil then
        error "unknown package `"..name.."'"
    end
    print(name)
    local pkg = pkgs[name]
    for _,path in ipairs(pkg.files) do
        local localName = path
        local repoPath = path

        -- Handle files with elided extensions.
        if string.sub(path, -1) == '*' then
            localName = string.match(path, '^(.*)[.][^.]+[*]$')
            repoPath = string.match(path, '^(.*)[*]$')
        end

        print(string.format(' - %s:%s -> %s',
            pkgs.repository, repoPath, localName))

        local body = githubGet(pkgs.repository, pkgs.branch, repoPath)
        local localPath = relpath(localName)
        if fs.exists(localPath) then fs.delete(localPath) end
        local f = io.open(localPath, 'wb')
        f:write(body)
        f:close()
    end

    pkgs[name] = true
end

function relpath(path)
    return fs.combine(shell.getRunningProgram(), '../' .. path)
end

function githubGet(repo, branch, path)
    local url = githubUrl(repo, path, branch)
    http.request(url)
    while true do
        local ev, resUrl, res = os.pullEvent()

        if ev == 'http_success' and resUrl == url then
            local body = response.readAll()
            return body
        elseif ev == 'http_failure' and resUrl == url then
            return nil
        end
    end
end

function githubUrl(repo, path, branch)
    local branch = branch or 'master'
    return 'https://raw.github.com/' .. repo .. '/' .. branch .. '/' .. path
end

main(__args__)
