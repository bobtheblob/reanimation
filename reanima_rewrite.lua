getgenv = getgenv or function() return _G end
sethiddenproperty = sethiddenproperty
setsimulationradius = setsimulationradius or function(a,b)
	sethiddenproperty(game:GetService("Players").LocalPlayer,"SimulationRadius",a)
	sethiddenproperty(game:GetService("Players").LocalPlayer,"MaximumSimulationRadius",b)
end
if getgenv().reanimating then error'you are reanimating' end
getgenv().reanimating = true
local animate = loadstring(game:HttpGet'https://raw.githubusercontent.com/bobtheblob/reanimation/main/extensions/animate_r6.lua')
local setting = getgenv().reanim_settings or {
	ispermadeath = true,
	power = Vector3.new(0,30,0),
	positiontype = "cframe",
	mdirpower = 100
}
local infvec3 = Vector3.one*math.huge
local rs = game:GetService("RunService")
--
local plrs = game:GetService("Players")
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local hum = char:FindFirstChildWhichIsA("Humanoid")
local anima = hum:FindFirstChildWhichIsA("Animator")
--
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = 1
settings().Physics.ThrottleAdjustTime = 0
setsimulationradius(1e9,1e9)
--
local hdesc = Instance.new("HumanoidDescription")
local rig = game:GetService("Players"):CreateHumanoidModelFromDescription(hdesc,"R6")
local righum = rig:FindFirstChildWhichIsA("Humanoid")
local lt = tick()
local rigroot = righum.RootPart
if char:FindFirstChild("UpperTorso") then
	rig.PrimaryPart = rigroot
end
righum.DisplayName = ("_"):rep(30)
--
local anim = char:FindFirstChild("Animate")
if anim then
	anim:Destroy()
end
for i,v in pairs(hum:GetPlayingAnimationTracks()) do
	v:Stop()
end
for i,v in pairs(anima:GetPlayingAnimationTracks()) do
	v:Stop()
