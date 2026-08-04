local TeleportService = game:GetService("TeleportService")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer

-- СПИСОК ИЗ 20 ИГР
local PLACES = {
    ["MM2 🔪"] = 142823291, ["BedWars ⚔️"] = 6872265039, ["BloxFruits 🍎"] = 2753915549,
    ["Brookhaven 🏡"] = 4913581622, ["AdoptMe 🐶"] = 920587237, ["Doors 👁️"] = 6516141723,
    ["Jailbreak 🚓"] = 606849621, ["DaHood ⛓️"] = 2788229376, ["BladeBall ⚽"] = 13772394625,
    ["PrisonLife 🔓"] = 155615604, ["NinjaLeg 🥷"] = 3956818381, ["Flee🏃"] = 893973440,
    ["Tower🗼"] = 1962086868, ["Slap🖐️"] = 6403338905, ["Strongest🥊"] = 10449761463,
    ["PetSim🐱"] = 8737899170, ["Evade🏃‍♂️"] = 9872477797, ["Arsenal 🔫"] = 286090424,
    ["Hide🙈"] = 20522438, ["Speed👟"] = 18336484
}

local selectedPlaceId = 142823291
local activePortal = nil
local activePortalConnections = {}

-- КОМПАКТНЫЙ ИНТЕРФЕЙС (Высота немного увеличена до 135 для поля ввода)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "RickPortal_CustomID"
ScreenGui.Parent = game.CoreGui
ScreenGui.ResetOnSpawn = false

local MainFrame = Instance.new("Frame")
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
MainFrame.BorderSizePixel = 1
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 50)
MainFrame.Position = UDim2.new(0.1, 0, 0.1, 0)
MainFrame.Size = UDim2.new(0, 360, 0, 135) -- Увеличили со 100 до 135
MainFrame.Active = true
MainFrame.Draggable = true

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, -50, 0, 25)
Title.BackgroundColor3 = Color3.fromRGB(25, 35, 25)
Title.Font = Enum.Font.SourceSansBold
Title.Text = " 🌀 Portal Gun C-137 (Custom ID)"
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.TextSize = 12
Title.TextXAlignment = Enum.TextXAlignment.Left
Title.Parent = MainFrame

local OpenBtn = Instance.new("TextButton")
OpenBtn.Size = UDim2.new(0, 40, 0, 40)
OpenBtn.BackgroundColor3 = Color3.fromRGB(20, 25, 20)
OpenBtn.BorderSizePixel = 1
OpenBtn.BorderColor3 = Color3.fromRGB(0, 255, 50)
OpenBtn.Font = Enum.Font.SourceSansBold
OpenBtn.Text = "🌀"
OpenBtn.TextSize = 20
OpenBtn.TextColor3 = Color3.fromRGB(0, 255, 100)
OpenBtn.Visible = false
OpenBtn.Active = true
OpenBtn.Draggable = true
OpenBtn.Parent = ScreenGui

local function createWinBtn(text, xOffset, color, cb)
    local b = Instance.new("TextButton", MainFrame)
    b.Size = UDim2.new(0, 20, 0, 20)
    b.Position = UDim2.new(1, xOffset, 0, 2)
    b.BackgroundColor3 = color
    b.BorderSizePixel = 0
    b.Font = Enum.Font.SourceSansBold
    b.Text = text
    b.TextColor3 = Color3.fromRGB(255, 255, 255)
    b.TextSize = 11
    b.MouseButton1Click:Connect(cb)
end

createWinBtn("—", -44, Color3.fromRGB(50, 60, 50), function()
    MainFrame.Visible = false
    OpenBtn.Position = MainFrame.Position
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    OpenBtn.Visible = false
    MainFrame.Position = OpenBtn.Position
    MainFrame.Visible = true
end)

local function destroyExistingPortal()
    for _, conn in pairs(activePortalConnections) do if conn then conn:Disconnect() end end
    activePortalConnections = {}
    if activePortal and activePortal.Parent then
        local portalToDestroy = activePortal; activePortal = nil
        local close = TweenService:Create(portalToDestroy, TweenInfo.new(0.3), {Size = Vector3.new(0.1, 0.1, 0.1)})
        close:Play()
        close.Completed:Connect(function() portalToDestroy:Destroy() end)
    end
end

createWinBtn("X", -22, Color3.fromRGB(120, 20, 20), function()
    destroyExistingPortal()
    ScreenGui:Destroy()
end)

-- ГОРИЗОНТАЛЬНЫЙ СПИСОК ИГР
local ScrollList = Instance.new("ScrollingFrame")
ScrollList.Size = UDim2.new(1, -10, 0, 30)
ScrollList.Position = UDim2.new(0, 5, 0, 32)
ScrollList.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ScrollList.BorderSizePixel = 0
ScrollList.ScrollingDirection = Enum.ScrollingDirection.X
ScrollList.CanvasSize = UDim2.new(0, 1600, 0, 0)
ScrollList.ScrollBarThickness = 3
ScrollList.Parent = MainFrame

local UIListLayout = Instance.new("UIListLayout")
UIListLayout.Parent = ScrollList
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.Padding = UDim.new(0, 4)

local function refreshList()
    for name, id in pairs(PLACES) do
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 75, 1, 0)
        btn.BackgroundColor3 = Color3.fromRGB(30, 35, 30)
        btn.Font = Enum.Font.SourceSansBold
        btn.Text = name
        btn.TextSize = 11
        btn.TextColor3 = (selectedPlaceId == id) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(180, 180, 180)
        btn.BorderSizePixel = 0
        btn.Parent = ScrollList
        
        btn.MouseButton1Click:Connect(function()
            selectedPlaceId = id
            for _, child in pairs(ScrollList:GetChildren()) do
                if child:IsA("TextButton") then
                    child.TextColor3 = (PLACES[child.Text] == id) and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(180, 180, 180)
                end
            end
        end)
    end
