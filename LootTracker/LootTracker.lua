local LootTrackerOptions_DefaultSettings = {
	enabled = false,
	uncommon = false,
	common = false,
	rare = false,
	epic = true,
	legendary = true,
	timestamp = false,
	cost = false,
}

local LootTrackerBlacklist_DefaultSettings = {
		"Nexus Crystal"
	}


---------------------------------------------------------
--LootTracker Global Functions
---------------------------------------------------------

local function LootTracker_Initialize()
	if not LootTrackerOptions  then
		LootTrackerOptions = {}
	end

	for i in LootTrackerOptions_DefaultSettings do
		if (LootTrackerOptions[i] == nil) then
			LootTrackerOptions[i] = LootTrackerOptions_DefaultSettings[i]
		end
	end
	
	if not LootTrackerBlacklist  then
		LootTrackerBlacklist = {}
	end

	for i in LootTrackerBlacklist_DefaultSettings do
		if (LootTrackerBlacklist[i] == nil) then
			LootTrackerBlacklist[i] = LootTrackerBlacklist_DefaultSettings[i]
		end
	end
end
	
function LootTracker_OnLoad()

	DEFAULT_CHAT_FRAME:AddMessage(string.format("|cfff485eaMemeTracker|r v%s by %s. Type /mt or /memetracker for more info", GetAddOnMetadata("LootTracker", "Version"), GetAddOnMetadata("LootTracker", "Author")));
    this:RegisterEvent("VARIABLES_LOADED");
    this:RegisterEvent("CHAT_MSG_LOOT")
	--CHAT_MSG_LOOT examples:
	--You receive loot: |cffffffff|Hitem:769:0:0:0|h[Chunk of Boar Meat]|h|r.
	--Luise receives loot: |cffffffff|Hitem:769:0:0:0|h[Chunk of Boar Meat]|h|r.
    
	SlashCmdList["LootTracker"] = LootTracker_SlashCommand;
	SLASH_LootTracker1 = "/memetracker";
	SLASH_LootTracker2 = "/mt";
	
	local MSG_PREFIX = "LootTracker"
	
	
	LootTracker_pattern_playername = "^([^%s]+) receive" 
	LootTracker_pattern_itemname = "%[(.+)]"
	LootTracker_pattern_itemid = "item:(%d+)"
	LootTracker_pattern_rarityhex = "(.+)|c(.+)|H"
 	you = "You"
	LootTracker_pattern_epgpextract = "^(%d+)/(%d+)"

	
	LootTracker_color_common = "ffffffff"
	LootTracker_color_uncommon = "ff1eff00"
	LootTracker_color_rare = "ff0070dd"
	LootTracker_color_epic = "ffa335ee"
	LootTracker_color_legendary = "ffff8000"
	
	LootTracker_dbfield_playername = "playername"
	LootTracker_dbfield_itemname = "itemname"
	LootTracker_dbfield_itemid = "itemid"
	LootTracker_dbfield_rarity = "rarity"
	LootTracker_dbfield_timestamp = "timestamp"
	LootTracker_dbfield_zone = "zone"
	LootTracker_dbfield_oldplayergp = "oldplayergp"
	LootTracker_dbfield_cost = "cost"
	LootTracker_dbfield_newplayergp = "newplayergp"
	LootTracker_dbfield_offspec = "wishlist"
	LootTracker_dbfield_offspec = "offspec"
	LootTracker_dbfield_res3 = "res3"
	LootTracker_dbfield_res4 = "res4"
	LootTracker_dbfield_res5 = "res5"
	
	--Localization
	LootTrackerLoc_Title = "|cfff485ea<meme team> Loot Council|r" 
	LootTrackerLoc_Version = GetAddOnMetadata("LootTracker", "Version")
end

function LootTracker_OnEvent()
	if event == "VARIABLES_LOADED" then
		this:UnregisterEvent("VARIABLES_LOADED");
		LootTracker_Initialize();
	elseif event == "CHAT_MSG_LOOT" and arg1 and LootTrackerOptions["enabled"] == true then
		
		--check and ignore you create: 
		if string.find(arg1, LootTracker_pattern_playername) then
		
			--extract the person who looted
			local _, _, playername = string.find(arg1, LootTracker_pattern_playername)
			if playername then
				if playername == you then
					playername = UnitName("player")
				end
			end
			
			--extract the itemname
			local _, _, itemname = string.find(arg1, LootTracker_pattern_itemname)
			
			--extract the item id
			local _, _, itemid = string.find(arg1, LootTracker_pattern_itemid)

			--extract rarity
			local _, _, _, rarityhex = string.find(arg1, LootTracker_pattern_rarityhex)
			
			--check if item is on the blacklist
			if not LootTracker_CheckBlacklist(itemname) then

				--check rarity and add itemname to db
				if rarityhex == LootTracker_color_common and LootTrackerOptions["common"] == true then
					rarity = "common"
					LootTracker_AddtoDB (playername, itemname, itemid, rarity)
				elseif rarityhex == LootTracker_color_uncommon and LootTrackerOptions["uncommon"] == true then
					rarity = "uncommon"
					LootTracker_AddtoDB (playername, itemname, itemid, rarity)
				elseif rarityhex == LootTracker_color_rare and LootTrackerOptions["rare"] == true then
					rarity = "rare"
					LootTracker_AddtoDB (playername, itemname, itemid, rarity)
				elseif rarityhex == LootTracker_color_epic and LootTrackerOptions["epic"] == true then
					rarity = "epic"
					LootTracker_AddtoDB (playername, itemname, itemid, rarity)
				elseif rarityhex == LootTracker_color_legendary and LootTrackerOptions["legendary"] == true then
					rarity = "legendary"
					LootTracker_AddtoDB (playername, itemname, tostring(itemid), rarity)
				end
			end
		end
	end
