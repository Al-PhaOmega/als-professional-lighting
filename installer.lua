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
VolumetricFog.Source = codes.Fog

local LensFlares = Instance.new("LocalScript", framework)
LensFlares.Name = "LensFlares"
LensFlares.Source = codes.Flare

local ScreenSpace = Instance.new("ModuleScript", game.ReplicatedStorage)
ScreenSpace.Name = "ScreenSpace"
ScreenSpace.Source = codes.SS

warn("INSTALLED APL. ||| PLEASE ENJOY")
