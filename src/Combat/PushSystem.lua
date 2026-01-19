--[[
    MODULE:     Volumetric Push System (Client)
    AUTHOR:     Mustafa(The_Formid) (Solo Dev)
    DATE:       January 2026
    DESC:       Uses workspace:Spherecast instead of Raycast to prevent missing moving targets.
                Handles local animations and audio feedback ("Game Juice").
]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local tool = script.Parent
local player = Players.LocalPlayer
local pushEvent = ReplicatedStorage:WaitForChild("PushEvent")

-- ⚙️ CONFIGURATION
local CONFIG = {
    COOLDOWN = 1.0,
    REACH = 3.5,
    RADIUS = 1.5, -- Radius of the Spherecast cylinder
    ANIM_ID = "rbxassetid://93827026159525",
    SOUND_ID = "rbxassetid://138092224"
}

local debounce = false
local animationTrack = nil

-- SETUP ASSETS
local anim = Instance.new("Animation")
anim.AnimationId = CONFIG.ANIM_ID

local swingSound = Instance.new("Sound")
swingSound.SoundId = CONFIG.SOUND_ID
swingSound.Volume = 0.5
swingSound.Parent = tool -- Attached to tool root since handle is missing

--------------------------------------------------------------------------------
-- ⚔️ COMBAT LOGIC
--------------------------------------------------------------------------------

tool.Equipped:Connect(function()
    local character = player.Character
    if character then
        local humanoid = character:WaitForChild("Humanoid")
        local animator = humanoid:FindFirstChild("Animator") or humanoid:WaitForChild("Animator")
        
        -- Load Animation safely
        pcall(function()
            animationTrack = animator:LoadAnimation(anim)
            animationTrack.Priority = Enum.AnimationPriority.Action4 
        end)
    end
end)

tool.Unequipped:Connect(function()
    if animationTrack then animationTrack:Stop() end
end)

tool.Activated:Connect(function()
    if debounce then return end
    debounce = true

    -- 1. AUDIO & VISUAL FEEDBACK
    swingSound:Play()
    
    task.spawn(function()
        pcall(function()
            if animationTrack then animationTrack:Play() end
        end)
    end)

    -- 2. VOLUMETRIC HIT DETECTION (SPHERECAST)
    local character = player.Character
    if character then
        local rootPart = character:WaitForChild("HumanoidRootPart")

        local origin = rootPart.Position
        local direction = rootPart.CFrame.LookVector * CONFIG.REACH

        -- Filter parameters to ignore self
        local rayParams = RaycastParams.new()
        rayParams.FilterDescendantsInstances = {character}
        rayParams.FilterType = Enum.RaycastFilterType.Exclude

        -- Cast the Sphere
        local hitResult = workspace:Spherecast(origin, CONFIG.RADIUS, direction, rayParams)

        if hitResult then
            local hitPart = hitResult.Instance
            local model = hitPart:FindFirstAncestorOfClass("Model")

            if model then
                local targetHumanoid = model:FindFirstChild("Humanoid")
                local targetRoot = model:FindFirstChild("HumanoidRootPart")

                -- Validate Target
                if targetHumanoid and targetRoot then
                    pushEvent:FireServer(model) -- Request server to apply impulse
                end
            end
        end
    end

    task.wait(CONFIG.COOLDOWN)
    debounce = false
end)
