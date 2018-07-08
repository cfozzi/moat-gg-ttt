ITEM.Name = "Red Backpack"
ITEM.ID = 584
ITEM.Description = "I wonder what you're carrying inside? Perhaps a secret charm for increased luck.."
ITEM.Rarity = 4
ITEM.Collection = "Urban Style Collection"
ITEM.Skin = 0
ITEM.Model = "models/modified/backpack_1.mdl"
ITEM.Bone = "ValveBiped.Bip01_Spine2"



function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	model:SetSkin( 0 )
	model:SetModelScale(1, 0)
	pos = pos + (ang:Right() * -3) + (ang:Up() * 0) + (ang:Forward() * 0)
	ang:RotateAroundAxis(ang:Up(), 90)
	ang:RotateAroundAxis(ang:Right(), 0)
	ang:RotateAroundAxis(ang:Forward(), 90)
	return model, pos, ang
end