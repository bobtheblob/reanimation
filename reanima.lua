local ENUM = {
	FLINGTYPES = {
		ROTVEL = 0,
		BODYTHRUST = 1,
	},
	REANIMTYPES = {
		PERMADEATH = 0,
		NONPERMA = 1,
		HATALIGN_NONPERMA = 2,
		HATALIGN_SEMIBOT_FLING = 3,
	},
	REANIMMODES = {
		R6 = 0,
		R15 = 1,
	}
}
local netvel = Vector3.new(30.5,0,0)
_G.ReanimType = _G.ReanimType or ENUM.REANIMTYPES.PERMADEATH
if _G.reanim then error'you are reanimating' end
settings().Physics.AllowSleep = false
settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
_G.reanim = true
perma = _G.ReanimType == ENUM.REANIMTYPES.PERMADEATH
local mode = _G.ReanimMode or ENUM.REANIMMODES.R6
local reanimtype = _G.ReanimType
local plr = game:GetService("Players").LocalPlayer
local char = plr.Character
local hum = char:FindFirstChildWhichIsA("Humanoid")
local r6 = char:FindFirstChild("Torso") and true or false
local rs = game:GetService("RunService")
local hb = rs.Heartbeat
local stp = rs.Stepped
local rstp = rs.RenderStepped
local cf = char:GetPivot()
local lastcf = hum.RootPart.CFrame
local hbt = {}
local stpt = {}
local rstpt = {}
local lastpos = char:GetPivot()
char.Archivable = true
local clone
local accessed = true
if mode == 0 then
	accessed = false
	local c = char:FindFirstChildOfClass("HumanoidDescription",true) or Instance.new("HumanoidDescription")
	c.BodyTypeScale = .3
	c.DepthScale = 1
	c.HeadScale = 1
	c.HeightScale = 1
	c.ProportionScale = 1
	c.WidthScale = 1
	clone = game:GetService("Players"):CreateHumanoidModelFromDescription(c,"R6")
elseif mode == 1 then
	accessed = false
	local c = char:FindFirstChildOfClass("HumanoidDescription",true) or Instance.new("HumanoidDescription")
	c.BodyTypeScale = .3
	c.DepthScale = 1
	c.HeadScale = 1
	c.HeightScale = 1
	c.ProportionScale = 1
	c.WidthScale = 1
	clone = game:GetService("Players"):CreateHumanoidModelFromDescription(c,"R15")
end
local clonetors = clone:WaitForChild("Torso")
local ctrs = clone:FindFirstChild("Torso")
local semibot = reanimtype == ENUM.REANIMTYPES.HATALIGN_SEMIBOT_FLING and r6 and ctrs
local cloneroot = clone.HumanoidRootPart
local acs = {}
if accessed == false then
	for i,v in pairs(char:children()) do
		if v:IsA("Accessory") then
			local c = v:Clone()
			c.Parent = clone
			table.insert(acs,{v,c})

		end
	end
