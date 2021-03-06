TALENT.ID = 614
TALENT.Suffix = "the GELADO"
TALENT.Name = "Ice Cream"
TALENT.NameEffect = "enchanted"
TALENT.NameColor = Color(103,182,255)
TALENT.NameEffectMods = {Color(255,141,170)}
TALENT.Description = "Each shot has a %s_^ chance to shoot an ice cream tub projectile dealing %s damage"
TALENT.Tier = 2
TALENT.LevelRequired = {min = 15, max = 20}
TALENT.Modifications = {}
TALENT.Modifications[1] = {min = 5, max = 20}
TALENT.Modifications[2] = {min = 15, max = 45}
TALENT.Melee = false
TALENT.NotUnique = true

function TALENT:OnWeaponFired(attacker, wep, dmginfo, talent_mods, is_bow, hit_pos)
    -- if (GetRoundState() ~= ROUND_ACTIVE) then return end

	local num = (wep.Primary and wep.Primary.NumShots) and wep.Primary.NumShots or 1
    local chance = self.Modifications[1].min + ((self.Modifications[1].max - self.Modifications[1].min) * math.min(1, talent_mods[1]))
    if (chance > math.random() * (100 * num)) then
        local ply = dmginfo.Attacker
        if (not IsValid(ply)) then return end

    	local dmg = self.Modifications[2].min + ((self.Modifications[2].max - self.Modifications[2].min) * math.min(1, talent_mods[2]))
        local Front = ply:GetAimVector()
        local Up = ply:EyeAngles():Up()
        local aimang = Front:Angle()
		local bulspread = vector_origin
		local conex = wep:GetPrimaryCone() or 0.01
		local coney = wep:GetPrimaryConeY() or conex
		local mult = Vector(coney, conex)
        local nlayers = ((wep.Primary and wep.Primary.LayerMults) and #wep.Primary.LayerMults or 1) + 3
        local class = wep:GetClass()

		if (wep.propshot and #wep.propshot > num) then
			for k, v in ipairs(wep.propshot) do
				if (IsValid(v)) then v:Remove() end
			end

			wep.propshot = {}
		end

		for i = 1, num do
        	local x, y = util.SharedRandom(class, -nlayers * 50, nlayers * 50, i) * conex / nlayers, util.SharedRandom(class, -nlayers * 50, nlayers * 50, i + 1) * coney / nlayers
       	 	local rspr = aimang:Right() * x + aimang:Up() * y
    		local dir = Front + rspr + bulspread.x * mult.x * aimang:Right() + bulspread.y * mult.y * aimang:Up()

			local ball = ents.Create "ent_propshot_icecream"
			if IsValid(ball) then
				ball:SetTrailColor(Vector(237/255, 28/255, 36/255))
				ball:SetPos(ply:GetShootPos() + dir * 10 + Up * 10 * -1)
				ball:SetAngles(Front:Angle())
				ball.Harmless = false
				ball.Damage = dmg
				ball:Spawn()
				ball:Activate()
				ball:SetOwner(ply)

				local Physics = ball:GetPhysicsObject()
				if IsValid(Physics) then
					Physics:ApplyForceCenter(Front:Angle():Forward() * 25000)
				end

				if (not wep.propshot) then wep.propshot = {} end
				table.insert(wep.propshot, ball)
			end
		end
    end
end