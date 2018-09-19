surface.CreateFont("moat_Trebuchet24", {
    font = "Trebuchet24",
    size = 24,
    weight = 800
})

local MOAT_SHOP = {}
net.Start("MOAT_GET_SHOP")
net.SendToServer()
local LIMITEDS = 0
net.Receive("MOAT_GET_SHOP", function(len)
    local tbl = net.ReadTable()
    table.insert(MOAT_SHOP, tbl)
    if (tbl.LimitedShop or 0) > os.time() then
        LIMITEDS = LIMITEDS + 1
    end
end)

timer.Create("LimitedShopChat",10,0,function()
    if MOAT_SHOP[1] then
        timer.Remove("LimitedShopChat")
        if LIMITEDS > 1 then
            chat.AddText(Material("icon16/information.png"),Color(255,255,255),"Welcome back, there are currently ",Color(255,255,0),tostring(LIMITEDS)," LIMITED TIME ITEMS",Color(255,255,255)," in the shop!")
        elseif LIMITEDS == 1 then
            chat.AddText(Material("icon16/information.png"),Color(255,255,255),"Welcome back, there's currently ",Color(255,255,0),tostring(LIMITEDS)," LIMITED TIME ITEM",Color(255,255,255)," in the shop!")
        end
    end
end)

local item_panel_w = 169
local item_panel_h = 220
local image_y_off = 5

function m_CreateBuyConfirmation(itemtbl, amount)
    local price = string.Comma(itemtbl.Price * amount)
    local BUY_MENU = DermaMenu()
    BUY_MENU:SetPos(gui.MouseX(), gui.MouseY())
    BUY_MENU:MakePopup()
    BUY_MENU:AddOption("Purchase " .. amount .. " for " .. price .. " IC?"):SetIcon("icon16/coins_delete.png")
    BUY_MENU:AddSpacer()

    BUY_MENU:AddOption("Accept", function()
        net.Start("MOAT_BUY_ITEM")
        net.WriteDouble(itemtbl.ID)
        net.WriteUInt(amount, 8)
        net.SendToServer()

        if (amount > 1 and amount * itemtbl.Price <= MOAT_INVENTORY_CREDITS) then
            MOAT_INV_BG:Remove()
            moat_inv_cooldown = CurTime() + 3
            m_ClearInventory()
            net.Start("MOAT_SEND_INV_ITEM")
            net.SendToServer()
        end
    end):SetIcon("icon16/tick.png")

    BUY_MENU:AddOption("Cancel", function() end):SetIcon("icon16/cross.png")
    -- nothing
end

local moat_crate_previews = {}

function m_PreviewCrate(item_tbl)
    if (not IsValid(MOAT_INV_BG)) then return end
    
    local tbl = {}
    tbl.item = item_tbl
    
    m_InitCrateWindow(tbl, 0, 0, true)
end

net.Receive("MOAT_CRATE_PREVIEW", function()
    local tbl = net.ReadTable()

    moat_crate_previews[tbl.ID] = tbl

    m_PreviewCrate(tbl)
end)

local mat_coins = Material("icon16/coins.png")
local mat_support = Material("icon16/heart.png")
local cur_cat = 0
local cat_lbl = "Shop Overview"
function m_BuildShop(pnl, pnl_w, pnl_h)

    pnl.Paint = function(s, w, h)
        draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))
        surface.SetDrawColor(62, 62, 64, 255)
        surface.DrawOutlinedRect(0, 0, w, h)
    end
    m_PopulateShop(pnl)
end

local lbls = {"Crates", "Usables", "Support Shop", "Get Support Credits"}

