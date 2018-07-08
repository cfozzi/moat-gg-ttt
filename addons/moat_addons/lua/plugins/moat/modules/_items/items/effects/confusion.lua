ITEM.Name = "Confusion Effect"
ITEM.ID = 220
ITEM.Description = "uh ... huh"
ITEM.Rarity = 5
ITEM.Collection = "Effect Collection"
ITEM.Model = "models/effects/vol_light.mdl"
ITEM.Bone = "ValveBiped.Bip01_Head1"



function ITEM:ModifyClientsideModel(ply, model, pos, ang)
	local Size = Vector(0.2000,0.1000,0.0199)
	local mat = Matrix()
	mat:Scale(Size)
	model:EnableMatrix("RenderMultiply", mat)

	model:SetMaterial("models/effects/splodearc_sheet")

	local MAngle = Angle(93.9100,0,266.08999)
	local MPos = Vector(-4.570,-0.219,-0)

	pos = pos + (ang:Forward() * MPos.x) + (ang:Up() * MPos.z) + (ang:Right() * MPos.y)
	ang:RotateAroundAxis(ang:Forward(), MAngle.p)
	ang:RotateAroundAxis(ang:Up(), MAngle.y)
	ang:RotateAroundAxis(ang:Right(), MAngle.r)

	model.ModelDrawingAngle = model.ModelDrawingAngle or Angle(0,0,0)
	model.ModelDrawingAngle.p = (CurTime() * 0 *90)
	model.ModelDrawingAngle.y = (CurTime() * 1.480 *90)
	model.ModelDrawingAngle.r = (CurTime() * 0 *90)

	ang:RotateAroundAxis(ang:Forward(), (model.ModelDrawingAngle.p))
	ang:RotateAroundAxis(ang:Up(), (model.ModelDrawingAngle.y))
	ang:RotateAroundAxis(ang:Right(), (model.ModelDrawingAngle.r))

	return model, pos, ang
end



