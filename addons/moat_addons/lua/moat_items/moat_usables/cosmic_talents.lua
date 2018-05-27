ITEM.Name = "Cosmic Talent Mutator"
ITEM.ID = 4002
ITEM.Description = "Using this item allows you to re-roll the talents of any Cosmic item. This will reset the item's LVL and XP"
ITEM.Rarity = 7
ITEM.Collection = "Gamma Collection"
ITEM.Image = "https://moat.gg/assets/img/cosmic_talent64.png"
ITEM.ItemCheck = 2
ITEM.ItemUsed = function(pl, slot, item)
	m_ResetTalents(pl, slot, item)
    m_SendInvItem(pl, slot)
end