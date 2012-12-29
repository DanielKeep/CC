
--[[
    Web Get for ComputerCraft.
    Written by Daniel Keep.

    Copyright 2012.
    Released under the MIT license.
  ]]

local args = {...}

if http == nil then
    error "HTTP support not enabled."
end

if #args ~= 2 then
    print "Usage: wget URL FILE"
    error "no arguments"
end

local url = args[1]
local file = args[2]

print('GET ' .. url)
http.request(url)

print('Awaiting response. Press any key to abort.')
local waiting = true
while waiting do
    local event, response_url, response = os.pullEvent()

    if event == 'http_success' and response_url == url then
        print('OK.  Saving result...')
        local text = response.readAll()
        local f = io.open(file, 'w')
        f:write(text)
        f:close()
        waiting = false
    elseif event == 'http_failure' and response_url == url then
        print('Request failed.')
        waiting = false
    elseif event == 'key' then
        print('Aborted.')
        waiting = false
    end
end