end

function LootTracker_CheckBlacklist(itemname)
	for k,v in ipairs(LootTrackerBlacklist) do
		if itemname == v then
			return true
		end
	end
	return false
end

function LootTracker_SlashCommand(msg)

	if msg == "help" then
		DEFAULT_CHAT_FRAME:AddMessage("MemeTracker usage:")
		DEFAULT_CHAT_FRAME:AddMessage("/mt or /memetracker { help |  enable | disable | toggle | show | options | reset | uncommon | common | rare | epic | legendary | timestamp | cost}")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eahelp|r: prints out this help")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eaenable|r: enables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eadisable|r: disables loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eatoggle|r: toggles loot tracking")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eashow|r: shows the current configuration")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eaoptions|r: shows the option menu")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eauncommon|r: toggles tracking uncommon loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eacommon|r: toggles tracking common loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485earare|r: toggles tracking rare loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eaepic|r: toggles tracking epic loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485ealegendary|r: toggles tracking legendary loot")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eatimestamp|r: toggles exporting with timestamps")
		DEFAULT_CHAT_FRAME:AddMessage(" - |cfff485eacost|r: toggles exporting with GP price")
	elseif msg == "toggle" then 
		if LootTrackerOptions["enabled"] == true then
			LootTrackerOptions["enabled"] = false
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
		elseif LootTrackerOptions["enabled"] == false then
			LootTrackerOptions["enabled"] = true
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
		end
	elseif msg == "enable" then
		LootTrackerOptions["enabled"] = true
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
	elseif msg == "disable" then
		LootTrackerOptions["enabled"] = false
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
	elseif msg == "show" then
	
		if LootTrackerOptions["enabled"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cff00ff00enabled|r")
		elseif LootTrackerOptions["enabled"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("LootTracker state: |cffff0000disabled|r")
		end
	
		if LootTrackerOptions["common"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["common"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["uncommon"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["uncommon"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["rare"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["rare"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["epic"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["epic"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cffff0000disabled|r")
		end

		if LootTrackerOptions["legendary"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cff00ff00enabled|r")
		elseif LootTrackerOptions["legendary"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cffff0000disabled|r")
		end
		
		if LootTrackerOptions["timestamp"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with timestamps: |cff00ff00enabled|r")
		elseif LootTrackerOptions["timestamp"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with timestamps: |cffff0000disabled|r")
		end
		
		if LootTrackerOptions["cost"] == true then
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with GP price: |cff00ff00enabled|r")
		elseif LootTrackerOptions["cost"] == false then
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with GP price: |cffff0000disabled|r")
		end

	elseif msg == "options" then
		if LootTracker_OptionsFrame:IsVisible() then
			LootTracker_OptionsFrame:Hide()
		else
			ShowUIPanel(LootTracker_OptionsFrame, 1)
		end
		
	elseif msg == "reset" then
		LootTracker_ResetDB()
	elseif msg == "common" then		
		if LootTrackerOptions["common"] == true then
			LootTrackerOptions["common"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["common"] == false then
			LootTrackerOptions["common"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffffffffcommon|r loot: |cff00ff00enabled|r")
		end
	elseif msg == "uncommon" then		
		if LootTrackerOptions["uncommon"] == true then
			LootTrackerOptions["uncommon"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["uncommon"] == false then
			LootTrackerOptions["uncommon"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff1eff00uncommon|r loot: |cff00ff00enabled|r")
		end
	elseif msg == "rare" then		
		if LootTrackerOptions["rare"] == true then
			LootTrackerOptions["rare"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["rare"] == false then
			LootTrackerOptions["rare"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cff0070ddrare|r loot: |cff00ff00enabled|r")
		end
	elseif msg == "epic" then		
		if LootTrackerOptions["epic"] == true then
			LootTrackerOptions["epic"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["epic"] == false then
			LootTrackerOptions["epic"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffa335eeepic|r loot: |cff00ff00enabled|r")
		end
	elseif msg == "legendary" then		
		if LootTrackerOptions["legendary"] == true then
			LootTrackerOptions["legendary"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cffff0000disabled|r")
		elseif LootTrackerOptions["legendary"] == false then
			LootTrackerOptions["legendary"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Tracking |cffff8000legendary|r loot: |cff00ff00enabled|r")
		end
	elseif msg == "timestamp" then		
		if LootTrackerOptions["timestamp"] == true then
			LootTrackerOptions["timestamp"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with timestamps: |cffff0000disabled|r")
		elseif LootTrackerOptions["timestamp"] == false then
			LootTrackerOptions["timestamp"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with timestamps: |cff00ff00enabled|r")

		end
	elseif msg == "cost" then		
		if LootTrackerOptions["cost"] == true then
			LootTrackerOptions["cost"] = false
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with GP price: |cffff0000disabled|r")
		elseif LootTrackerOptions["cost"] == false then
			LootTrackerOptions["cost"] = true
			DEFAULT_CHAT_FRAME:AddMessage("Exporting with GP price: |cff00ff00enabled|r")
		end
	else
		if (LootTracker_BrowseFrame:IsVisible() or LootTracker_RaidIDFrame:IsVisible()) then
			LootTracker_BrowseFrame:Hide()
			LootTracker_RaidIDFrame:Hide()
		else
			ShowUIPanel(LootTracker_BrowseFrame, 1)
		end
	end
end

function LootTracker_GetCosts(itemid)

	if guildName == "De Profundis" then
		CostDB = DeProfundis_GP
	elseif guildName == "Discordia" then
		CostDB = Discordia_GP
	else
		CostDB = DeProfundis_GP
	end

	if CostDB and itemid then
		for k, v in pairs(CostDB) do
			if k == "Item"..itemid then
				return v
			end
		end
	end
	
	return 0
end


---------------------------------------------------------
--LootTracker Database Functions
---------------------------------------------------------
function LootTracker_AddtoDB(playername, itemname, itemid, rarity, offspec, de)

	--clear variables
	
	
	--get the metadata
	--timestamp_raidid = date("%y-%m-%d")
	--timestamp_detail = date("%y-%m-%d %H:%M:%S")
	timestamp_raidid = date("%Y-%m-%d")
	timestamp_detail = date("%Y-%m-%d")
	zonename = GetRealZoneText();
	raidid = timestamp_raidid .. " " .. zonename
	

	--check if db is empty
	if LootTrackerDB == nil then
		LootTrackerDB = {}
	end
	if LootTrackerDB[raidid] == nil then
		LootTrackerDB[raidid] = {}
	end
	
	--Player GP
	for i = 1, GetNumGuildMembers(true) do
		local guild_name, _, _, _, _, _, _, guild_officernote, _, _ = GetGuildRosterInfo(i)
		local _, _, guild_ep, guild_gp = string.find(guild_officernote, LootTracker_pattern_epgpextract)
			if guild_name == playername then
				oldplayergp = guild_gp
			end
	end
	
	--calculate costs
	cost = LootTracker_GetCosts(itemid)
	

	--import the itemname into the db
	if playername and itemname and itemid and rarity and timestamp_detail and zonename then
		if getn(LootTrackerDB[raidid]) == 0 then
			LootTrackerDB[raidid][1] = {}
			LootTrackerDB[raidid][1][LootTracker_dbfield_playername] = playername
			LootTrackerDB[raidid][1][LootTracker_dbfield_itemname] = itemname
			LootTrackerDB[raidid][1][LootTracker_dbfield_itemid] = itemid
			LootTrackerDB[raidid][1][LootTracker_dbfield_rarity] = rarity
			LootTrackerDB[raidid][1][LootTracker_dbfield_timestamp] = timestamp_detail
			LootTrackerDB[raidid][1][LootTracker_dbfield_zone] = zonename
			if oldplayergp then
				LootTrackerDB[raidid][1][LootTracker_dbfield_oldplayergp] = tostring(oldplayergp)
			else
				LootTrackerDB[raidid][1][LootTracker_dbfield_oldplayergp] = "0"
			end
			if cost then 
				LootTrackerDB[raidid][1][LootTracker_dbfield_cost] = tostring(cost)
			else
				LootTrackerDB[raidid][1][LootTracker_dbfield_cost] = "0"
			end
			if oldplayergp and cost then 
				LootTrackerDB[raidid][1][LootTracker_dbfield_newplayergp] = tostring(oldplayergp+cost)
			else
				if oldplayergp then
					LootTrackerDB[raidid][1][LootTracker_dbfield_newplayergp] = tostring(oldplayergp)
				else
					LootTrackerDB[raidid][1][LootTracker_dbfield_newplayergp] = "0"
				end
			end
			
			if wishlist == true then
				LootTrackerDB[raidid][1][LootTracker_dbfield_wishlist] = true
			else
				LootTrackerDB[raidid][1][LootTracker_dbfield_wishlist] = false
			end
			if offspec == true then
				LootTrackerDB[raidid][1][LootTracker_dbfield_offspec] = true
			else
				LootTrackerDB[raidid][1][LootTracker_dbfield_offspec] = false
			end
			LootTrackerDB[raidid][1][LootTracker_dbfield_res3] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res4] = nil
			LootTrackerDB[raidid][1][LootTracker_dbfield_res5] = nil
		else
			lootid = getn(LootTrackerDB[raidid])+1
			LootTrackerDB[raidid][lootid] = {}
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_playername] = playername
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_itemname] = itemname
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_itemid] = itemid
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_rarity] = rarity
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_timestamp] = timestamp_detail
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_zone] = zonename
			if oldplayergp then
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_oldplayergp] = tostring(oldplayergp)
			else
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_oldplayergp] = "0"
			end
			if cost then 
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_cost] = tostring(cost)
			else
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_cost] = "0"
			end
			if oldplayergp and cost then 
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_newplayergp] = tostring(oldplayergp+cost)
			else
				if oldplayergp then
					LootTrackerDB[raidid][lootid][LootTracker_dbfield_newplayergp] = tostring(oldplayergp)
				else
					LootTrackerDB[raidid][lootid][LootTracker_dbfield_newplayergp] = "0"
				end
			end
			
			if wishlist == true then
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_wishlist] = true
			else
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_wishlist] = false
			end
			if offspec == true then
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_offspec] = true
			else
				LootTrackerDB[raidid][lootid][LootTracker_dbfield_offspec] = false
			end
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res3] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res4] = nil
			LootTrackerDB[raidid][lootid][LootTracker_dbfield_res5] = nil
		end
	else
		DEFAULT_CHAT_FRAME:AddMessage("LootTracker Debug: Error in LootTracker_AddtoDB")
	end
end

function LootTracker_ResetDB()
	LootTrackerDB = {}
	LootTracker_RaidIDScrollFrame_Update()
	LootTracker_BuildBrowseTable()
	DEFAULT_CHAT_FRAME:AddMessage("Loot Database has been reset")
end

function LootTracker_ExportRaid(raidid, timestamp, cost)
	--check raidid
	raidfound = false
	if raidid and (string.len(raidid) >= 1) then
		for k in pairs(LootTrackerDB) do
			if k == raidid then
				raidfound = true
			end
		end
	end
	
	LootTracker_ExportData = nil
	
	if raidfound == true then
		LootTracker_ExportData = raidid.."\r\n\r\n"
		for index in LootTrackerDB[raidid] do
			if timestamp == true then
				LootTracker_ExportData = LootTracker_ExportData .. LootTrackerDB[raidid][index][LootTracker_dbfield_timestamp] .. " - "
			end
			LootTracker_ExportData = LootTracker_ExportData .. LootTrackerDB[raidid][index][LootTracker_dbfield_itemname]
			if LootTrackerDB[raidid][index][LootTracker_dbfield_offspec] == true then
				LootTracker_ExportData = LootTracker_ExportData .. ": offspec"
			else
				LootTracker_ExportData = LootTracker_ExportData  .. ": " .. LootTrackerDB[raidid][index][LootTracker_dbfield_playername]
			end
			if LootTrackerDB[raidid][index][LootTracker_dbfield_wishlist] == true then
				LootTracker_ExportData = LootTracker_ExportData .. " - wishlist"
			end
			if cost and LootTrackerDB[raidid][index][LootTracker_dbfield_offspec] == false then
				LootTracker_ExportData = LootTracker_ExportData  .. " - " .. LootTrackerDB[raidid][index][LootTracker_dbfield_cost]
			end
			LootTracker_ExportData = LootTracker_ExportData .. "\r\n"
		end

		LootTracker_ExportRaidFrameEditBox1:SetFont("Fonts\\FRIZQT__.TTF", "8")
		LootTracker_ExportRaidFrameEditBox1Left:Hide()
		LootTracker_ExportRaidFrameEditBox1Middle:Hide()
		LootTracker_ExportRaidFrameEditBox1Right:Hide()
		LootTracker_ExportRaidFrameEditBox1:SetText(LootTracker_ExportData)
		
		ShowUIPanel(LootTracker_ExportRaidFrame, 1)
	end
end

---------------------------------------------------------
--LootTracker ItemBrowse Frame Functions
---------------------------------------------------------
function LootTracker_Main_OnShow()

end

-- this function is called when the frame starts being dragged around
function LootTracker_Main_OnMouseDown(button)
	if (button == "LeftButton") then
		this:StartMoving();
	end
end

-- this function is called when the frame is stopped being dragged around
function LootTracker_Main_OnMouseUp(button)
	if (button == "LeftButton") then
		this:StopMovingOrSizing()

	end
end

function LootTracker_RaidIDButton_OnClick()
	if LootTracker_RaidIDFrame:IsVisible() then
		LootTracker_RaidIDFrame:Hide()
	else
		LootTracker_RaidIDScrollFrame_Update()
		ShowUIPanel(LootTracker_RaidIDFrame, 1)
	end
end

function LootTracker_BuildBrowseTable()
	LootTracker_BrowseTable = {}
	--read ReadSearch editbox
	raidid = getglobal("LootTracker_RaidIDBox"):GetText()
		
	--check if raid exists
	raidfound = false
	if raidid and (string.len(raidid) >= 1) then
		for k in pairs(LootTrackerDB) do
			if k == raidid then
				raidfound = true
			end
		end
	end
	
	if raidfound == true then

		for index in LootTrackerDB[raidid] do
			LootTracker_BrowseTable[index] = {}
			LootTracker_BrowseTable[index].timestamp = LootTrackerDB[raidid][index][LootTracker_dbfield_timestamp]
			LootTracker_BrowseTable[index].playername = LootTrackerDB[raidid][index][LootTracker_dbfield_playername]

			if LootTrackerDB[raidid][index][LootTracker_dbfield_rarity] == "common" then
				browse_rarityhexlink = LootTracker_color_common
			elseif LootTrackerDB[raidid][index][LootTracker_dbfield_rarity] == "uncommon" then
				browse_rarityhexlink = LootTracker_color_uncommon
			elseif LootTrackerDB[raidid][index][LootTracker_dbfield_rarity] == "rare" then
				browse_rarityhexlink = LootTracker_color_rare
			elseif LootTrackerDB[raidid][index][LootTracker_dbfield_rarity] == "epic" then
				browse_rarityhexlink = LootTracker_color_epic
			elseif LootTrackerDB[raidid][index][LootTracker_dbfield_rarity] == "legendary" then
				browse_rarityhexlink = LootTracker_color_legendary
			end
			--building the itemlink
			browse_itemlink = "|c" .. browse_rarityhexlink .. "|Hitem:" .. LootTrackerDB[raidid][index][LootTracker_dbfield_itemid] .. ":0:0:0|h[" .. LootTrackerDB[raidid][index][LootTracker_dbfield_itemname] .. "]|h|r"
			
			LootTracker_BrowseTable[index].itemname = browse_itemlink
			-- for sorting
			LootTracker_BrowseTable[index].itemnamenolink = LootTrackerDB[raidid][index][LootTracker_dbfield_itemname]
			LootTracker_BrowseTable[index].zone = LootTrackerDB[raidid][index][LootTracker_dbfield_zone]
			--rest
			LootTracker_BrowseTable[index].cost = LootTrackerDB[raidid][index][LootTracker_dbfield_cost]
			LootTracker_BrowseTable[index].wishlist = LootTrackerDB[raidid][index][LootTracker_dbfield_wishlist]
			LootTracker_BrowseTable[index].offspec = LootTrackerDB[raidid][index][LootTracker_dbfield_offspec]
			--for tooltip
			LootTracker_BrowseTable[index].itemid = LootTrackerDB[raidid][index][LootTracker_dbfield_itemid]
			--for itemedit GUI
			LootTracker_BrowseTable[index].oldplayergp = LootTrackerDB[raidid][index][LootTracker_dbfield_oldplayergp]
			LootTracker_BrowseTable[index].newplayergp = LootTrackerDB[raidid][index][LootTracker_dbfield_newplayergp]
			LootTracker_BrowseTable[index].raidid = raidid
			LootTracker_BrowseTable[index].originalindex = index
		end
	
		--sorting
		if sortfield == LootTracker_dbfield_timestamp then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.timestamp < b.timestamp end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.timestamp > b.timestamp end)
			end
		elseif sortfield == LootTracker_dbfield_zone then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.zone < b.zone end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.zone > b.zone end)
			end	
		elseif sortfield == LootTracker_dbfield_playername then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.playername < b.playername end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.playername > b.playername end)
			end
		elseif sortfield == LootTracker_dbfield_itemname then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.itemnamenolink < b.itemnamenolink end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return a.itemnamenolink > b.itemnamenolink end)
			end
		elseif sortfield == LootTracker_dbfield_cost then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return (a.cost) < (b.cost) end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return (a.cost) > (b.cost) end)
			end
			elseif sortfield == LootTracker_dbfield_wishlist then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return tostring(a.wishlist) < tostring(b.wishlist) end)
			elseif sortdirection == "descending" then
			table.sort(LootTracker_BrowseTable, function(a,b) return tostring(a.wishlist) > tostring(b.wishlist) end)
			end
		elseif sortfield == LootTracker_dbfield_offspec then
			if sortdirection == "ascending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return tostring(a.offspec) < tostring(b.offspec) end)
			elseif sortdirection == "descending" then
				table.sort(LootTracker_BrowseTable, function(a,b) return tostring(a.offspec) > tostring(b.offspec) end)
			end
		else
			table.sort(LootTracker_BrowseTable, function(a,b) return a.timestamp < b.timestamp end)
		end
		
		--call for GUI Update
		LootTracker_ListScrollFrame_Update()
	
	else
		getglobal("LootTracker_TotalLootText"):SetText("no Raid found: " .. raidid)
		getglobal("LootTracker_TotalLootTextValue"):SetText("0 items")
	end
end

function LootTracker_ListScrollFrame_Update()
	--set GUI Total Loots (per Raid)
	if not LootTracker_BrowseTable then 
		LootTracker_BrowseTable = {}
	end
	
	if not raidid then
		raidid = getglobal("LootTracker_RaidIDBox"):GetText()
	end
	
	local maxlines = getn(LootTracker_BrowseTable)
	getglobal("LootTracker_TotalLootText"):SetText("Raid: " .. raidid .. ":")
	if maxlines == 1 then
		getglobal("LootTracker_TotalLootTextValue"):SetText(maxlines .. " item")
	else
		getglobal("LootTracker_TotalLootTextValue"):SetText(maxlines .. " items")
	end
	
	
	local line; -- 1 through 20 of our window to scroll
	local lineplusoffset; -- an index into our data calculated from the scroll offset
   
	 -- maxlines is max entries, 1 is number of lines, 16 is pixel height of each line
	FauxScrollFrame_Update(LootTracker_ListScrollFrame, maxlines, 1, 16)


	for line=1,20 do
		 lineplusoffset = line + FauxScrollFrame_GetOffset(LootTracker_ListScrollFrame);
		 if lineplusoffset <= maxlines then
			getglobal("LootTracker_List"..line.."TextTimestamp"):SetText(LootTracker_BrowseTable[lineplusoffset].timestamp)
			getglobal("LootTracker_List"..line.."TextPlayername"):SetText(LootTracker_BrowseTable[lineplusoffset].playername)
			getglobal("LootTracker_List"..line.."TextZone"):SetText(LootTracker_BrowseTable[lineplusoffset].zone)
			getglobal("LootTracker_List"..line.."TextItemName"):SetText(LootTracker_BrowseTable[lineplusoffset].itemname)
			getglobal("LootTracker_List"..line.."TextCost"):SetText(LootTracker_BrowseTable[lineplusoffset].cost)

			
			if LootTracker_BrowseTable[lineplusoffset].wishlist == true then
				getglobal("LootTracker_List"..line.."TextWishlist"):SetText("yes")
			else
				getglobal("LootTracker_List"..line.."TextWishlist"):SetText("no")
			end
			
			if LootTracker_BrowseTable[lineplusoffset].offspec == true then 
				getglobal("LootTracker_List"..line.."TextOffspec"):SetText("yes")
			else
				getglobal("LootTracker_List"..line.."TextOffspec"):SetText("no")
			end
			
			getglobal("LootTracker_List"..line):Show()
		 else
			getglobal("LootTracker_List"..line):Hide()
		 end
   end
end

--fires when the headline in the browse frame list is clicked
function LootTracker_SortTimestamp_OnClick(button)
	if sortfield == LootTracker_dbfield_timestamp and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_timestamp
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_timestamp
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortPlayername_OnClick(button)
	if 	sortfield == LootTracker_dbfield_playername and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_playername
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_playername
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortItemName_OnClick(button)
	if 	sortfield == LootTracker_dbfield_itemname and sortdirection == "ascending" then
	sortfield = LootTracker_dbfield_itemname
		sortdirection = "descending"
	else
	sortfield = LootTracker_dbfield_itemname
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortZone_OnClick(button)
	if 	sortfield == LootTracker_dbfield_zone and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_zone
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_zone
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortCost_OnClick(button)
	if 	sortfield == LootTracker_dbfield_cost and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_cost
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_cost
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortWishlist_OnClick(button)
	if 	sortfield == LootTracker_dbfield_wishlist and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_wishlist
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_wishlist
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end

function LootTracker_SortOffspec_OnClick(button)
	if 	sortfield == LootTracker_dbfield_offspec and sortdirection == "ascending" then
		sortfield = LootTracker_dbfield_offspec
		sortdirection = "descending"
	else
		sortfield = LootTracker_dbfield_offspec
		sortdirection = "ascending"
	end
	LootTracker_BuildBrowseTable()
end


--fires when a line in the browse frame list is clicked
function LootTracker_ListButton_OnClick(button, index)
	 if button == "LeftButton" then
		if( IsShiftKeyDown() and ChatFrameEditBox:IsVisible() ) then
			local link = LootTracker_BrowseTable[index].itemname
			ChatFrameEditBox:Insert(link)
		end
		
	 elseif button == "RightButton" then
		LootTracker_ItemEdit(index)
	 end
end

--mouseover a line in the itemlist
function LootTracker_ListButton_OnEnter(index)
	local itemid = LootTracker_BrowseTable[index].itemid
	
	if itemid then
		LootTracker_Tooltip:SetOwner(this, "ANCHOR_BOTTOMRIGHT");
		LootTracker_Tooltip:SetHyperlink("item:" .. itemid .. ":0:0:0")
		LootTracker_Tooltip:Show()
	end
end

function LootTracker_ListButton_OnLeave()
	LootTracker_Tooltip:Hide()	
end

function LootTracker_ExportButton_OnClick()
	raidid = getglobal("LootTracker_RaidIDBox"):GetText()
	
	--LootTracker_ExportRaid(raidid, LootTrackerOptions["timestamp"], LootTrackerOptions["cost"])

	if LootTrackerOptions["timestamp"] == false and LootTrackerOptions["cost"] == false then
		LootTracker_ExportRaid(raidid, false, false)
	elseif LootTrackerOptions["timestamp"] == false and LootTrackerOptions["cost"] == true then
		LootTracker_ExportRaid(raidid, false, true)
	elseif LootTrackerOptions["timestamp"] == true and LootTrackerOptions["cost"] == false then
		LootTracker_ExportRaid(raidid, true, false)
	elseif LootTrackerOptions["timestamp"] ==  true and LootTrackerOptions["cost"] == true then
		LootTracker_ExportRaid(raidid, true, true)
	end
end

---------------------------------------------------------
--LootTracker RaidID Browse Frame Functions
---------------------------------------------------------

--fires when a line in the Raid ID browse frame list is clicked
function LootTracker_RaidIDListButton_OnClick()

	local raidid_browse = getglobal(this:GetName().."TextRaidID"):GetText();
	getglobal("LootTracker_RaidIDBox"):SetText(raidid_browse)
	
	HideUIPanel(LootTracker_RaidIDFrame, 1)
	LootTracker_BuildBrowseTable()
	
end

--Raid ID Browser ScrollBar
function LootTracker_RaidIDScrollFrame_Update()

	LootTracker_RaidIDBrowseTable = {}
		
	for k in pairs(LootTrackerDB) do
		table.insert(LootTracker_RaidIDBrowseTable, k)
	end

	local maxlines = getn(LootTracker_RaidIDBrowseTable)
	local line; -- 1 through 10 of our window to scroll
	local lineplusoffset; -- an index into our data calculated from the scroll offset
   
	 -- maxlines is max entries, 1 is number of lines, 16 is pixel height of each line
	FauxScrollFrame_Update(LootTracker_RaidIDScrollFrame, maxlines, 1, 16)

	--sort table
	table.sort(LootTracker_RaidIDBrowseTable, function(a, b) return a > b end)
	--table.sort(LootTracker_RaidIDBrowseTable)

	for line=1,10 do
		 lineplusoffset = line + FauxScrollFrame_GetOffset(LootTracker_RaidIDScrollFrame);
		 if lineplusoffset <= maxlines then
			getglobal("LootTracker_RaidIDList"..line.."TextRaidID"):SetText(LootTracker_RaidIDBrowseTable[lineplusoffset])
			getglobal("LootTracker_RaidIDList"..line):Show()
		 else
			getglobal("LootTracker_RaidIDList"..line):Hide()
		 end
   end
end

---------------------------------------------------------
--LootTracker ItemEdit Frame Functions
---------------------------------------------------------
function LootTracker_ItemEdit(index)
	--fill window then open
	getglobal("LootTracker_ItemEditFrameItemName"):SetText(LootTracker_BrowseTable[index].itemname)
	getglobal("LootTracker_ItemEditFramePlayerName"):SetText(LootTracker_BrowseTable[index].playername)
	getglobal("LootTracker_ItemEditFrameOldPlayerGP"):SetText(LootTracker_BrowseTable[index].oldplayergp)
	getglobal("LootTracker_ItemEditFrameCost"):SetText(LootTracker_BrowseTable[index].cost)
	getglobal("LootTracker_ItemEditFrameNewPlayerGP"):SetText(LootTracker_BrowseTable[index].newplayergp)
	
	if LootTracker_BrowseTable[index].wishlist then
		getglobal("LootTracker_ItemEditFrameOption1"):SetChecked(true)
	else
		getglobal("LootTracker_ItemEditFrameOption1"):SetChecked(false)
	end
	
	if LootTracker_BrowseTable[index].offspec then
		getglobal("LootTracker_ItemEditFrameOption2"):SetChecked(true)
	else
		getglobal("LootTracker_ItemEditFrameOption2"):SetChecked(false)
	end
	
	--fill vars for itemedit
	LootTracker_ItemEditDB = {
	raidid = LootTracker_BrowseTable[index].raidid,
	index = index,
	originalindex = LootTracker_BrowseTable[index].originalindex,
	timestamp = LootTracker_BrowseTable[index].timestamp,
	itemname = LootTracker_BrowseTable[index].itemname,
	itemid = LootTracker_BrowseTable[index].itemid,
	playername = LootTracker_BrowseTable[index].playername,
	oldplayergp = LootTracker_BrowseTable[index].oldplayergp,
	cost = LootTracker_BrowseTable[index].cost,
	newplayergp = LootTracker_BrowseTable[index].newplayergp
	}
	
	
	ShowUIPanel(LootTracker_ItemEditFrame, 1)
end

function LootTracker_ItemEditCheckButton_OnClick(id)
	--wishlist
	if id == 1 then
		if LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_wishlist] == true then
		
			LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_wishlist]	= false

		elseif LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_wishlist] == false then
			
			LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_wishlist]	= true

		end
	--offspec
	elseif id == 2 then
		if LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_offspec] == true then
			
			LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_offspec]	= false
	
		elseif LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_offspec] == false then
			
			LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_offspec]	= true
		end
	end
	
	getglobal("LootTracker_ItemEditFrameOldPlayerGP"):SetText(LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_oldplayergp])
	getglobal("LootTracker_ItemEditFrameCost"):SetText(LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_cost])
	getglobal("LootTracker_ItemEditFrameNewPlayerGP"):SetText(LootTrackerDB[LootTracker_ItemEditDB.raidid][LootTracker_ItemEditDB.originalindex][LootTracker_dbfield_newplayergp])
	LootTracker_BuildBrowseTable()
