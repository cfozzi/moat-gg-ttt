ITEM.Name = "Brown Raybands"
ITEM.ID = 519
ITEM.Description = "Disclaimer: These do not make you any cooler"
ITEM.Rarity = 1
ITEM.Collection = "Urban Style Collection"
ITEM.Skin = 4
ITEM.Model = "models/modified/glasses02.mdl"
ITEM.Attachment = "eyes"



function ITEM:ModifyClientsideModel(ply, model, pos, ang)

	model:SetSkin( 4 )
	if (moat_TerroristModels[ply:GetModel()]) then

		model:SetModelScale( 1.15, 0 )
		pos = pos + (ang:Forward() * -4.110229) + (ang:Right() * 0) +  (ang:Up() * 1)

	else

		pos = pos + (ang:Forward() * -3.7)
		ang:RotateAroundAxis(ang:Up(), 0)

	end
	
	return model, pos, ang
end