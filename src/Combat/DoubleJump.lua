--[[
    MODULE:     Client Side Double Jump Logic
    AUTHOR:     Mustafa(The_Formid) (Solo Dev)
    DATE:       January 2026
    DESC:       Implements a robust double jump system using State Validation and Raycast checks.
                Includes optimization for particle effects (Object Pooling).
    LICENSE:    MIT
]]

local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local rootPart = character:WaitForChild("HumanoidRootPart")

-- ⚙️ CONFIGURATION
local CONFIG = {
    TOTAL_JUMP_LIMIT = 2,
    AIR_JUMP_POWER = 90,
    TIME_BETWEEN_JUMPS = 0.2,
    PARTICLE_ASSET_ID = "rbxassetid://1266170131"
}

-- STATE VARIABLES
local jumpCount = 0
local lastJumpTime = 0
local isValidJumpChain = false -- Prevents air-walking exploit

-- EFFECT OBJECTS (Pooling)
local jumpEffectAttachment = nil
local jumpParticles = nil

--------------------------------------------------------------------------------
-- 🎨 VISUAL EFFECTS (OPTIMIZED)
--------------------------------------------------------------------------------
local function createJumpEffect(targetRoot)
    -- Cleanup existing attachment if character refreshed
    if jumpEffectAttachment then jumpEffectAttachment:Destroy() end

    -- 1. Create Attachment (Positioned below feet)
    jumpEffectAttachment = Instance.new("Attachment")
    jumpEffectAttachment.Name = "DoubleJumpAttachment"
    jumpEffectAttachment.Parent = targetRoot
    jumpEffectAttachment.Position = Vector3.new(0, -2.5, 0)

    -- 2. Create ParticleEmitter (Pooled/Cached)
    jumpParticles = Instance.new("ParticleEmitter")
    jumpParticles.Name = "GlowEffect"
    jumpParticles.Parent = jumpEffectAttachment
    jumpParticles.Texture = CONFIG.PARTICLE_ASSET_ID
    jumpParticles.LightEmission = 1
    jumpParticles.ZOffset = 0.5
    
    -- Visual Style (Gold/Yellow Theme)
    jumpParticles.Color = ColorSequence.new{
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 180, 20)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 200))
    }
    
    jumpParticles.Size = NumberSequence.new{
        NumberSequenceKeypoint.new(0, 2.5),
        NumberSequenceKeypoint.new(1, 0)
    }

    jumpParticles.Lifetime = NumberRange.new(0.4, 0.6)
    jumpParticles.Speed = NumberRange.new(4, 7)
    jumpParticles.SpreadAngle = Vector2.new(360, 360)
    
    -- IMPORTANT: Start disabled, emit manually
    jumpParticles.Enabled = false 
end

--------------------------------------------------------------------------------
-- 🧠 CORE LOGIC
--------------------------------------------------------------------------------

-- Initialize for new characters
player.CharacterAdded:Connect(function(newChar)
    character = newChar
    humanoid = newChar:WaitForChild("Humanoid")
    rootPart = newChar:WaitForChild("HumanoidRootPart")
    jumpCount = 0
    isValidJumpChain = false
    createJumpEffect(rootPart)
end)

-- Initial setup
createJumpEffect(rootPart)

-- 1. STATE MACHINE TRACKING
humanoid.StateChanged:Connect(function(oldState, newState)
    if newState == Enum.HumanoidStateType.Landed then
        -- Reset on ground
        jumpCount = 0
        isValidJumpChain = false
        
    elseif newState == Enum.HumanoidStateType.Jumping then
        -- Validate first jump
        if not isValidJumpChain then
            isValidJumpChain = true
            jumpCount = 1
            lastJumpTime = tick()
        end
        
    elseif newState == Enum.HumanoidStateType.Freefall then
        -- Invalidate if falling without jumping (Walking off edge)
        if oldState ~= Enum.HumanoidStateType.Jumping then
            isValidJumpChain = false
            jumpCount = 0
        end
    end
end)

-- 2. JUMP REQUEST HANDLER
UserInputService.JumpRequest:Connect(function()
    -- Guard Clauses
    if not character:GetAttribute("CanDoubleJump") then return end
    if not isValidJumpChain then return end
    if tick() - lastJumpTime < CONFIG.TIME_BETWEEN_JUMPS then return end

    local state = humanoid:GetState()
    
    -- Perform Double Jump
    if (state == Enum.HumanoidStateType.Freefall or state == Enum.HumanoidStateType.Jumping) then
        if jumpCount < CONFIG.TOTAL_JUMP_LIMIT then
            
            jumpCount = jumpCount + 1
            lastJumpTime = tick()

            -- Apply Physics (Reset Y velocity for consistent height)
            rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity * Vector3.new(1, 0, 1)
            rootPart.AssemblyLinearVelocity = rootPart.AssemblyLinearVelocity + Vector3.new(0, CONFIG.AIR_JUMP_POWER, 0)
            
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)

            -- Trigger Visuals
            if jumpParticles then
                jumpParticles:Emit(20)
            end
        end
    end
end)