function moat_shop_change_pnl(num)
    local anim_time = 0.15

    if (num == 0) then
        cat_lbl = "Shop Overview"
        M_SHOP_HOME:MoveTo(0, 27, anim_time, anim_time)
        M_SHOP_HOME:AlphaTo(255, anim_time, anim_time)
    else
        M_SHOP_HOME:MoveTo(-M_SHOP_HOME:GetWide(), 27, anim_time, 0)
        M_SHOP_HOME:AlphaTo(0, anim_time)
    end

    if (num == 1) then
        cat_lbl = lbls[1]
        M_SHOP_SCROLL1:MoveTo(0, 27, anim_time, anim_time)
        M_SHOP_HOME:AlphaTo(255, anim_time, anim_time)
    else
        M_SHOP_SCROLL1:MoveTo(-M_SHOP_SCROLL1:GetWide(), 27, anim_time, 0)
        M_SHOP_HOME:AlphaTo(0, anim_time)
    end

    if (num == 2) then
        cat_lbl = lbls[2]
        M_SHOP_SCROLL2:MoveTo(0, 27, anim_time, anim_time)
        M_SHOP_HOME:AlphaTo(255, anim_time, anim_time)
    else
        M_SHOP_SCROLL2:MoveTo(-M_SHOP_SCROLL2:GetWide(), 27, anim_time, 0)
        M_SHOP_HOME:AlphaTo(0, anim_time)
    end

    if (num == 3) then
        cat_lbl = lbls[3]
        M_SHOP_SCROLL3:MoveTo(0, 27, anim_time, anim_time)
        M_SHOP_HOME:AlphaTo(255, anim_time, anim_time)
    else
        M_SHOP_SCROLL3:MoveTo(-M_SHOP_SCROLL3:GetWide(), 27, anim_time, 0)
        M_SHOP_HOME:AlphaTo(0, anim_time)
    end

    if (num == 4) then
        cat_lbl = lbls[4]
        M_SHOP_SCROLL4:MoveTo(0, 27, anim_time, anim_time)
        M_SHOP_HOME:AlphaTo(255, anim_time, anim_time)
    else
        M_SHOP_SCROLL4:MoveTo(-M_SHOP_SCROLL4:GetWide(), 27, anim_time, 0)
        M_SHOP_HOME:AlphaTo(0, anim_time)
    end

    cur_cat = num
end
function m_PopulateHomeShop(pnl)
    for i = 1, #lbls do
        local btnx, btny = (pnl:GetWide()/2) - 125, ((50 + 10) * i) + 150
        local btn = vgui.Create("DButton", pnl)
        btn:SetSize(250, 50)
        btn:SetPos(btnx, btny)
        btn:SetText("")
        btn.LerpNum = 0
        btn.DoClick = function()
            moat_shop_change_pnl(i)
        end
        btn.Paint = function(s, w, h)
            if (s:IsHovered()) then
                s.LerpNum = Lerp(FrameTime() * 8, s.LerpNum, 1)
            else
                s.LerpNum = Lerp(FrameTime() * 8, s.LerpNum, 0)
            end

            surface.SetDrawColor(51 * s.LerpNum, 153 * s.LerpNum, 255 * s.LerpNum, 150 + (50 * s.LerpNum))
            surface.DrawRect(0, 0, w, h)

            surface.SetDrawColor(62, 62, 64, 255)
            surface.DrawOutlinedRect(0, 0, w, h)

            draw.SimpleTextOutlined(lbls[i], "moat_Trebuchet", w/2, (h/2) - 2, Color(pnl.Theme.TextColor), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 1, Color( 0, 0, 0, 25 ))
        end
    end
end

local droppable_cache_count, droppable_cache = 0, {}
local function GetDroppableWeapons()
    if (droppable_cache[1]) then return droppable_cache, droppable_cache_count end

    for k, v in ipairs(weapons.GetList()) do
        if (v.AutoSpawnable and v.Base == "weapon_tttbase") then
            droppable_cache_count = droppable_cache_count + 1

            droppable_cache[droppable_cache_count] = {
                ClassName = v.ClassName,
                WeaponTable = weapons.Get(v.ClassName)
            }
        end
    end

    return droppable_cache, droppable_cache_count
end

