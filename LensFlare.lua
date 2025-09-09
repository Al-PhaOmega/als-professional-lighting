-- [[ Multi-light lens flare ]] --

local screenSpace = require(script:WaitForChild("ScreenSpace"))

local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local camera = workspace.CurrentCamera
local localPlayer = Players.LocalPlayer
local playerGui = localPlayer:WaitForChild("PlayerGui")
local flareTemplate = playerGui:WaitForChild("LensFlareTemplate")

local tweenInfo = TweenInfo.new(0.025, Enum.EasingStyle.Linear, Enum.EasingDirection.InOut)
local zOffsetDistance = script:GetAttribute("ZOffset")

-- at top, once
if script:GetAttribute("GlobalOpacity") == nil then
	script:SetAttribute("GlobalOpacity", 1) -- 1 = normal, 0 = fully hidden
end


-- Worldspace UI plane
local flarePlane = Instance.new("Part")
flarePlane.Anchored = true
flarePlane.CanCollide = false
flarePlane.CanQuery = false
flarePlane.CanTouch = false
flarePlane.Transparency = 1
flarePlane.Name = "FlarePlane"
flarePlane.Parent = workspace

-- Folder to hold per-light anchors
local anchorsFolder = Instance.new("Folder")
anchorsFolder.Name = "LensFlareAnchors"
anchorsFolder.Parent = workspace

-- Track: Light Instance -> Anchor Part
local lightMap = {}

-- Utils
local function getBasePartFaceCenter(part: BasePart, faceEnum)
	local n = Vector3.fromNormalId(faceEnum)
	local offset = Vector3.new(
		n.X * (part.Size.X * 0.5),
		n.Y * (part.Size.Y * 0.5),
		n.Z * (part.Size.Z * 0.5)
	)
	local push = n.Magnitude > 0 and n.Unit * 0.05 or Vector3.zero
	return (part.CFrame * CFrame.new(offset + push)).Position
end

local function getLightWorldPosition(light: Instance): Vector3
	local parent = light.Parent
	if not parent then return Vector3.zero end

	if parent:IsA("Attachment") then
		return parent.WorldPosition
	end

	if parent:IsA("BasePart") then
		-- SurfaceLight and SpotLight can have Face; PointLight ignores Face
		if light:IsA("SurfaceLight") then
			return getBasePartFaceCenter(parent, light.Face)
		elseif light:IsA("SpotLight") and parent:FindFirstChildOfClass("Attachment") == nil then
			-- SpotLight on face uses Face; on Attachment handled above
			return getBasePartFaceCenter(parent, light.Face)
		else
			return parent.Position
		end
	end

	if parent:IsA("Model") and parent.PrimaryPart then
		return parent.PrimaryPart.Position
	end

	return Vector3.zero
end

local function createAnchorForLight(light: Instance)
	if lightMap[light] then return end

	local anchor = Instance.new("Part")
	anchor.Name = ("LensFlare_%s"):format(light.Name)
	anchor.Anchored = true
	anchor.CanCollide = false
	anchor.CanQuery = false
	anchor.CanTouch = false
	anchor.Transparency = 1
	anchor.Parent = anchorsFolder

	-- Tag so existing UI path works
	CollectionService:AddTag(anchor, "LensFlare")

	-- Defaults; adjust if you want per-light tuning
	anchor:SetAttribute("LensFlareStrength", 1)
	anchor:SetAttribute("LensFlareRange", 0)

	-- Attach UI
	local ui = flareTemplate:Clone()
	ui.Name = "FlareUI"
	ui.Parent = anchor

	lightMap[light] = anchor
end

local function destroyAnchorForLight(light: Instance)
	local anchor = lightMap[light]
	if anchor then
		lightMap[light] = nil
		anchor:Destroy()
	end
end

-- Scan existing lights
local function isLight(inst: Instance)
	return inst:IsA("PointLight") or inst:IsA("SpotLight") or inst:IsA("SurfaceLight")
end

for _, inst in ipairs(workspace:GetDescendants()) do
	if isLight(inst) then
		createAnchorForLight(inst)
	end
end

-- React to changes
workspace.DescendantAdded:Connect(function(inst)
	if isLight(inst) then
		createAnchorForLight(inst)
	end
end)

workspace.DescendantRemoving:Connect(function(inst)
	if isLight(inst) then
		destroyAnchorForLight(inst)
	end
end)

-- Visibility test
local function testVisibility(cameraPos: Vector3, worldPos: Vector3, flareObject: Instance)
	local point, onScreen = camera:WorldToViewportPoint(worldPos)
	if not onScreen then
		return false, nil
	end

	-- FP passthrough for own character
	local distFromChar = localPlayer:DistanceFromCharacter(cameraPos)
	if distFromChar <= 2 then
		CollectionService:AddTag(localPlayer.Character, "LensFlarePassthrough")
	else
		CollectionService:RemoveTag(localPlayer.Character, "LensFlarePassthrough")
	end

	local rp = RaycastParams.new()
	rp.FilterDescendantsInstances = {CollectionService:GetTagged("LensFlarePassthrough"), flareObject}
	rp.IgnoreWater = true

	local direction = (worldPos - cameraPos)
	local hit = workspace:Raycast(cameraPos, direction, rp)
	if hit then
		return false, Vector2.new(point.X, point.Y)
	end

	return true, Vector2.new(point.X, point.Y)
