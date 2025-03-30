-----------------------------------------
-- Combined Script: PD + Reborn + Auto Set Character (Tốc độ cao, Instant Reset nếu không Legendary)
-----------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local player = Players.LocalPlayer
local RunService = game:GetService("RunService")

------------------------------------------------
-- Tạo UI với nút ON/OFF và thông báo
------------------------------------------------
local ScreenGui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
local toggleButton = Instance.new("TextButton", ScreenGui)
toggleButton.Text = "OFF"
toggleButton.Size = UDim2.new(0, 100, 0, 50)
toggleButton.Position = UDim2.new(0, 10, 0, 10)

local notificationLabel = Instance.new("TextLabel", ScreenGui)
notificationLabel.Size = UDim2.new(0, 200, 0, 50)
notificationLabel.Position = UDim2.new(0, 10, 0, 70)
notificationLabel.Text = ""
notificationLabel.Visible = false

local userToggle = false
toggleButton.MouseButton1Click:Connect(function()
    userToggle = not userToggle
    toggleButton.Text = userToggle and "ON" or "OFF"
end)

------------------------------------------------
-- PHẦN 1
------------------------------------------------
local legendaryClans = {"Yoshimura", "Washuu"}

local function getCurrentClan()
    local entity = workspace:FindFirstChild("Entities") and workspace.Entities:FindFirstChild(player.Name)
    if not entity then return nil end
    local clanVal = entity:FindFirstChild("Clan")
    if clanVal and typeof(clanVal.Value) == "string" then
        return clanVal.Value
    end
    return nil
end

local function isLegendaryClan()
    local clan = getCurrentClan()
    if not clan then return false end
    for _, name in ipairs(legendaryClans) do
        if clan == name then
            return true
        end
    end
    return false
end

local function isPDActive()
    local gui = player:WaitForChild("PlayerGui")
    local hud = gui:FindFirstChild("HUD", true)
    if not hud then return false end
    local combatTimer = hud:FindFirstChild("CombatTimer", true)
    if not combatTimer then return false end
    local bg = combatTimer:FindFirstChild("Background")
    if not bg then return false end
    local inCombatText = bg:FindFirstChild("InCombatText")
    if not inCombatText or not inCombatText:IsA("TextLabel") then return false end
    local text = inCombatText.Text
    return text and text:upper():find("DEATH AWAITS") ~= nil
end

-- Khi PD active và nếu không thuộc clan Legendary thì reset ngay tức thời
local function tryResetIfNotLegendary()
    if isPDActive() then
        print("💀 PD đang diễn ra...")
        if not isLegendaryClan() then
            print("❌ Không phải clan Legendary → Tự sát ngay lập tức!")
            player:LoadCharacter()  -- Reset nhân vật ngay lập tức
            return true
        else
            print("🌟 Clan Legendary! Không reset.")
            return false
        end
    else
        print("⏳ PD chưa active.")
        return false
    end
end

------------------------------------------------
-- PHẦN 2
------------------------------------------------
local TARGET_POS = Vector3.new(15281.845703, 8.999996, 1.378267)
local STOP_DISTANCE = 5

