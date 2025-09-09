local Http = game:GetService("HttpService")

local codes = {}
codes.Fog = 'https://raw.githubusercontent.com/Al-PhaOmega/als-professional-lighting/refs/heads/main/VolumetricFog.lua'
codes.Flare = 'https://raw.githubusercontent.com/Al-PhaOmega/als-professional-lighting/refs/heads/main/LensFlare.lua'
codes.SS = 'https://raw.githubusercontent.com/Al-PhaOmega/als-professional-lighting/refs/heads/main/ScreenSpace.lua'

local framework = Instance.new("Folder", game.StarterPlayer.StarterPlayerScripts)
framework.Name = "APL_Client"

local module = Instance.new("Configuration", game.ReplicatedStorage)
module.Name = "Fog_Setings"
module:SetAttribute("Enabled", true)
module:SetAttribute("Dithering", true)
module:SetAttribute("Layers", 200)
module:SetAttribute("LayerSpacing", 0.5)
module:SetAttribute("LightInfluence", 1)
module:SetAttribute("Tint", Color3.fromRGB(255, 255, 255))
module:SetAttribute("Transparency", 0.995)

local VolumetricFog = Instance.new("LocalScript", framework)
VolumetricFog.Name = "VolumetricFog"
VolumetricFog.Source = Http:GetAsync(codes.Fog)

local LensFlares = Instance.new("LocalScript", framework)
LensFlares.Name = "LensFlares"
LensFlares.Source = Http:GetAsync(codes.Flare)

local ScreenSpace = Instance.new("ModuleScript", game.ReplicatedStorage)
ScreenSpace.Name = "ScreenSpace"
ScreenSpace.Source = Http:GetAsync(codes.SS)

local LightLensFlare = Instance.new("SurfaceGui", game.StarterGui)
LightLensFlare.Name = "LightLensFlare"
LightLensFlare.Brightness = 2.5
LightLensFlare.Face = Enum.NormalId.Back
LightLensFlare.LightInfluence = 0
LightLensFlare.MaxDistance = 0
LightLensFlare.CanvasSize = Vector2.new(1920, 1080)
LightLensFlare.SizingMode = Enum.SurfaceGuiSizingMode.FixedSize

local frame = Instance.new("Frame", LightLensFlare)
frame.AnchorPoint = Vector2.new(0.5, 0.5)
frame.BackgroundTransparency = 1
frame.BorderSizePixel = 0
frame.ClipsDescendants = false
frame.ZIndex = 1
frame.Position = UDim2.new(0.5, 0, 0.5, 0)

local function light(name: string, id: number, values: {[string]: any})
	assert(name, "Must contain a valid string")
	assert(id, "Must contain a valid number")
	assert(values, "Must contain a valid table of values")

	local decal = Instance.new("ImageLabel", frame)
	decal.Image = "rbxassetid://" .. tostring(id)
	decal.Name = name
	decal.BackgroundTransparency = 1
	decal.BorderSizePixel = 0
	decal.ClipsDescendants = false
	decal.AnchorPoint = Vector2.new(0.5, 0.5)
	decal.ImageTransparency = 1
	decal.ResampleMode = Enum.ResamplerMode.Default
	decal.ScaleType = Enum.ScaleType.Stretch
	
	local aspect = Instance.new("UIAspectRatioConstraint", decal)
	aspect.AspectRatio = 1
	aspect.AspectType = Enum.AspectType.FitWithinMaxSize
	aspect.DominantAxis = Enum.DominantAxis.Height

	for key, value in pairs(values) do
		local success, _ = pcall(function()
			local _ = decal[key]
		end)

		if success and decal:FindFirstChild(key) == nil then
			local assignSuccess, assignErr = pcall(function()
				decal[key] = value
			end)

			if not assignSuccess then
				warn(`Failed to assign property "{key}" to decal: {assignErr}`)
			end
		else
			local attrSuccess, attrErr = pcall(function()
				decal:SetAttribute(key, value)
			end)

			if not attrSuccess then
				warn(`Failed to set attribute "{key}" on decal: {attrErr}`)
			end
		end
	end
end

light("BaseGlow", 1215684307, {
	ImageColor3 = Color3.fromRGB(176, 208, 255),
	Size = UDim2.new(0.5, 0, 0.125, 0),
	
	BaseRotation = 0,
	CanRotate = true,
	Offset = -0.35,
	FlareTransparency = 0.35
})

light("BaseGlow", 1215684307, {
	ImageColor3 = Color3.fromRGB(202, 232, 255),
	Size = UDim2.new(0.5, 0, 0.065, 0),

	BaseRotation = 0,
	CanRotate = true,
	Offset = -0.45,
	FlareTransparency = 0.35
})

light("Bokeh", 1215684307, {
	ImageColor3 = Color3.fromRGB(184, 212, 255),
	Size = UDim2.new(0.5, 0, 0.25, 0),

	BaseRotation = 0,
	CanRotate = true,
	Offset = 0.45,
	FlareTransparency = 0.6
})

light("Bokeh", 1215684307, {
	ImageColor3 = Color3.fromRGB(202, 255, 198),
	Size = UDim2.new(0.5, 0, 0.125, 0),

	BaseRotation = 0,
	CanRotate = true,
	Offset = 0.6,
	FlareTransparency = 0.5
})

light("Bokeh", 1215684307, {
	ImageColor3 = Color3.fromRGB(235, 255, 189),
	Size = UDim2.new(0.5, 0, 0.125, 0),

	BaseRotation = 0,
	CanRotate = true,
	Offset = 1.6,
	FlareTransparency = 0.65
})

light("Bokeh", 1215684307, {
	ImageColor3 = Color3.fromRGB(170, 207, 255),
	Size = UDim2.new(0.5, 0, 0.125, 0),

	BaseRotation = 0,
	CanRotate = true,
	Offset = 2,
	FlareTransparency = 0.7
})

light("Glare", 9691415433, {
	ImageColor3 = Color3.fromRGB(180, 213, 255),
	Size = UDim2.new(0.5, 0, 0.25, 0),

	BaseRotation = 0,
	CanRotate = false,
	Offset = 0.55,
	FlareTransparency = 0.4
})

light("Glare", 9691415433, {
	ImageColor3 = Color3.fromRGB(232, 255, 166),
	Size = UDim2.new(0.5, 0, 0.35, 0),

	BaseRotation = 0,
	CanRotate = false,
	Offset = 1.85,
	FlareTransparency = 0.45
})

light("Glare", 9691415433, {
	ImageColor3 = Color3.fromRGB(162, 203, 255),
	Size = UDim2.new(0.5, 0, 0.35, 0),

	BaseRotation = 0,
	CanRotate = false,
	Offset = 0.5,
	FlareTransparency = 0.5
})

light("RainbowFar", 2033611536, {
	ImageColor3 = Color3.fromRGB(255, 255, 255),
	Size = UDim2.new(0.5, 0, 0.6, 0),

	BaseRotation = -90,
	CanRotate = true,
	Offset = 1.15,
	FlareTransparency = 0.75
})

warn("INSTALLED APL. ||| PLEASE ENJOY")