end

-- UI sizing
local function updateUiSize()
	zOffsetDistance = script:GetAttribute("ZOffset")

	local viewX = camera.ViewportSize.X
	local viewY = camera.ViewportSize.Y

	local newSize = Vector3.new(
		screenSpace.ScreenWidthToWorldWidth(viewX, zOffsetDistance),
		screenSpace.ScreenHeightToWorldHeight(viewY, zOffsetDistance),
		0.001
	)

	flarePlane.Size = newSize
	return Vector2.new(viewX, viewY)
end

-- Per-frame
local function onRender()
	local viewSize = updateUiSize()
	if not viewSize then return end

	local aspect = camera.ViewportSize.X / camera.ViewportSize.Y
	local screenCenter = camera.ViewportSize * 0.5
	local camPos = camera.CFrame.Position

	flarePlane.CFrame = camera.CFrame * CFrame.new(0, 0, zOffsetDistance)

	for light, anchor in pairs(lightMap) do
		-- Skip disabled lights
		if not light.Enabled then
			if anchor:FindFirstChild("FlareUI") then
				anchor.FlareUI.Enabled = false
			end
			continue
		end

		-- Update anchor position
		if light.Parent then
			anchor.Position = getLightWorldPosition(light)
		end
		
		local ui = anchor:FindFirstChild("FlareUI")
		if not ui then
			ui = flareTemplate:Clone()
			ui.Name = "FlareUI"
			ui.Parent = anchor
		end
		ui.Adornee = flarePlane
		ui.Enabled = true
		ui.CanvasSize = viewSize

		local frame = ui:FindFirstChild("Frame")
		if not frame then continue end

		local sprites = frame:GetChildren()

		local worldPos = anchor.Position
		local visible, pt = testVisibility(camPos, worldPos, anchor)

		if not pt then
			-- Off-screen: hard hide
			for _, obj in ipairs(sprites) do
				if obj:IsA("ImageLabel") then
					obj.Visible = false
					obj.ImageTransparency = 1
				end
			end
			continue
		end

		local flareScreen = Vector2.new(pt.X, pt.Y)
		local toCenter = screenCenter - flareScreen

		for _, obj in ipairs(sprites) do
			if not obj:IsA("ImageLabel") then continue end

			-- Always set position; visibility handled below
			local offset = obj:GetAttribute("Offset")
			local finalPos = (flareScreen + (toCenter * 0.05)) + (toCenter * offset)
			obj.Position = UDim2.new(0, finalPos.X, 0, finalPos.Y)

			-- Rotation
			if obj:GetAttribute("CanRotate") then
				local baseRot = obj:GetAttribute("BaseRotation")
				local dir = finalPos - flareScreen
				local ang = math.atan2(dir.Y, dir.X)
				obj.Rotation = (math.deg(ang) - 90) + baseRot
			end

			-- Composite transparency:
			-- 1) base from screen position and strength
			-- 2) linear distance fade: 10 studs fully visible, 20 studs invisible
			-- 3) occlusion/off-screen gating
			local absDist = Vector2.new(math.abs(toCenter.X), math.abs(toCenter.Y))
			local strength = anchor:GetAttribute("LensFlareStrength") or 1
			local baseT = (obj:GetAttribute("Transparency") or 0) +
				((((absDist / screenCenter).Magnitude) / aspect) / math.max(strength, 0.001))
			baseT = math.clamp(baseT, obj:GetAttribute("Transparency") or 0, 1)

			local d = (camPos - worldPos).Magnitude
			local visFactor = math.clamp(1 - ((d - 20) / 10), 0, 1) -- 1 @10, 0 @>=20

			-- global opacity
			local g = math.clamp(script:GetAttribute("GlobalOpacity") or 1, 0, 1)

			-- Compute final transparency regardless of visibility
			local unclampedT = math.clamp(baseT * visFactor + (1 - visFactor), 0, 1)
			local finalT = 1 - (1 - unclampedT) * g  -- lerp(1, unclampedT, g)

			-- Force full transparency and hide if occluded
			if not visible then
				finalT = 1
				obj.Visible = false
			else
				obj.Visible = true
			end

			-- Apply the transparency
			TweenService:Create(obj, tweenInfo, {ImageTransparency = finalT}):Play()
		end
	end
end

RunService:BindToRenderStep("LensFlareIterate", Enum.RenderPriority.Camera.Value + 1, onRender)