end
function permadeath(anchor)
	hum.RootPart.Anchored = true
	hum.AutoRotate = false
	hum.WalkSpeed = 0
	hum.JumpPower = 0
	hum.PlatformStand = true
	hb:Wait()
	plr.Character = nil
	plr.Character = char
	hum.PlatformStand = true
	wait(game:GetService("Players").RespawnTime+.2)
	hum.PlatformStand = true
	if anchor == true then
		for i,v in pairs(clone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
			end
		end
	end
	hum.Health = 0
	clone.Parent = workspace
	wait()

	clone:FindFirstChildWhichIsA("Humanoid").BreakJointsOnDeath = false
	clone.Name = "clientCharacter"
	clone:FindFirstChildWhichIsA("Humanoid").DisplayName = "-------------"


end
if perma then
	local anc = r6 == false and true or false
	permadeath(anc)
	wait(.1)
end
if r6 == false then
	cf = char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Torso") or char:FindFirstChild("UpperTorso")
	cf = cf.CFrame
	clone.PrimaryPart = cloneroot
end
clone:PivotTo(cf)
local bp = {
	["Left Arm"] = "LeftLowerArm",
	["Right Arm"] = "RightLowerArm",
	["Left Leg"] = "LeftLowerLeg",
	["Right Leg"] = "RightLowerLeg",
	["Torso"] = "UpperTorso",
}
if perma then
	clone.Parent = workspace
else
	clone.Parent = char
end
char.Archivable = false
local cf = {}
function WorldAlign(Part0,Part1,Position,Angle)
	local AlignPos = Instance.new('AlignPosition', Part1)
	AlignPos.ApplyAtCenterOfMass = true
	AlignPos.MaxForce = 67752
	AlignPos.MaxVelocity = math.huge/9e110
	AlignPos.ReactionForceEnabled = false
	AlignPos.Responsiveness = 200
	AlignPos.RigidityEnabled = true
	local AlignOri = Instance.new('AlignOrientation', Part1)
	AlignOri.MaxAngularVelocity = math.huge/9e110
	AlignOri.MaxTorque = 67752
	AlignOri.PrimaryAxisOnly = false
	AlignOri.ReactionTorqueEnabled = false
	AlignOri.Responsiveness = 200
	AlignOri.RigidityEnabled = true
	local AttachmentA=Instance.new('Attachment',Part1)
	local AttachmentB=Instance.new('Attachment',Part0)
	local AttachmentC=Instance.new('Attachment',Part1)
	local AttachmentD=Instance.new('Attachment',Part0)
	AttachmentA.WorldCFrame = Part0.CFrame
	AttachmentC.WorldCFrame = Part0.CFrame
	AlignPos.Attachment1 = AttachmentA;
	AlignPos.Attachment0 = AttachmentB;
	AlignOri.Attachment1 = AttachmentC;
	AlignOri.Attachment0 = AttachmentD;
end
function CFAlign(Part0,Part1,Position,Angle)
	table.insert(cf,{Part0,Part1,Position,Angle})
end
function Align(Part0,Part1,Position,Angle)
	local AlignPos = Instance.new('AlignPosition', Part1)
	AlignPos.ApplyAtCenterOfMass = true
	AlignPos.MaxForce = 67752
	AlignPos.MaxVelocity = math.huge/9e110
	AlignPos.ReactionForceEnabled = false
	AlignPos.Responsiveness = 200
	AlignPos.RigidityEnabled = true
	local AlignOri = Instance.new('AlignOrientation', Part1)
	AlignOri.MaxAngularVelocity = math.huge/9e110
	AlignOri.MaxTorque = 67752
	AlignOri.PrimaryAxisOnly = false
	AlignOri.ReactionTorqueEnabled = false
	AlignOri.Responsiveness = 200
	AlignOri.RigidityEnabled = true
	local AttachmentA=Instance.new('Attachment',Part1)
	local AttachmentB=Instance.new('Attachment',Part0)
	local AttachmentC=Instance.new('Attachment',Part1)
	local AttachmentD=Instance.new('Attachment',Part0)
	AttachmentC.Orientation = Angle or Vector3.new()
	AttachmentA.Position = Position or Vector3.new()
	AlignPos.Attachment1 = AttachmentA;
	AlignPos.Attachment0 = AttachmentB;
	AlignOri.Attachment1 = AttachmentC;
	AlignOri.Attachment0 = AttachmentD;
end
function SocketAlign(Part0,Part1,Position,Angle)
	local AlignPos = Instance.new('BallSocketConstraint', Part1)
	local AttachmentA=Instance.new('Attachment',Part1)
	local AttachmentB=Instance.new('Attachment',Part0)
	local AttachmentC=Instance.new('Attachment',Part1)
	local AttachmentD=Instance.new('Attachment',Part0)
	AttachmentC.Orientation = Angle or Vector3.new()
	AttachmentA.Position = Position or Vector3.new()
	AlignPos.Attachment1 = AttachmentA;
	AlignPos.Attachment0 = AttachmentB;
end
local clonehum = clone:FindFirstChildWhichIsA("Humanoid")
function hbeat(f)
	table.insert(hbt,f)
end
function step(f)
	table.insert(stpt,f)
end
function rstep(f)
	table.insert(rstpt,f)
end
local frame = 0
step(function(a,b)
	frame = frame + 1
	for i,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = false
		end
	end
	if frame < 30 then
		for i,v in pairs(clone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
	clonehum.Jump = hum.Jump
	clonehum:Move(hum.MoveDirection,false)
end)
local alignfunc = Align
if perma then
	if r6 == false then
		for i,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = true
			end
		end
		wait(.2)
		for i,v in pairs(char:children()) do
			if v:isA("BasePart") then
				if v.Name:find("Torso") then
					WorldAlign(v,clone:FindFirstChild("Torso"))
				elseif v.Name:find("Left") then
					if v.Name:find("Leg") or v.Name:find("Foot") then
						WorldAlign(v,clone:FindFirstChild("Left Leg"))
					end
					if v.Name:find("Arm") or v.Name:find("Hand") then
						WorldAlign(v,clone:FindFirstChild("Left Arm"))
					end
				elseif v.Name:find("Right") then
					if v.Name:find("Leg") or v.Name:find("Foot") then
						WorldAlign(v,clone:FindFirstChild("Right Leg"))
					end
					if v.Name:find("Arm") or v.Name:find("Hand") then
						WorldAlign(v,clone:FindFirstChild("Right Arm"))
					end
				else
					WorldAlign(v,clone:FindFirstChild(v.Name))
				end
			end
		end
		for i,v in pairs(acs) do
			pcall(function()
				v[1].Handle:BreakJoints()
				alignfunc(v[1].Handle,v[2].Handle)
			end)
		end

		wait(.2)
		for i,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
			end
		end
		for i,v in pairs(clone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
			end
		end
	else
		for i,v in pairs(char:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Anchored = false
			end
		end
		for i,v in pairs(char:children()) do
			if v:isA("BasePart") and clone:FindFirstChild(v.Name) then
				if v.Name == "LowerTorso" then
					alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.8,0))
				elseif v.Name == "UpperTorso" then
					alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.5,0))
				else
					if v.Name == "HumanoidRootPart" then
						Align(v,clone:FindFirstChild(v.Name))
					else
						alignfunc(v,clone:FindFirstChild(v.Name))
					end
				end
			end
		end
		for i,v in pairs(char:children()) do
			if v:isA("BasePart") then
				if bp[v.Name] then
					if v.Name == "Torso" then
						Align(v,clone:FindFirstChild(bp[v.Name]),Vector3.new(0,-.1,0))
					elseif v.Name:find("Leg") then
						Align(v,clone:FindFirstChild(bp[v.Name]),Vector3.new(0,.2,0))
					else
						alignfunc(v,clone:FindFirstChild(bp[v.Name]))
					end
				end
			end
		end
		for i,v in pairs(acs) do
			pcall(function()
				v[1].Handle:BreakJoints()
				alignfunc(v[1].Handle,v[2].Handle)
			end)
		end
	end	
