-----------------------------------------
-- Combined Script: PD + Reborn + Auto Set Character
-----------------------------------------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
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
    if userToggle then
       toggleButton.Text = "ON"
    else
       toggleButton.Text = "OFF"
    end
end)

------------------------------------------------
-- PHẦN 1: Check PD + Clan + Reset (xem CHECK PD + CLAN + RESET.txt :contentReference[oaicite:0]{index=0}&#8203;:contentReference[oaicite:1]{index=1})
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

local function tryResetIfNotLegendary()
    if isPDActive() then
        print("💀 PD đang diễn ra...")
        if not isLegendaryClan() then
            local char = player.Character or player.CharacterAdded:Wait()
            local hum = char:FindFirstChildOfClass("Humanoid")
            if hum then
                hum.Health = 0
                warn("❌ Không phải clan Legendary → Đã tự sát để roll lại.")
            else
                warn("⚠️ Không tìm thấy Humanoid.")
            end
            return true -- đã reset
        else
            warn("🌟 Clan Legendary! Không reset.")
            return false -- không reset
        end
    else
        warn("⏳ PD chưa active.")
        return false -- không active
    end
end

------------------------------------------------
-- PHẦN 2: Reborn (xem REBORN.txt :contentReference[oaicite:2]{index=2}&#8203;:contentReference[oaicite:3]{index=3})
------------------------------------------------
local TARGET_POS = Vector3.new(15281.845703, 8.999996, 1.378267)
local STOP_DISTANCE = 5

local function performReborn()
    local character = player.Character or player.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")
    local hrp = character:WaitForChild("HumanoidRootPart")
    local reached = false

    -- Di chuyển đến vị trí TARGET
    spawn(function()
        while not reached do
            local distance = (hrp.Position - TARGET_POS).Magnitude
            if distance > STOP_DISTANCE then
                humanoid:MoveTo(TARGET_POS)
            end
            wait(0.5)
        end
    end)
    humanoid.MoveToFinished:Connect(function(success)
        if success and (hrp.Position - TARGET_POS).Magnitude <= STOP_DISTANCE then
            reached = true
            print("[AUTO MOVE] Đã tới vị trí.")
        end
    end)
    while not reached do wait() end
    wait(1.5)

    -- Tìm và kích hoạt Prompt gần (để tương tác NPC)
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
    wait(1)
    
    local remote = ReplicatedStorage:WaitForChild("Bridgenet2Main"):WaitForChild("dataRemoteEvent")
    -- Remote Step 1
    remote:FireServer({
        {
            Message = "Oh, you have come koangu. What are you here for?",
            Choice = "I seek a new start.",
            Name = "???",
            Choices = {
                "I seek a new start.",
                "I should go.",
                "I want to go back."
            },
            Properties = {
                RegularDelay = 0.02,
                DotDelay = 0,
                Name = "?",
                Sound = "rbxassetid://6929790120"
            },
            Part = 1,
            NPCName = ""
        },
        "\3"
    })
    wait(1)
    -- Remote Step 2
    remote:FireServer({
        {
            Message = "Do you seek a new beginning, or perhaps do you seek something else?",
            Choice = "Im ready for a new beginning.",
            Name = "???",
            Choices = {
                "Im ready for a new beginning.",
                "I'm not too sure."
            },
            Properties = {
                RegularDelay = 0.02,
                DotDelay = 0,
                Name = "?",
                Sound = "rbxassetid://6929790120"
            },
            Part = 2,
            NPCName = ""
        },
        "\3"
    })
    wait(1)
    -- Remote Step 3
    remote:FireServer({
        {
            Message = "Very well... But know this: once your past is erased, theres no going back.",
            Choice = "I accept my fate.",
            Name = "???",
            Choices = {
                "I accept my fate.",
                "Wait, Im not sure."
            },
            Properties = {
                RegularDelay = 0.02,
                DotDelay = 0,
                Name = "?",
                Sound = "rbxassetid://6929790120"
            },
            Part = 3,
            NPCName = ""
        },
        "\3"
    })
    print("✅ Wipe complete via remote!")
end

------------------------------------------------
-- PHẦN 3: Auto Set Character (xem AUTO SET CHARACTER.txt :contentReference[oaicite:4]{index=4}&#8203;:contentReference[oaicite:5]{index=5})
------------------------------------------------
local function autoSetCharacter()
    local playerGui = player:WaitForChild("PlayerGui")
    local customizeGui = playerGui:WaitForChild("CUSTOMIZE")
    local remoteEvent = customizeGui:WaitForChild("RemoteEvent")
    local gender = "Female"       -- Đổi thành "Male" nếu muốn
    local race = "Ghoul"          -- Đổi chủng tộc nếu muốn
    local name = "Kuronaai"       -- Đổi tên theo ý bạn
    remoteEvent:FireServer(gender, race, name)
    print("✅ Đã gửi yêu cầu tạo nhân vật:", gender, race, name)
end

------------------------------------------------
-- Vòng lặp chính: Kiểm tra điều kiện, thực hiện PD, reborn, auto set character rồi repeat
------------------------------------------------
while true do
    if userToggle then
        -- Kiểm tra trạng thái PD
        if not isPDActive() then
            notificationLabel.Text = "Server không có PD"
            notificationLabel.Visible = true
            print("Server không có PD. Chờ PD active...")
            wait(5)  -- Chờ trước khi kiểm tra lại
            notificationLabel.Visible = false
        else
            notificationLabel.Visible = false
            -- Nếu PD active: thử reset nếu cần (nếu không phải clan Legendary)
            local didReset = tryResetIfNotLegendary()
            if didReset then
                -- Chờ nhân vật respawn sau reset
                player.CharacterAdded:Wait()
                wait(1)
            end
            -- Thực hiện reborn
            performReborn()
            -- Sau đó tự động set character
            autoSetCharacter()
        end
    else
        print("Auto script is OFF")
    end
    wait(5)  -- Khoảng thời gian chờ giữa các chu trình
end
