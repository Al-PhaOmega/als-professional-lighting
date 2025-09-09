--[[

--Volumetric lightning/fog script--
------- Made by LinoIsThere -------
--------- Version: 2.0.0 ----------

Put the folder "VolumetricFog" in
           Workspace

]]--[[

Settings Information:
(Settings are found in the "VolumetricFog" folder,
inside of the "Settings" instance as attributes)

- Dithering:
Noise effect that reduces visual artifacts.

- Enabled:
Enables the volumetric fog.

- Layers:
How many beam layers will be created.

- LayersSpacing:
How much distance will have the layers between them.

- LightInfluence:
How much light influence the fog has.

- Tint:
The tint of the fog.

- Transparency:
How much transparency will have each layer.

]]





local Layers = {}
local Thread

local SettingsInstance = game.ReplicatedStorage.Fog_Settings

local Settings = {
	Enabled = SettingsInstance:GetAttribute("Enabled") or true,
	Layers = SettingsInstance:GetAttribute("Layers") or 200,
	LayerSpacing = SettingsInstance:GetAttribute("LayerSpacing") or 0.5,
	Transparency = NumberSequence.new(SettingsInstance:GetAttribute("Transparency")) or NumberSequence.new(0.99),
	LightInfluence = SettingsInstance:GetAttribute("LightInfluence") or 1,
	Tint = ColorSequence.new(SettingsInstance:GetAttribute("Tint")) or ColorSequence.new(Color3.new(1, 1, 1)),
	Dithering = SettingsInstance:GetAttribute("Dithering") or true,
}

local CurrentCamera = game.Workspace:WaitForChild("Camera")
local CurrentViewport = CurrentCamera.ViewportSize
local CurrentFOV = CurrentCamera.FieldOfView

--Create a camera part
local CameraPart = Instance.new("Part", workspace)
CameraPart.Transparency = 1
CameraPart.Size = Vector3.new(1, 1, 1)
CameraPart.CanCollide = false
CameraPart.Anchored = true
CameraPart.Name = "Camera"
CameraPart.Parent = game.Workspace

--Instances
local Attachment = Instance.new("Attachment")
Attachment.Visible = false

local Beam = Instance.new("Beam")
Beam.TextureMode = Enum.TextureMode.Stretch
Beam.TextureLength = 1
Beam.Segments = 1
if Settings.Dithering == true then
	Beam.Texture = "rbxassetid://81288576486784" -- DITTERED TEXTURE
end
Beam.TextureSpeed = 0
Beam.FaceCamera = false
Beam.LightEmission = 1

--Code
function UpdateLayers(Viewport, FOV)
	local tan = math.tan(math.rad(FOV/2))
	local ratioY = ((0.1*tan)/0.1)
	local ratioX = ((0.1*Viewport.X*tan)/Viewport.Y/0.1)

	for i=1, #Layers do
		local Layer = Layers[i]

		local b = Layer[1]
		local a1 = Layer[2]
		local a2 = Layer[3]

		local PositionZ = (i-1)*Settings.LayerSpacing	

		local RandomSpeed = math.random(-100,100)
		local randomy = math.random(0,1000)/800
		a1.Position = Vector3.new((ratioX*PositionZ), 0, -PositionZ)+Vector3.new(0,randomy,0)
		a2.Position = Vector3.new(-(ratioX*PositionZ), 0, -PositionZ)+Vector3.new(0,randomy,0)
		b.Width0 = (ratioY*PositionZ)*2+randomy*2
		b.Width1 = (ratioY*PositionZ)*2+randomy*2

		a1.Parent = CameraPart
		a2.Parent = CameraPart
		b.Parent = CameraPart
		b.TextureLength = ratioX/ratioY
		b.TextureSpeed = RandomSpeed
	end
	Thread = task.delay(2, function()
		for i=1, #Layers do
			local Layer = Layers[i]

			local b = Layer[1]

			b.TextureSpeed = 0
		end
	end)
end

function ReDrawLayers()
	for i=1, #Layers do
		local Beam = Layers[i][1]
		Beam.Color = Settings.Tint
		Beam.Transparency = Settings.Transparency
		Beam.LightInfluence = Settings.LightInfluence
		if Settings.Dithering == true then
			Beam.Texture = "rbxassetid://81288576486784"
		else
			Beam.Texture = "rbxassetid://0"
		end
	end
end

function CreateLayers(Viewport, FOV)
	local nLayers = 1

	local tan = math.tan(math.rad(FOV/2))
	local ratioY = (0.1*tan)/0.1
	local ratioX = (0.1*Viewport.X*tan)/Viewport.Y/0.1
	for i=1, Settings.Layers do
		local b = Beam:Clone()
		local a1 = Attachment:Clone()
		local a2 = Attachment:Clone()
		b.Attachment0 = a1
		b.Attachment1 = a2
		Layers[nLayers] = {b, a1, a2}
		nLayers = nLayers + 1
	end
	UpdateLayers(Viewport, FOV)
	ReDrawLayers()
end

function DeleteLayers()
	Layers = {}
	for i, v in pairs(CameraPart:GetChildren()) do
		v:Destroy()
	end
end

CreateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)

SettingsInstance:GetAttributeChangedSignal("Enabled"):Connect(function()
	Settings.Enabled = SettingsInstance:GetAttribute("Enabled")
	if Settings.Enabled == false then
		DeleteLayers()
	else
		CreateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)
	end
end)
SettingsInstance:GetAttributeChangedSignal("Dithering"):Connect(function()
	Settings.Dithering = SettingsInstance:GetAttribute("Dithering")
	ReDrawLayers()
end)
SettingsInstance:GetAttributeChangedSignal("Layers"):Connect(function()
	Settings.Layers = SettingsInstance:GetAttribute("Layers")
	DeleteLayers()
	CreateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)
end)
SettingsInstance:GetAttributeChangedSignal("LayerSpacing"):Connect(function()
	Settings.LayerSpacing = SettingsInstance:GetAttribute("LayerSpacing")
	UpdateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)
end)
SettingsInstance:GetAttributeChangedSignal("LightInfluence"):Connect(function()
	Settings.LightInfluence = SettingsInstance:GetAttribute("LightInfluence")
	ReDrawLayers()
end)
SettingsInstance:GetAttributeChangedSignal("Tint"):Connect(function()
	Settings.Tint = ColorSequence.new(SettingsInstance:GetAttribute("Tint"))
	ReDrawLayers()
end)
SettingsInstance:GetAttributeChangedSignal("Transparency"):Connect(function()
	Settings.Transparency = NumberSequence.new(SettingsInstance:GetAttribute("Transparency"))
	ReDrawLayers()
end)

game:GetService("RunService").RenderStepped:Connect(function()
	if CameraPart ~= nil then
		CameraPart.CFrame = CurrentCamera.CFrame
	end
	if CurrentCamera.ViewportSize ~= CurrentViewport then
		UpdateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)
		CurrentViewport = CurrentCamera.ViewportSize	
	end
	if CurrentCamera.FieldOfView ~= CurrentFOV then
		UpdateLayers(CurrentCamera.ViewportSize, CurrentCamera.FieldOfView)
		CurrentFOV = CurrentCamera.FieldOfView
	end
end)