end
refreshList()

-- ФУНКЦИЯ СПАВНА КАНОНИЧНОГО ПОРТАЛА
local function spawnRickPortal(targetId)
    local character = LocalPlayer.Character
    if not character or not character:FindFirstChild("HumanoidRootPart") then return end
    
    local spawnCFrame = character.HumanoidRootPart.CFrame * CFrame.new(0, 0, -8)
    destroyExistingPortal()
    
    local portal = Instance.new("Part")
    portal.Size = Vector3.new(0.1, 0.1, 0.1)
    portal.CFrame = spawnCFrame * CFrame.new(0, 3.5, 0)
    portal.Anchored = true; portal.CanCollide = false
    portal.Material = Enum.Material.Neon; portal.Color = Color3.fromRGB(0, 220, 40)
    portal.Transparency = 0.15; portal.Parent = workspace
    activePortal = portal

    local mesh = Instance.new("SpecialMesh", portal)
    mesh.MeshType = Enum.MeshType.Sphere

    local texture1 = Instance.new("Decal", portal)
    texture1.Texture = "rbxassetid://10850750560"; texture1.Face = Enum.NormalId.Front
    local texture2 = Instance.new("Decal", portal)
    texture2.Texture = "rbxassetid://10850750560"; texture2.Face = Enum.NormalId.Back

    local att = Instance.new("Attachment", portal)
    local p = Instance.new("ParticleEmitter", att)
    p.Texture = "rbxassetid://243020610"; p.Rate = 80; p.Speed = NumberRange.new(3, 5)
    p.Color = ColorSequence.new(Color3.fromRGB(0, 255, 50))

    TweenService:Create(portal, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {Size = Vector3.new(7.5, 10.5, 0.2)}):Play()

    local rotConnection; local rot = 0
    rotConnection = game:GetService("RunService").Heartbeat:Connect(function()
        if portal and portal.Parent then rot = rot + 6; texture1.Rotation = rot; texture2.Rotation = -rot else rotConnection:Disconnect() end
    end)
    table.insert(activePortalConnections, rotConnection)

    local connection
    connection = game:GetService("RunService").Heartbeat:Connect(function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            if (char.HumanoidRootPart.Position - portal.Position).Magnitude < 4.8 then
                connection:Disconnect(); destroyExistingPortal()
                pcall(function() char.HumanoidRootPart.Anchored = true end)
                task.wait(0.1)
                TeleportService:Teleport(targetId, LocalPlayer)
            end
        end
    end)
    table.insert(activePortalConnections, connection)
    task.delay(25, function() if connection.Connected then destroyExistingPortal() end end)
end

-- КНОПКИ ДЕЙСТВИЙ (Нижний ряд)
local function createActionButton(text, x, y, width, height, color, cb)
    local btn = Instance.new("TextButton", MainFrame)
    btn.Size = UDim2.new(0, width, 0, height)
    btn.Position = UDim2.new(0, x, 0, y)
    btn.BackgroundColor3 = color
    btn.BorderSizePixel = 0
    btn.Font = Enum.Font.SourceSansBold
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(255, 255, 255)
    btn.TextSize = 11
    btn.MouseButton1Click:Connect(cb)
end

-- Кнопка: Выстрелить по списку
createActionButton("💥 ВЫСТРЕЛИТЬ (СПИСОК)", 5, 68, 120, 26, Color3.fromRGB(0, 110, 25), function()
    spawnRickPortal(selectedPlaceId)
end)

-- Кнопка: Убрать
createActionButton("❌ УБРАТЬ ПОРТАЛ", 130, 68, 105, 26, Color3.fromRGB(90, 45, 15), function()
    destroyExistingPortal()
end)

-- Кнопка: Rejoin
createActionButton("🔄 REJOIN СЕРВЕРА", 240, 68, 115, 26, Color3.fromRGB(40, 40, 40), function()
    destroyExistingPortal()
    if #game.Players:GetPlayers() <= 1 then
        TeleportService:Teleport(game.PlaceId, LocalPlayer)
    else
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
    end
end)

-- =========================================================================
-- НОВОЕ ПОЛЕ ДЛЯ ЛЮБОГО СВОЕГО ID
-- =========================================================================

local IdInput = Instance.new("TextBox", MainFrame)
IdInput.Size = UDim2.new(0, 220, 0, 26)
IdInput.Position = UDim2.new(0, 5, 0, 102)
IdInput.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
IdInput.BorderSizePixel = 1
IdInput.BorderColor3 = Color3.fromRGB(40, 50, 40)
IdInput.Font = Enum.Font.SourceSans
IdInput.Text = ""
IdInput.PlaceholderText = " Введите ID любого плейса..."
IdInput.TextColor3 = Color3.fromRGB(255, 255, 255)
IdInput.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
IdInput.TextSize = 11
IdInput.ClearTextOnFocus = false

-- Кнопка выстрела по кастомному ID
createActionButton("🌀 ВЫСТРЕЛИТЬ В ID", 232, 102, 123, 26, Color3.fromRGB(0, 150, 100), function()
    local inputId = tonumber(IdInput.Text)
    if inputId then
        spawnRickPortal(inputId)
    else
        IdInput.Text = "Неверный ID!"
        task.wait(1.5)
        IdInput.Text = ""
end
end)