local function performReborn()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    local reached = false
    
    -- Sử dụng dash bằng cách spam phím Q (sau khi định hướng nhân vật về hướng tọa độ đích)
    task.spawn(function()
        while not reached do
            local distance = (hrp.Position - TARGET_POS).Magnitude
            if distance > STOP_DISTANCE then
                hrp.CFrame = CFrame.new(hrp.Position, TARGET_POS)
                VirtualInputManager:SendKeyEvent(true, "q", false, game)
                VirtualInputManager:SendKeyEvent(false, "q", false, game)
            else
                reached = true
            end
            task.wait(0.1)
        end
    end)
    while not reached do task.wait(0.1) end
    task.wait(0.3)
    
    -- Tương tác với NPC (tốc độ nhanh)
    local function firePromptNear()
        for _, obj in ipairs(workspace:GetDescendants()) do
            if obj:IsA("ProximityPrompt") and obj.Enabled then
                local parent = obj.Parent
                if parent and parent.Position and (parent.Position - hrp.Position).Magnitude <= 10 then
                    fireproximityprompt(obj)
                    print("[AUTO E] Đã tương tác NPC.")
                    return true
                end
            end
        end
        warn("[WARN] Không tìm thấy Prompt để tương tác.")
        return false
    end
    firePromptNear()
    task.wait(0.3)
    
    local remote = ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent")
    -- Các bước remote event
    remote:FireServer({
        {
            Message = "Oh, you have come koangu. What are you here for?",
            Choice = "I seek a new start.",
            Name = "???",
            Choices = {"I seek a new start.", "I should go.", "I want to go back."},
            Properties = {RegularDelay = 0.02, DotDelay = 0, Name = "?", Sound = "rbxassetid://6929790120"},
            Part = 1,
            NPCName = ""
        },
        "\3"
    })
    task.wait(0.3)
    remote:FireServer({
        {
            Message = "Do you seek a new beginning, or perhaps do you seek something else?",
            Choice = "Im ready for a new beginning.",
            Name = "???",
            Choices = {"Im ready for a new beginning.", "I'm not too sure."},
            Properties = {RegularDelay = 0.02, DotDelay = 0, Name = "?", Sound = "rbxassetid://6929790120"},
            Part = 2,
            NPCName = ""
        },
        "\3"
    })
    task.wait(0.3)
    remote:FireServer({
        {
            Message = "Very well... But know this: once your past is erased, theres no going back.",
            Choice = "I accept my fate.",
            Name = "???",
            Choices = {"I accept my fate.", "Wait, Im not sure."},
            Properties = {RegularDelay = 0.02, DotDelay = 0, Name = "?", Sound = "rbxassetid://6929790120"},
            Part = 3,
            NPCName = ""
        },
        "\3"
    })
    print("✅ Wipe complete via remote!")
end

------------------------------------------------
-- PHẦN 3
------------------------------------------------
local function autoSetCharacter()
    local playerGui = player:WaitForChild("PlayerGui")
    local customizeGui = playerGui:WaitForChild("CUSTOMIZE")
    local remoteEvent = customizeGui:WaitForChild("RemoteEvent")
    local gender = "Female"  -- Đổi thành "Male" nếu muốn
    local race = "Ghoul"     -- Đổi chủng tộc nếu muốn
    local name = "Kuronaai"  -- Đổi tên theo ý bạn
    remoteEvent:FireServer(gender, race, name)
    print("✅ Đã gửi yêu cầu tạo nhân vật:", gender, race, name)
end

------------------------------------------------
-- Kiểm tra trạng thái sau chết (afterdead) và trạng thái tạo nhân vật
------------------------------------------------
local function isAfterDead()
    local character = player.Character
    if not character then return true end
    local humanoid = character:FindFirstChildOfClass("Humanoid")
    return (humanoid and humanoid.Health <= 0) or false
end

local function isInCharacterCreation()
    local playerGui = player:FindFirstChild("PlayerGui")
    return playerGui and playerGui:FindFirstChild("CUSTOMIZE") and true or false
end

------------------------------------------------
-- Vòng lặp chính: Kiểm tra trạng thái và thực hiện các bước theo thứ tự (afterdead → reborn → tạo nhân vật → PD)
------------------------------------------------
while true do
    if userToggle then
        if isAfterDead() then
            print("Player ở trạng thái afterdead, thực hiện reborn...")
            performReborn()
            autoSetCharacter()
            player.CharacterAdded:Wait()
            task.wait(0.1)
        elseif isInCharacterCreation() then
            print("Đang ở giao diện tạo nhân vật, tự động set nhân vật...")
            autoSetCharacter()
            task.wait(0.1)
            -- Sau khi tạo, nếu không phải clan Legendary thì reset ngay
            if not isLegendaryClan() then
                print("Không phải clan Legendary, reset ngay!")
                player:LoadCharacter()
                player.CharacterAdded:Wait()
            end
        else
            if not isPDActive() then
                notificationLabel.Text = "Server không có PD"
                notificationLabel.Visible = true
                print("Server không có PD. Chờ PD active...")
                task.wait(2)
                notificationLabel.Visible = false
            else
                notificationLabel.Visible = false
                local didReset = tryResetIfNotLegendary()
                if didReset then
                    player.CharacterAdded:Wait()
                    task.wait(0.1)
                end
                performReborn()
                autoSetCharacter()
                -- Kiểm tra ngay sau tạo nhân vật, nếu không phải clan Legendary thì reset tức thì
                if not isLegendaryClan() then
                    print("Không phải clan Legendary, reset ngay sau tạo nhân vật!")
                    player:LoadCharacter()
                    player.CharacterAdded:Wait()
                end
            end
        end
    else
        print("Auto script is OFF")
    end
    task.wait(2)
end
