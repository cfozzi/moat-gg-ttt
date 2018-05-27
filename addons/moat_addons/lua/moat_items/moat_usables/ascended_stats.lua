ITEM.Name = "Ascended Stat Mutator"
ITEM.ID = 4006
ITEM.Description = "Using this item allows you to re-roll the stats of any Ascended item"
ITEM.Rarity = 6
ITEM.Collection = "Gamma Collection"
ITEM.Image = "https://moat.gg/assets/img/ascended_stat64.png"
ITEM.ItemCheck = 7
ITEM.ItemUsed = function(pl, slot, item)
	m_ResetStats(pl, slot, item)
    m_SendInvItem(pl, slot)
end