function make_modelpanel(itemtbl,ITEM_BG)
    local m_WClass = {} 
    if (itemtbl.Image) then
        m_WClass.WorldModel = itemtbl.Image
    elseif (itemtbl.Model) then
        m_WClass.WorldModel = itemtbl.Model
        m_WClass.ModelSkin = itemtbl.Skin
    elseif (itemtbl.Kind == "tier") then
        m_WClass = table.Random(GetDroppableWeapons()).WeaponTable
    else
        m_WClass = weapons.Get(itemtbl.WeaponClass)
    end
    

    local m_DPanelIcon = {}
    m_DPanelIcon.SIcon = vgui.Create("MoatModelIcon", ITEM_BG)
    m_DPanelIcon.SIcon:SetPos(52.5, 58)
    m_DPanelIcon.SIcon:SetSize(64, 64)
    m_DPanelIcon.SIcon:SetTooltip(nil)

    m_DPanelIcon.SIcon.Think = function(s)
        s:SetTooltip(nil)
    end

    m_DPanelIcon.SIcon:SetVisible(false)

    if (m_WClass) then
        if (not string.EndsWith(tostring(m_WClass.WorldModel), ".mdl")) then
            if (not IsValid(m_DPanelIcon.SIcon.Icon)) then m_DPanelIcon.SIcon:CreateIcon(n) end
            m_DPanelIcon.SIcon.Icon:SetAlpha(0)
        end

        m_DPanelIcon.SIcon:SetModel(m_WClass.WorldModel, m_WClass.ModelSkin)
        m_DPanelIcon.SIcon:SetVisible(true)
    end

    m_DPanelIcon.WModel = nil
    m_DPanelIcon.Item = nil
    m_DPanelIcon.MSkin = nil

    if (m_WClass) then
        m_DPanelIcon.WModel = m_WClass.WorldModel
        m_DPanelIcon.Item = itemtbl
        if (m_WClass.ModelSkin) then
            m_DPanelIcon.MSkin = m_WClass.ModelSkin
        end
    end

    m_DPanelIcon.SIcon.PaintOver = function(s, w, h)
        if (not string.EndsWith(m_DPanelIcon.WModel, ".mdl")) then
            s.Icon:SetAlpha(0)
            if (m_DPanelIcon.WModel:StartWith("https")) then
                draw.WebImage(m_DPanelIcon.WModel, 0, 0, w, h, {r = 255, g = 255, b = 255, a = 255})
            else
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(Material(m_DPanelIcon.WModel))
                surface.DrawTexturedRect(0, 0, w, h)
            end
        else
            s.Icon:SetAlpha(255)
        end
    end
    return m_DPanelIcon.SIcon
end

local circ_gradient = "https://i.moat.gg/8WkHz.png"