end
hum.RootPart.Anchored = true
task.wait(.1)
local pos = char:GetPivot()
rig:PivotTo(pos)
--
local netvel = Vector3.new(0,30,0)
local staticvel = Vector3.new(0,30,0)
local accessories = {}
local alignparts = {}
local addedaparts = {}
local dead = false
local connections = {}
local donotalign = {}
local flingpart = hum.RootPart
local peramdeath =false
--
local giveme = {}
if rig.PrimaryPart == rigroot then
	for i,v in pairs(char:children()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			local mainpart = rigroot
			if v.Name:find("Left") and (v.Name:find("Arm") or v.Name:find("Hand")) then
				mainpart = rig:FindFirstChild("Left Arm")
			end
			if v.Name:find("Right") and (v.Name:find("Arm") or v.Name:find("Hand")) then
				mainpart = rig:FindFirstChild("Right Arm")
			end
			if v.Name:find("Left") and (v.Name:find("Leg") or v.Name:find("Foot")) then
				mainpart = rig:FindFirstChild("Left Leg")
			end
			if v.Name:find("Right") and (v.Name:find("Leg") or v.Name:find("Foot")) then
				mainpart = rig:FindFirstChild("Right Leg")
			end
			if v.Name:find("Torso") then
				mainpart = rig:FindFirstChild("Torso")
			end
			if v.Name == "Head" then
				mainpart = rig:FindFirstChild("Head")
			end
			giveme[v] = mainpart.CFrame:Inverse()*v.CFrame
			alignparts[v] = mainpart
		end
	end
end
if setting.ispermadeath then
	peramdeath = true
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", false)
	plr.Character = nil
	plr.Character = char
	hum.RootPart.Anchored = true
	wait(plrs.RespawnTime+.25)
	hum.RootPart.Anchored = false
	for i,v in pairs(char:GetDescendants()) do
		if v:IsA("Motor6D") then
			v:Destroy()
		end
	end
else
	flingpart = char:FindFirstChild("Left Arm")
	hum.RootPart.Anchored = false
end
--
for i,v in pairs(char:children()) do
	if v:IsA("Accessory") and v:FindFirstChild("Handle") then
		workspace:UnjoinFromOutsiders({v:FindFirstChild("Handle")})
		local hand = v:FindFirstChild("Handle")
		local clone = v:Clone()
		local chand = clone:WaitForChild("Handle")
		clone.Parent = rig
		alignparts[hand] = chand
		accessories[v] = clone
	end
end
--
function raycast(ray,ign,tcac,iw)
	local ig = {char}
	if typeof(ign) == 'Instance' then
		table.insert(ig,ign)
	elseif typeof(ign) == 'table' then
		for i,v in pairs(ign) do
			table.insert(ig,v)
		end
	end
	return workspace:FindPartOnRayWithIgnoreList(ray,ig,tcac,iw)
end
--
for i,v in pairs(char:GetDescendants()) do
	if v:IsA("Motor6D") and v.Name ~= "Neck" and v.Name ~= "RootJoint" then
		v:Destroy()
	end
end
--
local netcheck = function(part)
	return part.ReceiveAge == 0
end
function isdead()
	return dead
end
function ispermadeath()
	return peramdeath
end
--
function networksetup(p0,p1)
	if setting.positiontype == "align" then
		local a0,a1 = Instance.new("Attachment"),Instance.new("Attachment")
		local alignpos,alignori = Instance.new("AlignPosition"),Instance.new("AlignOrientation")
		alignpos.Attachment0 = a0
		alignpos.Attachment1 = a1
		alignori.Attachment0 = a0
		alignori.Attachment1 = a1
		alignpos.Responsiveness = 2000
		alignori.Responsiveness = 2000
		alignpos.MaxForce = 1e9
		alignori.MaxTorque = 1e9
		a0.Parent = p0
		a1.Parent = p1
		a0.Name = "PART0_"..p1.Name
		a1.Name = "PART1_"..p0.Name
		alignpos.Parent,alignori.Parent = p1,p1
	end
	p0.CustomPhysicalProperties = PhysicalProperties.new(math.huge,math.huge,math.huge,math.huge,math.huge)
end
function align(p0 : Part,p1 : Part)
	if p0:GetAttribute("DontAlign") == nil then
		p0:ApplyImpulse(netvel)
		p0:ApplyAngularImpulse(Vector3.new())
		p0.AssemblyLinearVelocity = netvel
		p0.AssemblyAngularVelocity = Vector3.new()
		local cf = CFrame.new()
		if giveme[p0] then
			cf = giveme[p0]
		end
		if setting.positiontype == "cframe" then
			p0.CFrame = p1.CFrame*cf
		elseif setting.positiontype == "align" then
			local o = p0:FindFirstChild("PART0_"..p1.Name)
			o.CFrame = cf
		end
	end
end
--
connections[#connections+1] = rs.RenderStepped:Connect(function()
	if hum.MoveDirection.Magnitude > 0 then
		netvel = (hum.MoveDirection*setting.mdirpower)+setting.power
	else
		netvel = setting.power
	end
	if setting.ispermadeath then
		righum:Move(hum.MoveDirection,false)
		righum.Jump = hum.Jump
	end
end)
connections[#connections+1] = rs.Stepped:Connect(function()
	for i,v in pairs(rig:children()) do
		if v:isA("BasePart") then
			v.CanCollide = false
			v.Transparency = .7
		end
		if v:isA("Accessory") and v:FindFirstChild("Handle") then
			v:FindFirstChild("Handle").CanCollide = false
			v:FindFirstChild("Handle").Transparency = .7
		end
	end
	for i,v in pairs(char:GetDescendants()) do
		if v:isA("BasePart") then
			v.CanCollide = false
		end
	end
	local isfps = (workspace.CurrentCamera.CFrame.Position-rigroot.Position).Magnitude <= 2
	if isfps then
		for i,v in pairs(rig:GetDescendants()) do
			if v:isA("BasePart") then
				v.LocalTransparencyModifier = 1
			end
		end
		for i,v in pairs(char:GetDescendants()) do
			if v:isA("BasePart") then
				v.LocalTransparencyModifier = 1
			end
		end
	else
		for i,v in pairs(rig:GetDescendants()) do
			if v:isA("BasePart") then
				v.LocalTransparencyModifier = 0
			end
		end
		for i,v in pairs(char:GetDescendants()) do
			if v:isA("BasePart") then
				v.LocalTransparencyModifier = 0
			end
		end
	end
end)
if rig.PrimaryPart ~= rigroot then
	for i,v in pairs(rig:children()) do
		if char:FindFirstChild(v.Name) and v:IsA("BasePart") and (setting.ispermadeath == false and v.Name ~= "Torso" and v.Name ~= "Head" or true) then
			networksetup(char:FindFirstChild(v.Name),v)
		end
	end
end
connections[#connections+1] = rs.Heartbeat:Connect(function()
	local ypos = rigroot.Position.Y
	if ypos < workspace.FallenPartsDestroyHeight / 2 then
		for i,v in pairs(rig:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity = Vector3.new()
				v.RotVelocity = Vector3.new()
			end
		end
		rig:PivotTo(pos)
		for i,v in pairs(rig:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity = Vector3.new()
				v.RotVelocity = Vector3.new()
			end
		end
	end
	for i,v in pairs(alignparts) do
		if addedaparts[i] == nil then
			addedaparts[i] = true
			networksetup(i,v)
			align(i,v)
		elseif (i:IsDescendantOf(workspace) == false or v:IsDescendantOf(workspace)  == false) and addedaparts[i] then
			addedaparts[i] = nil
		else
			align(i,v)
		end
		if i:FindFirstChild("BOX") == nil then
			local box = Instance.new("SelectionBox")
			box.Parent = i
			box.LineThickness = .1
			box.Color3 = Color3.new(1,0,0)
			box.SurfaceTransparency = 1
			box.Adornee = i
			box.Name = "BOX"
			box.Visible = not netcheck(box.Parent)
		else
			local box = i:FindFirstChild("BOX")
			box.Visible = not netcheck(box.Parent)
		end
	end
	for i,v in pairs(rig:children()) do
		if char:FindFirstChild(v.Name) and v:IsA("BasePart") and (setting.ispermadeath == false and v.Name ~= "Torso" and v.Name ~= "Head" or true) then
			if char:FindFirstChild(v.Name):FindFirstChild("BOX") == nil then
				local box = Instance.new("SelectionBox")
				box.Parent = char:FindFirstChild(v.Name)
				box.LineThickness = .1
				box.Color3 = Color3.new(1,0,0)
				box.SurfaceColor3 = Color3.new(1,0,0)
				box.SurfaceTransparency = 0
				box.Adornee = char:FindFirstChild(v.Name)
				box.Name = "BOX"
				box.Visible = not netcheck(box.Parent)
			else
				local box = char:FindFirstChild(v.Name):FindFirstChild("BOX")
				box.Visible = not netcheck(box.Parent)
			end
			if setting.ispermadeath then
				align(char:FindFirstChild(v.Name),v)
			else
				if v.Name == "HumanoidRootPart" then
					align(char:FindFirstChild(v.Name),rig:FindFirstChild("Torso"))
				else
					align(char:FindFirstChild(v.Name),v)
				end
			end
		end
	end
	for i,v in pairs(hum:GetPlayingAnimationTracks()) do
		v:Stop(0)
	end
	for i,v in pairs(anima:GetPlayingAnimationTracks()) do
		v:Stop(0)
	end
end)

--
local resetBindable = Instance.new("BindableEvent")
resetBindable.Event:connect(function()
	getgenv().REANIMATE_Figure = nil
	plr.Character = rig
	addedaparts = {}
	alignparts = {}
	dead = true
	for i,v in pairs(connections) do
		v:Disconnect()
	end
	rig:BreakJoints()
	game:GetService("Debris"):AddItem(rig,1)
	plr.Character = char
	char:BreakJoints()
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
	getgenv().reanimating = false
end)
game:GetService("StarterGui"):SetCore("ResetButtonCallback", resetBindable)
--
rig.Name = "ClientChar"
if setting.ispermadeath == false then
	plr.Character = rig
else
	workspace.CurrentCamera.CameraSubject = righum
end
rig.Parent = workspace
getgenv().REANIMATE_Figure = rig
animate()
--
local box = Instance.new("SelectionBox")
box.Parent = flingpart
box.LineThickness = .05
box.Color3 = Color3.new(1,1,1)
box.SurfaceTransparency = .5
box.Adornee = flingpart
box.Name = "Da"
box.Visible = true
--
local dafling = 0
local power = Instance.new("BodyAngularVelocity")
power.Parent = flingpart
power.MaxTorque = infvec3
power.P = math.huge
power.AngularVelocity = Vector3.one*2000000
local bp
if setting.positiontype == "align" then
	flingpart:ClearAllChildren()
	bp = Instance.new("BodyPosition")
	bp.Position = flingpart.Position
	bp.MaxForce = infvec3
	bp.P = 25000
	bp.D = 200
	bp.Parent = flingpart
	connections[#connections+1] = rs.Heartbeat:Connect(function()
		if not flingpart:GetAttribute("DontAlign") then
			bp.Position = rigroot.Position
		end
	end)
end
function fling(p,dur)
	if isdead() then return end
	task.spawn(function()
		dafling = dafling + 1
		flingpart:SetAttribute("DontAlign",true)
		for i = 1,dur or 40 do
			rs.Heartbeat:Wait()
			flingpart:ApplyImpulse(setting.power)
			flingpart:ApplyAngularImpulse(Vector3.new())
			if typeof(p) == 'Instance' then
				if p:IsA("BasePart") then
					flingpart.CFrame = p.CFrame
				elseif p:IsA("Humanoid") then
					local root = p.Parent:FindFirstChild("Torso") or p.Parent:FindFirstChild("UpperTorso") or p.Parent:FindFirstChild("Head") or p.RootPart
					if root then
						if root.Velocity.Magnitude < 28 then
							local x,y,z = 0,0,0
							x = root.Position.X
							y = root.Position.Y
							z = root.Position.Z
							x = x + root.Velocity.X / 2
							y = y + root.Velocity.Y / 2
							z = z + root.Velocity.Z / 2
							flingpart.CFrame = CFrame.new(Vector3.new(x,y,z))
						else
							flingpart.CFrame = root.CFrame
						end

					end
				end
			elseif typeof(p) == 'Vector3' then
				flingpart.CFrame = CFrame.new(p)
			elseif typeof(p) == 'CFrame' then
				flingpart.CFrame = p
			end
			if bp then
				bp.Position = flingpart.Position
			end
			--flingpart.CFrame = flingpart.CFrame * CFrame.Angles(math.random(-360,360),math.random(-360,360),math.random(-360,360))
		end
		dafling = dafling - 1
		if dafling <= 0 then
			dafling = 0
			flingpart:SetAttribute("DontAlign",nil)
		end
	end)
end
rig.Parent = workspace
getgenv().REANIMATE_Figure = rig
local fake = Instance.new("LocalScript")
fake.Name = "Animate"
fake.Parent = rig
animate(fake)
return {
	['clone'] = rig,
	['isdead'] = isdead,
	['ispermadeath'] = ispermadeath,
	['fling'] = fling,
	['realchar'] = char,
	['clonehum'] = righum,
	['accessories'] = accessories,
	['netcheck'] = netcheck,
	['alignparts'] = alignparts,
	['resetevent'] = resetBindable,
	['raycast'] = raycast
}