else
	if r6 then
		if semibot then
			for i,v in pairs(char:GetDescendants()) do
				if v:isA("Motor6D") and v:IsDescendantOf(clone) == false and v.Name ~= "Neck" and v.Name ~= "RootJoint" and v.Name ~= "Root" and v.Name ~= "Root Hip" then
					v:Destroy()
				end
			end
			for i,v in pairs(char:children()) do
				if v:isA("BasePart") and clone:FindFirstChild(v.Name) and v.Name ~= "Head" and v.Name ~= "HumanoidRootPart" and v.Name ~= "Torso" then
					if v.Name == "Torso" then
						alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.4,0))
					else
						alignfunc(v,clone:FindFirstChild(v.Name))
					end
				end
			end
		else
			for i,v in pairs(char:GetDescendants()) do
				if v:isA("Motor6D") and v:IsDescendantOf(clone) == false and v.Name ~= "Neck" and v.Name ~= "RootJoint" and v.Name ~= "Root" and v.Name ~= "Root Hip" then
					v:Destroy()
				end
			end
			for i,v in pairs(char:children()) do
				if v:isA("BasePart") and clone:FindFirstChild(v.Name) and v.Name ~= "Head" and v.Name ~= "HumanoidRootPart" then
					if v.Name == "Torso" then
						alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.4,0))
					else
						alignfunc(v,clone:FindFirstChild(v.Name))
					end
				end
			end
		end

	else
		for i,v in pairs(char:GetDescendants()) do
			if v:isA("Motor6D") and v:IsDescendantOf(clone) == false and v.Name ~= "Neck" and v.Name ~= "RootJoint" and v.Name ~= "Root Hip" and v.Name ~= "Root" then
				v:Destroy()
			end
		end
		for i,v in pairs(char:children()) do
			if v:isA("BasePart") and clone:FindFirstChild(v.Name) and v.Name ~= "Head" and v.Name ~= "HumanoidRootPart" then
				if v.Name == "LowerTorso" then
					alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.8,0))
				elseif v.Name == "UpperTorso" then
					alignfunc(v,clone:FindFirstChild(v.Name),Vector3.new(0,.5,0))
				else
					alignfunc(v,clone:FindFirstChild(v.Name))
				end
			end
		end
		for i,v in pairs(char:children()) do
			if v:isA("BasePart") and v.Name ~= "Head" and v.Name ~= "HumanoidRootPart" then
				if bp[v.Name] then
					alignfunc(v,clone:FindFirstChild(bp[v.Name]))
				end
			end
		end
	end
	if reanimtype == ENUM.REANIMTYPES.HATALIGN_NONPERMA or reanimtype == ENUM.REANIMTYPES.HATALIGN_SEMIBOT_FLING then
		for i,v in pairs(acs) do
			workspace:UnjoinFromOutsiders({v[1].Handle})
			alignfunc(v[1].Handle,v[2].Handle)
		end
	end
	char.Animate:Destroy()
	for i,v in pairs(char.Humanoid.Animator:GetPlayingAnimationTracks()) do
		v:Stop()
	end
