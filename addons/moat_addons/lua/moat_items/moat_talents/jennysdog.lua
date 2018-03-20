TALENT.ID = 154
TALENT.Name = "Jenny's Doggo"
TALENT.NameColor = Color(255, 0, 127)
TALENT.Description = "Each hit has a %s_^ chance to overwehlm the target with Jenny's adorable doggo for %s seconds"
TALENT.Tier = 2
TALENT.LevelRequired = {min = 15, max = 20}
TALENT.Modifications = {}
TALENT.Modifications[1] = {min = 5, max = 10} -- percent
TALENT.Modifications[2] = {min = 5, max = 10} -- seconds
TALENT.Melee = false
TALENT.NotUnique = false

function TALENT:OnPlayerHit(victim, attacker, dmginfo, talent_mods )
	if (GetRoundState() ~= ROUND_ACTIVE or victim:HasGodMode()) then return end
	local chance = self.Modifications[1].min + ( ( self.Modifications[1].max - self.Modifications[1].min ) * talent_mods[1] )
	local random_num = math.Rand(1, 100)
	local apply_mod = chance > random_num
	if (apply_mod) then
		local pic_time = self.Modifications[2].min + ( ( self.Modifications[2].max - self.Modifications[2].min ) * talent_mods[2] )

		net.Start("JennyDoggo")
		net.WriteBool(false)
		net.WriteDouble(pic_time)
		net.Send(victim)

		net.Start("JennyDoggo")
		net.WriteBool(true)
		net.Send(attacker)
	end
end