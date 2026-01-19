--[[
    MODULE:     Hybrid Attribute & GamePass Handler (Server)
    AUTHOR:     Mustafa (The_Formid) (Solo Dev)
    DATE:       January 2026
    DESC:       Optimizes network usage by caching GamePass ownership into Player Attributes.
                Replicates attributes to the Character automatically upon respawn.
                Eliminates repetitive GetAsync calls.
]]

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

-- 🆔 GAMEPASS CONFIGURATION
local GAMEPASS_IDS = {
    DoubleJump = 1673427184,
    Push       = 1673536983,
    VIP        = 1672955593,
    LowGravity = 1673239348,
    Radio      = 1673447152,
    Coins2x    = 1673095337
}

--------------------------------------------------------------------------------
-- ⚡ FEATURE ACTIVATION LOGIC
--------------------------------------------------------------------------------
local function activateFeature(player, passId)
    -- STAMP THE PLAYER MEMORY (RAM)
    -- Using attributes allows client-side scripts to check permissions easily.
    
    if passId == GAMEPASS_IDS.DoubleJump then
        player:SetAttribute("HasDoubleJump", true)
        
        -- If character is already alive, apply immediately
        if player.Character then
            player.Character:SetAttribute("CanDoubleJump", true)
        end
        print("✅ Attribute Set: DoubleJump for " .. player.Name)

    elseif passId == GAMEPASS_IDS.Push then
        player:SetAttribute("HasPush", true)
        print("✅ Attribute Set: Push for " .. player.Name)

    -- Add other pass logics here...
    end
end

--------------------------------------------------------------------------------
-- 🔄 EVENT HANDLERS
--------------------------------------------------------------------------------

-- 1. INITIAL JOIN HANDLER (Checks API Once)
Players.PlayerAdded:Connect(function(player)

    -- A) CHECK OWNERSHIP (Async/Parallel)
    for name, id in pairs(GAMEPASS_IDS) do
        task.spawn(function()
            local success, hasPass = pcall(function()
                return MarketplaceService:UserOwnsGamePassAsync(player.UserId, id)
            end)

            if success and hasPass then
                activateFeature(player, id)
            end
        end)
    end

    -- B) CHARACTER SPAWN HANDLER (Zero API Calls)
    player.CharacterAdded:Connect(function(character)
        -- Optimization: Check Cached Attributes on Player Object
        -- Do NOT call MarketplaceService here.
        
        if player:GetAttribute("HasDoubleJump") then
            character:SetAttribute("CanDoubleJump", true)
        end

        if player:GetAttribute("HasPush") then
            -- Additional character logic for push if needed
        end
    end)
end)

-- 2. REAL-TIME PURCHASE HANDLER
MarketplaceService.PromptGamePassPurchaseFinished:Connect(function(player, passId, wasPurchased)
    if wasPurchased then
        print("💰 New Purchase Detected: " .. player.Name)
        activateFeature(player, passId) -- Apply instantly without rejoin
    end
end)
