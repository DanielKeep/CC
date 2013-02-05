
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

function table.find(t, v)
    for i,e in ipairs(t) do
        if e == v then return i end
    end
    return false
end

function main(args)
    local config = loadConfig()

    -- Fetch remote list of packages.
    local pkgs = getPackages(config.repository, config.branch)

    if #args == 0 then
        -- If no packages were specified, then we should just update everything.
        local pkgsToInstall = {}
        for name,installed in pairs(config.packages) do
            if installed then
                table.insert(pkgsToInstall, name)
            end
        end
        installPackages(config, pkgs, pkgsToInstall)
    elseif table.find(args, '--list') then
        -- List available packages.
        local pkgList = {}
        for pkg,files in pairs(pkgs.packages) do
            local display = pkg
            if config.packages[pkg] then
                -- It's installed
                display = display .. '*'
            end
            table.insert(pkgList, display)
        end
        table.sort(pkgList)
        print(table.concat(pkgList, ', '))
    else
        -- Otherwise, update only the specified packages.
        local pkgsToInstall = {}
        for _,name in ipairs(args) do
            table.insert(pkgsToInstall, name)
        end
        installPackages(config, pkgs, pkgsToInstall)
    end

    saveConfig(config)
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
    local pkgs = {}
    pkgs.packages = textutils.unserialize(githubGet(repo, branch, 'packages.lua'))
    pkgs.repository = repo
    pkgs.branch = branch
    return pkgs
end

function checkDependencies(pkgs, pkgsToCheck)
    local fullList = {}
    local function checkPkg(name)
        if pkgs.packages[name] == nil then
            error("unknown package '"..name.."'")
        end
        if not table.find(fullList, name) then
            table.insert(fullList, name)
        end
        local pkg = pkgs.packages[name]
        if pkg.depends then
            for _,depName in ipairs(pkg.depends) do
                checkPkg(depName)
            end
        end
    end
    for _,name in ipairs(pkgsToCheck) do
        checkPkg(name)
    end
    return fullList
end

function installPackages(config, pkgs, pkgsToInstall)
    local pkgsToInstall = checkDependencies(pkgs, pkgsToInstall)
    for _,name in ipairs(pkgsToInstall) do
        installPackage(config, pkgs, name)
    end
end

function installPackage(config, pkgs, name)
    if pkgs.packages[name] == nil then
        error("unknown package '"..name.."'")
    end
    print(name)
    local pkg = pkgs.packages[name]
    for _,path in ipairs(pkg.files) do
        local localName = path
        local repoPath = path

        -- Handle files with elided extensions.
        if string.sub(path, -1) == '*' then
            localName = string.match(path, '^(.*)[.][^.]+[*]$')
            repoPath = string.match(path, '^(.*)[*]$')
        end

        local localPath = relpath(localName)
        print(string.format(' - %s', localPath))

        local body = githubGet(pkgs.repository, pkgs.branch, repoPath)
        
        if fs.exists(localPath) then fs.delete(localPath) end
        local f = io.open(localPath, 'w')
        f:write(body)
        f:close()
    end

    config.packages[name] = true
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
            local body = res.readAll()
            return body
        elseif ev == 'http_failure' and resUrl == url then
            error("failed to fetch '"..path.."'")
        end
    end
end

function githubUrl(repo, path, branch)
    local branch = branch or 'master'
    return 'https://raw.github.com/' .. repo .. '/' .. branch .. '/' .. path
end

main(__args__)
