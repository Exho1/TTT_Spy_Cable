if SERVER then
    AddCSLuaFile() 
end

if CLIENT then
    SWEP.PrintName = "Spy Cable"
    SWEP.Slot = 7
    SWEP.DrawAmmo = true
    SWEP.DrawCrosshair = false
       
    SWEP.Icon = "vgui/ttt/icon_rock"
 
	SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "f"
   };
end
 
SWEP.HoldType            = "normal"
SWEP.Base                = "weapon_tttbase"
SWEP.Kind                = WEAPON_EQUIP
SWEP.CanBuy              = { ROLE_TRAITOR }

SWEP.Primary.Ammo        = "none"
SWEP.Primary.Delay       = 1
SWEP.Secondary.Delay     = 1
SWEP.Primary.ClipSize    = -1
SWEP.Primary.ClipMax     = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic   = false
SWEP.AllowDrop			 = false

SWEP.Spawnable           = true
SWEP.AdminSpawnable      = true
SWEP.AutoSpawnable       = false
SWEP.ViewModel           = "models/weapons/v_pistol.mdl"
SWEP.WorldModel          = "models/weapons/w_crowbar.mdl"
SWEP.ViewModelFlip       = false
SWEP.LimitedUse 		 = true

SWEP.IsLooking = false
SWEP.Door = nil
SWEP.FootPos = nil

local function IsDoor(ent) -- Check if the entity is a door, function from Destructible Doors
	if not IsValid(ent) then return false end
	local doors = {"func_door", "func_door_rotating", "prop_door", "prop_door_rotating",}

	for k,v in pairs(doors) do
		if ent:GetClass() == v then
			return true
		end
	end
	return false
end

function SWEP:PrimaryAttack()
	local ply = self.Owner
	
	--if not self:CanPrimaryAttack() then return end
    self:SetNextPrimaryFire(CurTime()+self.Primary.Delay)
    self:SetNextSecondaryFire(CurTime()+self.Secondary.Delay)
       
    local pos = self.Owner:GetShootPos()
    local ang = self.Owner:GetAimVector()
    local tracedata = {}
    tracedata.start = pos
    tracedata.endpos = pos+(ang*100)
    tracedata.filter = self.Owner
    local trace = util.TraceLine(tracedata)
       
    local door = trace.Entity
	
	if IsDoor(door) then
		print("Door")
		self.IsLooking = true
		self.Door = door
		self.FootPos = ply:GetPos()
	end
end

function SWEP:SecondaryAttack()
	self.IsLooking = false
	self.Door = nil
end

function SWEP:Reload()

end

function SWEP:DrawHUD()
	local ply = self.Owner
	if not self.IsLooking then return end
	
	local EyeAng = ply:EyeAngles()
	-- pitch/x, roll/y, yaw/z
	
	EyeAng.x = math.Clamp(EyeAng.x, -30, 24)
	--EyeAng.y = math.Clamp(EyeAng.y, 80, -80)
	print(EyeAng)
	
	-- To Do: Find a good way of finding the current direction, rounding it to 90, 180, -90, or 0, and clamping the view based off that.
	-- Fix the door position not be centered on a certain axies
	
	local CamData = {}
	
	CamData.angles = Angle(EyeAng.x, EyeAng.y, 0) -- Angles, supposed to be clamped
	local footpos = self.FootPos -- Declared once because jumping
	local doorpos = self.Door:GetPos() + self.Door:OBBCenter()
	-- This^ doesnt work if the door is facing broadside toward either 90 or -90 Eye Angle
	
	CamData.origin = Vector(doorpos.x, doorpos.y, footpos.z + 15) -- Position, supposed to be the at the center and forward 10 
	
	CamData.x = 0
	CamData.y = 0
	CamData.w = ScrW() -- Takes up the entire screen, for now..
	CamData.h = ScrH() 
	render.RenderView( CamData )
end


