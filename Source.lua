-- Services

local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local ReSt = game:GetService("ReplicatedStorage")
local PPS = game:GetService("ProximityPromptService")

-- Variables

local Plr = Players.LocalPlayer
local Char = Plr.Character or Plr.CharacterAdded:Wait()
local Hum = Char:WaitForChild("Humanoid")

local SelfModules = {
    Functions = loadstring(game:HttpGet("https://github.com/IseeYou011011000110111101101100/CustomShopItems/raw/main/Functions.lua"))(),
    DoorReplication = loadstring(game:HttpGet("https://github.com/IseeYou011011000110111101101100/DoorReplication/raw/main/Source.lua"))(),
    Achievements = loadstring(game:HttpGet("https://github.com/IseeYou011011000110111101101100/CustomAchievements/raw/main/Source.lua"))(),
    CustomShop = loadstring(game:HttpGet("https://github.com/IseeYou011011000110111101101100/CustomShopItems/raw/main/CustomShopItems.lua"))(),
}
local Assets = {
    KeyItem = LoadCustomInstance("https://github.com/IseeYou011011000110111101101100/CursedKey/blob/main/CursedKeyItem.rbxm?raw=true"),
}

-- Functions

local function replicateDoor(room)
    local originalDoor = room:FindFirstChild("Door")

    if originalDoor then
        local door = SelfModules.DoorReplication.CreateDoor({
            Locked = room:WaitForChild("Assets"):WaitForChild("KeyObtain", 0.3) ~= nil,
            Sign = true,
            Light = true,
            Barricaded = false,
            CustomKeyNames = {"CursedKey"},
            DestroyKey = false,
            GuidingLight = true,
            FastOpen = false,
        })

        door.Model.Name = "FakeDoor"
        door.Model:SetPrimaryPartCFrame(originalDoor.PrimaryPart.CFrame)
        door.Model.Parent = room
        SelfModules.DoorReplication.ReplicateDoor(door)
        originalDoor:Destroy()
        
        door.Debug.OnDoorOpened = function()
            local key = Char:FindFirstChild(Assets.KeyItem.Name) or Char:FindFirstChild("Key")

            if key then
                if key.Name == Assets.KeyItem.Name then
                    local uses = key:GetAttribute("Uses") - 1
    
                    if uses == 0 then
                        key:Destroy()
    
                        SelfModules.Achievements.Get({
                            Title = "Unbolting Hazard",
                            Desc = "Indefinitely cursing yourself.",
                            Reason = "Breaking the Cursed Key.",
                            Image = "https://media.discordapp.net/attachments/1035320391142477896/1036335501004779632/unknown.png",
                        })
                    else
                        key:SetAttribute("Uses", uses)
                    end
    
                    Hum.Health = math.max(Hum.Health - 10, 0)
                    workspace.Curse:Play()
                else
                    key:Destroy()
                end
            end
        end
    end
end

-- Scripts

if typeof(Assets.KeyItem) ~= "Instance" then
    return
end

Assets.KeyItem.Curse.Parent = workspace

-- Door replication setup

task.spawn(function()
    for _, v in next, workspace.CurrentRooms:GetChildren() do
        if v:FindFirstChild("Door") and v.Door:FindFirstChild("Lock") then
            replicateDoor(v)
        end
    end
    
    workspace.CurrentRooms.DescendantAdded:Connect(function(des)
        if des.Name == "Lock" and des.Parent.Name == "Door" then
            task.wait(0.3)

            if des.Parent then
                replicateDoor(des.Parent.Parent)
            end
        end
    end)
end)

-- Obtain cursed key

SelfModules.CustomShop.CreateItem(Assets.KeyItem:Clone(), {
    Title = "Cursed Key",
    Desc = "Five uses, holds secrets",
    Image = "https://media.discordapp.net/attachments/1035320391142477896/1035697972924661790/CursedKey.png",
    Price = 100,
    Stack = 1,
})