end

table.foreach(acs,function(i,v)
	table.foreach(v,function(a,b)
		print(b,b.Parent)
	end)
end)
hum.RootPart.CFrame = lastcf
hum.RootPart.Anchored=false
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
local resetBindable = Instance.new("BindableEvent")
if r6 == false then
	clone:PivotTo(CFrame.new(lastpos.Position)*CFrame.new(0,30,0))
else
	clone:PivotTo(CFrame.new(lastpos.Position)*CFrame.new(0,10,0))
end
local rootpos
rstep(function()
	if cloneroot.Velocity.Y > .1 then
		netvel = Vector3.new(0,cloneroot.Velocity.Unit.Y*30.5,0)+(clonehum.MoveDirection*30.5)
	elseif clonehum.MoveDirection.Magnitude > 0 then
		netvel = clonehum.MoveDirection*30.5
	else
		netvel = Vector3.new(0,30.5,0)
	end
	for i,v in pairs(cf) do
		pcall(function()
			local pos = v[3]
			local ang = v[4]
			local addcf = CFrame.new()
			if pos then
				addcf = addcf*CFrame.new(pos)
			end
			if ang then
				addcf = addcf*CFrame.fromOrientation(ang)
			end
			v[1].CFrame = CFrame.new(v[2].CFrame.Position)*CFrame.Angles(v[2].CFrame:ToEulerAnglesXYZ())*addcf
		end)
	end
end)
hbeat(function()
	for i,v in pairs(char:GetDescendants()) do
		if v:IsA("BasePart") and (clonetors.Position-v.Position).Magnitude > 50 then
			task.spawn(function()
				v.CFrame = clonetors.CFrame
				wait()
				v.Velocity = Vector3.new(0,30.5,0)
			end)
		end
	end
	for i,v in pairs(clone:GetDescendants()) do
		if v:IsA("BasePart") and v.Velocity.magnitude > 900 and v.Name ~="HumanoidRootPart" then
			v.Velocity = Vector3.new()
		end
		if v:IsA("BasePart") and v.Velocity.magnitude > 900 and v.Name =="HumanoidRootPart" then
			v.CFrame = rootpos
			v.Anchored = true
			v.Velocity = Vector3.new()
			task.wait()
			v.Anchored = false

		end
	end
	rootpos = cloneroot.CFrame
	if clone:GetPivot().Position.Y < workspace.FallenPartsDestroyHeight/4 then
		clone:PivotTo(CFrame.new(lastpos.Position))
		for i,v in pairs(clone:GetDescendants()) do
			if v:IsA("BasePart") then
				v.Velocity = Vector3.new()
			end
		end
		for i1,v1 in pairs(clone:GetDescendants()) do
			if v1:IsA("BasePart") and v1.Name ~="HumanoidRootPart" then
				v1.CFrame = rootpos
			end
		end
	end
	if clone:IsDescendantOf(workspace) == false then
		resetBindable:Fire()
	end
end)

