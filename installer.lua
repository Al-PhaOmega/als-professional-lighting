local Http = game:GetService("HttpService")

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
VolumetricFog.Source = Http:GetAsync("https://raw.githubusercontent.com/Al-PhaOmega/als-professional-lighting/main/VolumetricFog.lua")

warn("INSTALLED APL. ||| PLEASE ENJOY")