function m_PopulateShop(pnl)
    local M_SHOP_LIST = vgui.Create("DIconLayout", pnl)
    M_SHOP_LIST:SetPos(5, 5)
    M_SHOP_LIST:SetSize(pnl:GetWide() - 20, pnl:GetTall() - 20)
    M_SHOP_LIST:SetSpaceX(5)
    M_SHOP_LIST:SetSpaceY(5)

    function m_AddShopItem(itemtbl)
        local name_col = itemtbl.NameColor or rarity_names[itemtbl.Rarity][2]
        if itemtbl.LimitedShop then name_col = Color(255, 128, 0) end
        local item_name = string.Explode(" ", itemtbl.Name)
        if (item_name[1] == "Urban") then item_name[1] = "Urban Style" end
        local item_price = "IC: " .. string.Comma(itemtbl.Price)
        surface.SetFont("moat_ItemDesc")
        local price_width, price_height = surface.GetTextSize(item_price)
        local ITEM_BG = M_SHOP_LIST:Add("DPanel")
        ITEM_BG:SetSize(item_panel_w, item_panel_h)
        ITEM_BG.Qty = 1
        if itemtbl.LimitedShop then
            if itemtbl.ShopDesc then
                ITEM_BG:SetTooltip(itemtbl.ShopDesc)
            end
            itemtbl.Preview = false
            local id = tostring(ITEM_BG) .. math.random()
            timer.Create(id,5,0,function()
                if not IsValid(ITEM_BG) then
                    timer.Remove(id)
                    return
                end
                ITEM_BG.Sweet = (not ITEM_BG.Sweet)
                if itemtbl.Kind == "tier" then
                    ITEM_BG.Modelk:Remove()
                    ITEM_BG.Modelk = make_modelpanel(itemtbl,ITEM_BG)
                end
            end)
            ITEM_BG.Modelk = make_modelpanel(itemtbl,ITEM_BG)
        end
        local checked_hover = false
        ITEM_BG.Paint = function(s, w, h)
            if itemtbl.LimitedShop then
                if s:IsHovered() and (not checked_hover) then
                    checked_hover = true
                    if (itemtbl.ShopDesc) then
                        Derma_Message(itemtbl.ShopDesc, "Limited time item: " .. itemtbl.Name, "Got it, thanks!")
                    end
                end
                if itemtbl.LimitedShop < os.time() then
                    ITEM_BG:Remove()
                    M_SHOP_LIST:InvalidateLayout()
                    return
                end
            end
            draw.RoundedBox(0, 0, 0, w, h, name_col)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))

            surface.SetMaterial(fetch_asset(circ_gradient))
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(1, 1, w-2, h-2)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRect(1, 1, w-2, h-2)

            /*
            draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(50, 50, 50, 200))
            surface.SetDrawColor(62, 62, 64, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(62, 62, 64, 150)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(10, 10, 10, 150)
            surface.SetMaterial(Material("vgui/gradient-d"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)
            surface.SetDrawColor(150, 150, 150, 30)
            surface.SetMaterial(Material("vgui/gradient-u"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)*/

            if (itemtbl.CrateShopOverride or itemtbl.LimitedShop) then
                if (itemtbl.CrateShopOverride == "50/50") then
                    m_DrawEnchantedText(itemtbl.CrateShopOverride, "moat_Trebuchet24", (w / 2) - 35, 5, name_col, Color(0, 0, 255))
                    m_DrawEnchantedText("Crate", "moat_Trebuchet24", (w / 2) - 29, 25, name_col, Color(0, 0, 255))
                elseif (itemtbl.CrateShopOverride == "Gift") then
                    m_DrawShadowedText(1, "Empty Gift", "moat_Medium5", w / 2, 5, name_col, TEXT_ALIGN_CENTER)
                    m_DrawShadowedText(1, "Package", "moat_Medium5", w / 2, 25, name_col, TEXT_ALIGN_CENTER)
                elseif (itemtbl.LimitedShop) then
                    if (itemtbl.Kind == "tier") then
                        m_DrawShadowedText(1, itemtbl.Name .. " Weapon", "moat_Medium5", w / 2, 5, name_col, TEXT_ALIGN_CENTER)
                    else
                        m_DrawShadowedText(1, itemtbl.Name, "moat_Medium5", w / 2, 5, name_col, TEXT_ALIGN_CENTER)
                    end
                    surface.SetFont("moat_ItemDescLarge3")
                    local ss = "Limited Time!"
                    if not s.Sweet then 
                        surface.SetFont("moat_ItemDescLarge3")
                        local tw = surface.GetTextSize(ss)
                        DrawShadowedText(1, ss, "moat_ItemDescLarge3", (w/2) - (tw/2), 25, Color(0, 0, 0))
                        DrawEnchantedText(1, ss, "moat_ItemDescLarge3", (w/2) - (tw/2), 25, name_col, Color(255,0,0))
                    else
                        local time = os.date("!*t", (itemtbl.LimitedShop - os.time()))
                        local h,m,sec = time.hour,time.min,time.sec
                        local days = time.day - 1
                        if days > 0 then
                            h = h + (days * 24)
                        end
                        if (#tostring(h)) == 1 then h = "0" .. h end
                        if (#tostring(m)) == 1 then m = "0" .. m end
                        if (#tostring(sec)) == 1 then sec = "0" .. sec end
                        ss = D3A.FormatTimeSingle(itemtbl.LimitedShop - os.time()) .. " left!" --h .. ":" .. m .. ":" .. sec .. " left!"
                        local tw = surface.GetTextSize(ss)
                        DrawShadowedText(1, ss, "moat_ItemDescLarge3", (w/2) - (tw/2), 25, Color(0, 0, 0))
                        DrawEnchantedText(5, ss, "moat_ItemDescLarge3", (w/2) - (tw/2), 25, name_col, Color(255,0,0))
                    end
                else
                    m_DrawEnchantedText(itemtbl.CrateShopOverride, "moat_Trebuchet24", w / 2, 5, name_col, Color(255, 0, 255))
                    m_DrawEnchantedText("Crate", "moat_Trebuchet24", w / 2, 25, name_col, Color(255, 0, 255))
                end
            else
                m_DrawShadowedText(1, item_name[1], "moat_Trebuchet24", w / 2, 5, name_col, TEXT_ALIGN_CENTER)
                m_DrawShadowedText(1, "Crate", "moat_Trebuchet24", w / 2, 25, name_col, TEXT_ALIGN_CENTER)
            end

            if itemtbl.Image then
                local img = Material(itemtbl.Image)
                if (itemtbl.Image:StartWith("https")) then img = fetch_asset(itemtbl.Image) end
                surface.SetDrawColor(0, 0, 0, 100)
                surface.SetMaterial(img)
                surface.DrawTexturedRect((w / 2) - 35, ((h - 50) / 2) - 35 + image_y_off, 70, 70)
                surface.SetDrawColor(255, 255, 255, 255)
                surface.SetMaterial(img)
                surface.DrawTexturedRect((w / 2) - 32, ((h - 50) / 2) - 32 + image_y_off, 64, 64)
            end
            m_DrawShadowedText(1, item_price, "moat_ItemDesc", (w / 2) + 8, h - 85, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            surface.SetMaterial(Material("icon16/coins_delete.png"))
            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawTexturedRect((w / 2) - (price_width / 2) - 21 + 8, h - 85, 16, 16)

            m_DrawShadowedText(1, "Amount: " .. s.Qty, "moat_ItemDesc", (w / 2), h - 60, (itemtbl.Price * s.Qty <= MOAT_INVENTORY_CREDITS) and Color(255, 255, 255) or Color(255, 0, 0), TEXT_ALIGN_CENTER)
        end
        ITEM_BG.PaintOver = function(s, w, h) end

        if (itemtbl.Preview == nil or itemtbl.Preview) then
            local ITEM_PREVIEW = vgui.Create("DButton", ITEM_BG)
            ITEM_PREVIEW:SetSize(70, 70)
            ITEM_PREVIEW:SetPos(49, 50)
            ITEM_PREVIEW:SetText("")
            ITEM_PREVIEW:SetTooltip("Preview Crate")
            ITEM_PREVIEW.Paint = nil
            ITEM_PREVIEW.DoClick = function(s)
               if (moat_crate_previews[itemtbl.ID]) then 
                    m_PreviewCrate(moat_crate_previews[itemtbl.ID])
                    return
                end
                net.Start("MOAT_CRATE_PREVIEW")
                net.WriteUInt(itemtbl.ID, 32)
                net.SendToServer()
            end
        end

        local ITEM_BUY_INC = vgui.Create("DButton", ITEM_BG)
        ITEM_BUY_INC:SetSize(20, 20)
        ITEM_BUY_INC:SetPos(item_panel_w-30, item_panel_h - 63)
        ITEM_BUY_INC:SetText("")
        ITEM_BUY_INC.Paint = function(s, w, h)
            m_DrawShadowedText(1, ">", "moat_ItemDesc", w/2, h/2, s:IsHovered() and Color(0, 255, 0) or Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        ITEM_BUY_INC.DoClick = function(s)
            local num = input.IsKeyDown(KEY_LSHIFT) and 10 or 1
            ITEM_BG.Qty = math.Clamp(ITEM_BG.Qty + num, 1, 50)
            if (GetConVar("moat_enable_uisounds"):GetInt() > 0) then LocalPlayer():EmitSound("moatsounds/pop1.wav") end
        end

        local ITEM_BUY_DEC = vgui.Create("DButton", ITEM_BG)
        ITEM_BUY_DEC:SetSize(20, 20)
        ITEM_BUY_DEC:SetPos(10, item_panel_h - 63)
        ITEM_BUY_DEC:SetText("")
        ITEM_BUY_DEC.Paint = function(s, w, h)
            m_DrawShadowedText(1, "<", "moat_ItemDesc", w/2, h/2, s:IsHovered() and Color(255, 0, 0) or Color(255, 255, 255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end
        ITEM_BUY_DEC.DoClick = function(s)
            local num = input.IsKeyDown(KEY_LSHIFT) and 10 or 1
            ITEM_BG.Qty = math.Clamp(ITEM_BG.Qty - num, 1, 50)
            if (GetConVar("moat_enable_uisounds"):GetInt() > 0) then LocalPlayer():EmitSound("moatsounds/pop1.wav") end
        end

        local ITEM_BUY = vgui.Create("DButton", ITEM_BG)
        ITEM_BUY:SetSize(149, 30)
        ITEM_BUY:SetPos(10, ITEM_BG:GetTall() - 40)
        ITEM_BUY:SetText("")
        local hover_coloral = 0
        ITEM_BUY.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            surface.SetDrawColor(50, 50, 50, 100)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(0, 200, 0, 20 + hover_coloral / 5)
            surface.DrawRect(1, 1, w - 2, h - 2)
            surface.SetDrawColor(0, 255, 0, 20 + hover_coloral / 5)
            surface.SetMaterial(Material("vgui/gradient-d"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)
            m_DrawShadowedText(1, "Purchase", "Trebuchet24", w / 2, h / 2, Color(100, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local btn_hovered = 1
        local btn_color_a = false

        ITEM_BUY.Think = function(s)
            if (not s:IsHovered()) then
                btn_hovered = 0
                btn_color_a = false

                if (hover_coloral > 0) then
                    hover_coloral = Lerp(2 * FrameTime(), hover_coloral, 0)
                end
            else
                if (hover_coloral < 154 and btn_hovered == 0) then
                    hover_coloral = Lerp(5 * FrameTime(), hover_coloral, 155)
                else
                    btn_hovered = 1
                end

                if (btn_hovered == 1) then
                    if (btn_color_a) then
                        if (hover_coloral >= 154) then
                            btn_color_a = false
                        else
                            hover_coloral = hover_coloral + (100 * FrameTime())
                        end
                    else
                        if (hover_coloral <= 50) then
                            btn_color_a = true
                        else
                            hover_coloral = hover_coloral - (100 * FrameTime())
                        end
                    end
                end
            end
        end

        ITEM_BUY.OnCursorEntered = function() if (GetConVar("moat_enable_uisounds"):GetInt() > 0) then LocalPlayer():EmitSound("moatsounds/pop2.wav") end end

        ITEM_BUY.DoClick = function()
            m_CreateBuyConfirmation(itemtbl, ITEM_BG.Qty)

            if (GetConVar("moat_enable_uisounds"):GetInt() > 0) then LocalPlayer():EmitSound("moatsounds/pop1.wav") end
        end
    end

	table.sort(MOAT_SHOP, function(a, b)
        return a.ID > b.ID
    end)

    table.sort(MOAT_SHOP, function(a, b)
        return a.Rarity < b.Rarity
    end)

    for i = 1, #MOAT_SHOP do
		if MOAT_SHOP[i].LimitedShop then
            m_AddShopItem(MOAT_SHOP[i]) -- Always at top 
        end
	end

    for i = 1, #MOAT_SHOP do
        if MOAT_SHOP[i].LimitedShop then continue end
		m_AddShopItem(MOAT_SHOP[i])
	end

    local function m_AddShopItemCommand(name, name2, color, price, img, item_cmd)
        local name_col = color
        local item_name = {name, name2}
        local item_price = "IC: " .. string.Comma(price)
        surface.SetFont("moat_ItemDesc")
        local price_width, price_height = surface.GetTextSize(item_price)
        local ITEM_BG = M_SHOP_LIST:Add("DPanel")
        ITEM_BG:SetSize(item_panel_w, item_panel_h)
        ITEM_BG.Qty = 1
        ITEM_BG.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, name_col)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 100))

            surface.SetMaterial(fetch_asset(circ_gradient))
            surface.SetDrawColor(0, 0, 0, 150)
            surface.DrawRect(1, 1, w-2, h-2)
            surface.SetDrawColor(0, 0, 0, 255)
            surface.DrawTexturedRect(1, 1, w-2, h-2)

            /*draw.RoundedBox(0, 1, 1, w - 2, h - 2, Color(50, 50, 50, 200))
            surface.SetDrawColor(62, 62, 64, 255)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(62, 62, 64, 150)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(10, 10, 10, 150)
            surface.SetMaterial(Material("vgui/gradient-d"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)
            surface.SetDrawColor(150, 150, 150, 30)
            surface.SetMaterial(Material("vgui/gradient-u"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)*/

            m_DrawShadowedText(1, item_name[1], "moat_Trebuchet24", w / 2, 5, name_col, TEXT_ALIGN_CENTER)
            m_DrawShadowedText(1, item_name[2], "moat_Trebuchet24", w / 2, 25, name_col, TEXT_ALIGN_CENTER)

            local imgs = Material(img)
            if (img:StartWith("https")) then imgs = fetch_asset(img) end

            surface.SetDrawColor(0, 0, 0, 100)
            surface.SetMaterial(imgs)
            surface.DrawTexturedRect((w / 2) - 35, ((h - 50) / 2) - 35 + image_y_off, 70, 70)
            surface.SetDrawColor(255, 255, 255, 255)
            surface.SetMaterial(imgs)
            surface.DrawTexturedRect((w / 2) - 32, ((h - 50) / 2) - 32 + image_y_off, 64, 64)
            m_DrawShadowedText(1, item_price, "moat_ItemDesc", (w / 2) + 8, h - 85, Color(255, 255, 255), TEXT_ALIGN_CENTER)
            surface.SetMaterial(Material("icon16/coins_delete.png"))
            surface.SetDrawColor(Color(255, 255, 255))
            surface.DrawTexturedRect((w / 2) - (price_width / 2) - 21 + 8, h - 85, 16, 16)

            m_DrawShadowedText(1, "Amount: " .. s.Qty, "moat_ItemDesc", (w / 2), h - 60, (price * s.Qty <= MOAT_INVENTORY_CREDITS) and Color(255, 255, 255) or Color(255, 0, 0), TEXT_ALIGN_CENTER)
        end

        ITEM_BG.PaintOver = function(s, w, h) end

        local ITEM_BUY = vgui.Create("DButton", ITEM_BG)
        ITEM_BUY:SetSize(149, 30)
        ITEM_BUY:SetPos(10, ITEM_BG:GetTall() - 40)
        ITEM_BUY:SetText("")
        local hover_coloral = 0
        ITEM_BUY.Paint = function(s, w, h)
            draw.RoundedBox(0, 0, 0, w, h, Color(0, 0, 0, 150))
            surface.SetDrawColor(50, 50, 50, 100)
            surface.DrawOutlinedRect(0, 0, w, h)
            surface.SetDrawColor(0, 200, 0, 20 + hover_coloral / 5)
            surface.DrawRect(1, 1, w - 2, h - 2)
            surface.SetDrawColor(0, 255, 0, 20 + hover_coloral / 5)
            surface.SetMaterial(Material("vgui/gradient-d"))
            surface.DrawTexturedRect(1, 1, w - 2, h - 2)
            m_DrawShadowedText(1, "Purchase", "Trebuchet24", w / 2, h / 2, Color(100, 200, 100), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
        end

        local btn_hovered = 1
        local btn_color_a = false

        ITEM_BUY.Think = function(s)
            if (not s:IsHovered()) then
                btn_hovered = 0
                btn_color_a = false

                if (hover_coloral > 0) then
                    hover_coloral = Lerp(2 * FrameTime(), hover_coloral, 0)
                end
            else
                if (hover_coloral < 154 and btn_hovered == 0) then
                    hover_coloral = Lerp(5 * FrameTime(), hover_coloral, 155)
                else
                    btn_hovered = 1
                end

                if (btn_hovered == 1) then
                    if (btn_color_a) then
                        if (hover_coloral >= 154) then
                            btn_color_a = false
                        else
                            hover_coloral = hover_coloral + (100 * FrameTime())
                        end
                    else
                        if (hover_coloral <= 50) then
                            btn_color_a = true
                        else
                            hover_coloral = hover_coloral - (100 * FrameTime())
                        end
                    end
                end
            end
        end

        ITEM_BUY.DoClick = function()
            if (price * ITEM_BG.Qty > MOAT_INVENTORY_CREDITS) then
                chat.AddText(Material("icon16/information.png"), Color(255, 0, 0), "You can't afford that item!")

                return
            end
            MOAT_INV_BG:Remove()
            
            RunConsoleCommand(item_cmd)

            if (GetConVar("moat_enable_uisounds"):GetInt() > 0) then LocalPlayer():EmitSound("moatsounds/pop1.wav") end
        end
    end
    m_AddShopItemCommand("Self Title", "Change", Color(255, 205, 0), 15000, "icon16/tag_yellow.png", "moat_selftitles")
    m_AddShopItemCommand("Other's Title", "Change", Color(0, 255, 0), 50000, "icon16/tag_pink.png", "moat_titles")
    m_AddShopItemCommand("Send a TTS", "Message", Color(255, 0, 0), 100, "icon16/music.png", "moat_ttsmenu")

    local EndSpacing = M_SHOP_LIST:Add("DPanel")
    EndSpacing:SetSize(169, 0)
    EndSpacing.Paint = nil

    local EndSpacing = M_SHOP_LIST:Add("DPanel")
    EndSpacing:SetSize(169, 0)
    EndSpacing.Paint = nil
    -- OCD fuck
end