local aa
local bb
local cc
aa=hb:Connect(function(a)
	for i,v in pairs(hbt) do coroutine.wrap(v)(a) end
end)
bb=stp:Connect(function(a,b)
	for i,v in pairs(stpt) do coroutine.wrap(v)(a,b) end
end)
cc=rstp:Connect(function(a)
	for i,v in pairs(rstpt) do coroutine.wrap(v)(a) end
end)
local Alloweds = {
	"Pal Hair",
	"Robloxclassicred",
	"Hat1",
	"International Fedora",
	"LavanderHair",
	"Pink Hair",
	"Kate Hair",
}
for i,v in next, game:GetService("Players").LocalPlayer.Character:GetDescendants() do
	if v:IsA("BasePart") and v.Name ~="HumanoidRootPart" then
		game:GetService'RunService'.Heartbeat:Connect(function()
			v.Velocity = netvel
			task.wait(.5)
		end)
	end
end
resetBindable.Event:connect(function()
	_G.Ignores = {}
	_G.reanim = false
	hbt = {}
	stpt = {}
	rstpt = {}
	aa:Disconnect()
	bb:Disconnect()
	cc:Disconnect()
	plr.Character = clone
	clone:Destroy()
	plr.Character = char
	char:BreakJoints()
	game:GetService("StarterGui"):SetCore("ResetButtonCallback", true)
end)
game:GetService("StarterGui"):SetCore("ResetButtonCallback", resetBindable)
if semibot and r6 and ctrs then
	local trs1
	local trs2
	local hed
	local ign = _G.Ignores or {}
	for i,v in pairs(clone:children()) do
		if v:IsA("Accessory") and v:FindFirstChild("Handle") and table.find(Alloweds,v.Name)then
			local hand = v:FindFirstChild("Handle")
			local real = char:FindFirstChild(v.Name)
			if hand.Size == Vector3.new(1,1,1) and hed == nil then
				hed = hand
			end
			if hand.Size == Vector3.new(1,1,2) and trs1 == nil then
				trs1 = hand
			elseif hand.Size == Vector3.new(1,1,2) and trs2 == nil then
				trs2 = hand
			end
			if real and (hed == hand or trs1 == hand or trs2 == hand) then
				local realh = real:FindFirstChild("Handle")
				pcall(function()
					realh:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
				end)
			end
		end
	end

	if trs1 then
		trs1:BreakJoints()
		local w = Instance.new("Weld")
		w.Parent = ctrs
		w.Part0 = ctrs
		w.Part1 = trs1
		w.C0 = CFrame.Angles(0,math.rad(90),0)*CFrame.new(0,.5,0)
	end
	if trs2 then
		trs2:BreakJoints()
		local w = Instance.new("Weld")
		w.Parent = ctrs
		w.Part0 = ctrs
		w.Part1 = trs2
		w.C0 = CFrame.Angles(0,math.rad(90),0)*CFrame.new(0,-.5,0)
	end
	if hed then
		hed:BreakJoints()
		local w = Instance.new("Weld")
		w.Parent = clone:FindFirstChild("Head")
		w.Part0 = clone:FindFirstChild("Head")
		w.Part1 = hed
	end