end
		

---------------------------------------------------------
--LootTracker Options Frame Functions
---------------------------------------------------------
function LootTracker_OptionsButton_OnClick()
	if LootTracker_OptionsFrame:IsVisible() then
		LootTracker_OptionsFrame:Hide()
	else
		ShowUIPanel(LootTracker_OptionsFrame, 1)
	end
end

function LootTracker_OptionsFrame_OnShow()
	if LootTrackerOptions["enabled"] == true then
		getglobal("LootTracker_OptionsFrameOption1"):SetChecked(true)
		getglobal("LootTracker_OptionsFrameOption2"):Enable()
		getglobal("LootTracker_OptionsFrameOption3"):Enable()
		getglobal("LootTracker_OptionsFrameOption4"):Enable()
		getglobal("LootTracker_OptionsFrameOption5"):Enable()
		getglobal("LootTracker_OptionsFrameOption6"):Enable()
	else
		getglobal("LootTracker_OptionsFrameOption1"):SetChecked(false)
		getglobal("LootTracker_OptionsFrameOption2"):Disable()
		getglobal("LootTracker_OptionsFrameOption3"):Disable()
		getglobal("LootTracker_OptionsFrameOption4"):Disable()
		getglobal("LootTracker_OptionsFrameOption5"):Disable()
		getglobal("LootTracker_OptionsFrameOption6"):Disable()
	end
	if LootTrackerOptions["common"] == true then
		getglobal("LootTracker_OptionsFrameOption2"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption2"):SetChecked(false)
	end
	if LootTrackerOptions["uncommon"] == true then
		getglobal("LootTracker_OptionsFrameOption3"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption3"):SetChecked(false)
	end
	if LootTrackerOptions["rare"] == true then
		getglobal("LootTracker_OptionsFrameOption4"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption4"):SetChecked(false)
	end
	if LootTrackerOptions["epic"] == true then
		getglobal("LootTracker_OptionsFrameOption5"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption5"):SetChecked(false)
	end
	if LootTrackerOptions["legendary"] == true then
		getglobal("LootTracker_OptionsFrameOption6"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption6"):SetChecked(false)
	end
	if LootTrackerOptions["timestamp"] == true then
		getglobal("LootTracker_OptionsFrameOption7"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption7"):SetChecked(false)
	end
	if LootTrackerOptions["cost"] == true then
		getglobal("LootTracker_OptionsFrameOption8"):SetChecked(true)
	else
		getglobal("LootTracker_OptionsFrameOption8"):SetChecked(false)
	end
end

function LootTracker_OptionCheckButton_OnClick(id)
	if id == 1 then
		if LootTrackerOptions["enabled"] == true then
			LootTrackerOptions["enabled"] = false
			
			--disable checkbuttons
			getglobal("LootTracker_OptionsFrameOption2"):Disable()
			getglobal("LootTracker_OptionsFrameOption3"):Disable()
			getglobal("LootTracker_OptionsFrameOption4"):Disable()
			getglobal("LootTracker_OptionsFrameOption5"):Disable()
			getglobal("LootTracker_OptionsFrameOption6"):Disable()
		else
			LootTrackerOptions["enabled"] = true
			
			--enable checkbuttons
			getglobal("LootTracker_OptionsFrameOption2"):Enable()
			getglobal("LootTracker_OptionsFrameOption3"):Enable()
			getglobal("LootTracker_OptionsFrameOption4"):Enable()
			getglobal("LootTracker_OptionsFrameOption5"):Enable()
			getglobal("LootTracker_OptionsFrameOption6"):Enable()
		end
	elseif id == 2 then
		if LootTrackerOptions["common"] == true then
			LootTrackerOptions["common"] = false
		else
			LootTrackerOptions["common"] = true
		end
	elseif id == 3 then
		if LootTrackerOptions["uncommon"] == true then
			LootTrackerOptions["uncommon"] = false
		else
			LootTrackerOptions["uncommon"] = true
		end
	elseif id == 4 then
		if LootTrackerOptions["rare"] == true then
			LootTrackerOptions["rare"] = false
		else
			LootTrackerOptions["rare"] = true
		end
	elseif id == 5 then
		if LootTrackerOptions["epic"] == true then
			LootTrackerOptions["epic"] = false
		else
			LootTrackerOptions["epic"] = true
		end
	elseif id == 6 then
		if LootTrackerOptions["legendary"] == true then
			LootTrackerOptions["legendary"] = false
		else
			LootTrackerOptions["legendary"] = true
		end
	elseif id == 7 then
		if LootTrackerOptions["timestamp"] == true then
			LootTrackerOptions["timestamp"] = false
		else
			LootTrackerOptions["timestamp"] = true
		end
	elseif id == 8 then
		if LootTrackerOptions["cost"] == true then
			LootTrackerOptions["cost"] = false
		else
			LootTrackerOptions["cost"] = true
		end
	end
end

function LootTracker_OptionsReset_OnClick() 
	LootTracker_ResetDB()
end