end
if perma == false then
	plr.Character = clone
	char:FindFirstChildWhichIsA("Humanoid").Died:Connect(function()
		resetBindable:Fire()
	end)
	clone:FindFirstChildWhichIsA("Humanoid").Died:Connect(function()
		resetBindable:Fire()
	end)
end
local cam = workspace.CurrentCamera
cam.CameraSubject = clone:FindFirstChildWhichIsA("Humanoid")
for i,v in pairs(clone:GetDescendants()) do
	if v:IsA("BasePart") then
		v.Transparency = .7
	end
end

local root = hum.RootPart
local trs = char:FindFirstChild("Torso")
local flingable = reanimtype == ENUM.REANIMTYPES.PERMADEATH or semibot
local fling = function()

end
if flingable then
	root:ClearAllChildren()
	game:GetService'RunService'.Heartbeat:Connect(function()
		root.Velocity = Vector3.new(0,30.5,0)
		--root:ApplyImpulse(Vector3.new(0,90,0))
		task.wait(.5)
	end)
	rstep(function()
		if semibot and trs then
			trs.CFrame = root.CFrame
		end
	end)
	local flingtype = _G.FlingType or ENUM.FLINGTYPES.BODYTHRUST
	local bp = Instance.new("BodyPosition")
	bp.Parent = root
	bp.MaxForce = Vector3.new(math.huge,math.huge,math.huge)
	bp.D = 999999999999
	bp.P = 9999999999999999
	bp.Position = cloneroot.Position
	if flingtype == ENUM.FLINGTYPES.BODYTHRUST then
		local boy = Instance.new("BodyThrust")
		boy.Parent = root
		boy.Force = Vector3.new(12312,0,1242)
		boy.Location = Vector3.new(0,1244,0)
	end
	Instance.new("SelectionBox",root).Adornee = root
	local dothat = false
	spawn(function()
		hbeat(function()
			if dothat == false then
				bp.Position = cloneroot.Position-Vector3.new(0,1,0)
				if semibot then
					bp.Position = cloneroot.Position-Vector3.new(0,11,0)
					root.Position = cloneroot.Position-Vector3.new(0,11,0)
				else
					bp.Position = cloneroot.Position-Vector3.new(0,1,0)
					root.Position = cloneroot.Position-Vector3.new(0,1,0)
				end

				if flingtype ~= ENUM.FLINGTYPES.BODYTHRUST then
					root.RotVelocity = Vector3.new()
				end
			else
				if flingtype ~= ENUM.FLINGTYPES.BODYTHRUST then
					root.RotVelocity = Vector3.new(100,100,100)
				end
			end
		end)
	end)
	fling = function(who)
		if who == clone or who == char then return end
		task.spawn(function()
			dothat = true

			for i = 1,16 do
				hb:Wait()
				local pos = (who:GetPivot()*CFrame.new(0,-3.25,0)).Position
				bp.Position = pos
				root.Position = pos
			end
			for i = 1,8 do
				hb:Wait()
				local pos = who:GetPivot().Position
				bp.Position = pos
				root.Position = pos
			end
			pcall(function()
				for i = 1,16 do
					hb:Wait()
					local pos = (who:FindFirstChild("HumanoidRootPart") or who:FindFirstChild("Torso")).Position-Vector3.new(0,3.25,0)
					bp.Position = pos
					root.Position = pos
				end
				for i = 1,8 do
					hb:Wait()
					local pos = (who:FindFirstChild("HumanoidRootPart") or who:FindFirstChild("Torso")).Position
					bp.Position = pos
					root.Position = pos
				end
			end)
			dothat = false
		end)
	end
end



return clone,fling,char,hum,clonehum,hbeat,step,rstep,raycast,acs,resetBindable
