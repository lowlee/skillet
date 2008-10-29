--[[

Skillet: A tradeskill window replacement.
Copyright (c) 2007 Robert Clark <nogudnik@gmail.com>

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program.  If not, see <http://www.gnu.org/licenses/>.

]]


local AceEvent = AceLibrary("AceEvent-2.0")
local PT
if AceLibrary:HasInstance("LibPeriodicTable-3.1") then
	PT = AceLibrary("LibPeriodicTable-3.1")
end

-- a table of tradeskills by id (lowest qualifying skill only)
local TradeSkillList = {
	2259,           -- alchemy
	2018,           -- blacksmithing
	7411,           -- enchanting 
	4036,           -- engineering
	45357,			-- inscription
	25229,          -- jewelcrafting
	2108,           -- leatherworking
--	2575,			-- mining (or smelting?)
	2656,           -- smelting (from mining)
	3908,           -- tailoring
	2550,           -- cooking
	3273,           -- first aid
--	2842,           -- poisons

	
--	5149, 			-- beast training (not supported, but i need to know the number)... err... or maybe i don't
}


SkilletData = {}				-- skillet data scanner
SkilletLink = {}


local TradeSkillIDsByName = {}		-- filled in with ids and names for reverse matching (since the same name has multiple id's based on level)

local DifficultyText = {
	x = "unknown",
	o = "optimal",
	m = "medium",
	e = "easy",
	t = "trivial",
}
local DifficultyChar = {
	unknown = "x",
	optimal = "o",
	medium = "m",
	easy = "e",
	trivial = "t",
}


local skill_style_type = {
	["unknown"]			= { r = 1.00, g = 0.00, b = 0.00, level = 5, alttext="???", cstring = "|cffff0000"},
	["optimal"]	        = { r = 1.00, g = 0.50, b = 0.25, level = 4, alttext="+++", cstring = "|cffff8040"},
	["medium"]          = { r = 1.00, g = 1.00, b = 0.00, level = 3, alttext="++",  cstring = "|cffffff00"},
	["easy"]            = { r = 0.25, g = 0.75, b = 0.25, level = 2, alttext="+",   cstring = "|cff40c000"},
	["trivial"]	        = { r = 0.50, g = 0.50, b = 0.50, level = 1, alttext="",    cstring = "|cff808080"},
	["header"]          = { r = 1.00, g = 0.82, b = 0,    level = 0, alttext="",    cstring = "|cffffc800"},
}



-- adds an recipe source for an itemID (recipeID produces itemID)
function Skillet:ItemDataAddRecipeSource(itemID,recipeID)
	if not itemID or not recipeID then return end
	
	if not self.data.itemRecipeSource then
		self.data.itemRecipeSource = {}
	end
	
	if not self.data.itemRecipeSource[itemID] then		
		self.data.itemRecipeSource[itemID] = {}
	end
	
	self.data.itemRecipeSource[itemID][recipeID] = true
end


-- adds a recipe usage for an itemID (recipeID uses itemID as a reagent)
function Skillet:ItemDataAddUsedInRecipe(itemID,recipeID)
	if not itemID or not recipeID then return end
	
	if not self.data.itemRecipeUsedIn then
		self.data.itemRecipeUsedIn = {}
	end
	
	if not self.data.itemRecipeUsedIn[itemID] then
		self.data.itemRecipeUsedIn[itemID] = {}
	end
	
	self.data.itemRecipeUsedIn[itemID][recipeID] = true
end


-- goes thru the stored recipe list and collects reagent and item information as well as skill lookups
function Skillet:CollectRecipeInformation()
	
--[[
	for recipeID in pairs(self.db.account.recipeDB) do
		local recipe = self:GetRecipe(recipeID)
		
		if recipe.itemID ~= 0 then
			self:ItemDataAddRecipeSource(recipe.itemID, recipeID)
		end
		
		local reagentData = recipe.reagentData

		if reagentData then
			for r=1,#reagentData do
				self:ItemDataAddUsedInRecipe(reagentData[r].id, recipeID)
			end
		end
	end
]]
	for recipeID, recipeString in pairs(self.db.account.recipeDB) do

		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
		local itemID, numMade = 0, 1
		local slot = nil
		
		if itemString ~= "0" then
			local a, b = string.split(":",itemString)
			
			if a ~= "0" then 
				itemID, numMade = a,b
			else
				itemID = 0
				numMade = 1
				slot = tonumber(b)
			end
			
			if not numMade then
				numMade = 1
			end
		end
		
		itemID = tonumber(itemID)
		
		if itemID ~= 0 then
			self:ItemDataAddRecipeSource(itemID, recipeID)
		end
		

		local reagentList = { string.split(":",reagentString) }
		local numReagents = #reagentList / 2
		
		for i=1,numReagents do
			local reagentID = tonumber(reagentList[1 + (i-1)*2])
			
			self:ItemDataAddUsedInRecipe(reagentID, recipeID)
		end
	end
	
	
	for player,tradeList in pairs(self.db.server.skillDB) do
		self.data.skillIndexLookup[player] = {}
		
		for trade,skillList in pairs(tradeList) do
			for i=1,#skillList do
--				local skillData = self:GetSkill(player, trade, i)
				local skillString = self.db.server.skillDB[player][trade][i]

				local data = { string.split(" ",skillString) }
				
				if data[1] ~= "header" then
					local recipeID = string.sub(data[1],2)
				
					self.data.skillIndexLookup[player][recipeID] = i
				end
			end
		end
	end
end



-- Checks to see if the current trade is one that we support.

function Skillet:IsSupportedTradeskill(tradeID)
	if not tradeID or tradeID == 5419 then
		return false				-- beast training
	end
	
	if IsShiftKeyDown() then
		return false
	end
	
	return true
end

local missingVendorItems = {
	[30817] = true,				-- simple flour
	[4539] = true,				-- Goldenbark Apple
	[17035] = true,				-- Stranglethorn seed
	[17034] = true, 			-- Maple seed
}
		
		
-- queries periodic table for vendor info for a particual itemID
function Skillet:VendorSellsReagent(itemID)
	if PT then
		if missingVendorItems[itemID] then
			return true
		end
		
		if PT:ItemInSet(itemID,"Tradeskill.Mat.BySource.Vendor") then
			return true
		end
	end
end

-- resets the blizzard tradeskill search filters just to make sure no other addon has monkeyed with them
function SkilletData:ResetTradeSkillFilter()
	SetTradeSkillItemNameFilter("")	 			
	SetTradeSkillItemLevelFilter(0,0)
end


function SkilletLink:ResetTradeSkillFilter()
	SetTradeSkillItemNameFilter("")	 			
	SetTradeSkillItemLevelFilter(0,0)
end



function Skillet:IsRecipe(id)
	if not id then return end
	return true

--[[	
	return recipeName
	
	local m,i = string.split("/",id)
	
	local recipeModule = self.recipeDataModules[m]
	
	if recipeModule and tonumber(i) then
		return true
	end
]]
end



	
function SkilletData:GetRecipeName(id)
	if not id then return "unknown" end

	local name = GetSpellInfo(id)
--DebugSpam("name "..(id or "nil").." "..(name or "nil"))

	if name then return name, id end
	
	return tostring(id), id
end
	


function Skillet:GetRecipeName(id)
	if not id then return "unknown" end
	
	local name = GetSpellInfo(id)
--DebugSpam("name "..(id or "nil").." "..(name or "nil"))

	if name then return name, id end
	
	
	id = tonumber(id)
	
	local name = "unknown"
	
	for n,m in pairs(self.recipeDataModules) do
		if recipeName == "unknown" then
			recipeName = m.GetRecipeName(m, id)
		end
	end
	
	return recipeName
end




function Skillet:GetRecipe(id)
--DEFAULT_CHAT_FRAME:AddMessage("getrecipe "..(id or "nil"))
	if not id or id == 0 then return self.unknownRecipe end
	
	local recipe = self.unknownRecipe
	
	id = tonumber(id)
	
	for n,m in pairs(self.recipeDataModules) do
		if recipe == self.unknownRecipe then
			recipe = m.GetRecipe(m,id)
		end
	end

	return recipe, id
end


-- reconstruct a recipe from a recipeString and cache it into our system for this session
function SkilletData:GetRecipe(id)
	if not id or id == 0 then return self.unknownRecipe end
--DEFAULT_CHAT_FRAME:AddMessage("skilletData "..(id or "nil"))

	if (not Skillet.data.recipeList[id]) and Skillet.db.account.recipeDB[id] then	
		local recipeString = Skillet.db.account.recipeDB[id]
		
		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
		local itemID, numMade = 0, 1
		local slot = nil
		
		if itemString ~= "0" then
			local a, b = string.split(":",itemString)
			
			if a ~= "0" then 
				itemID, numMade = a,b
			else
				itemID = 0
				numMade = 1
				slot = tonumber(b)
			end
			
			if not numMade then
				numMade = 1
			end
		end
		
		Skillet.data.recipeList[id] = {}
		
		Skillet.data.recipeList[id].spellID = id
		
		Skillet.data.recipeList[id].name = GetSpellInfo(id)
		Skillet.data.recipeList[id].tradeID = tonumber(tradeID)
		Skillet.data.recipeList[id].itemID = tonumber(itemID)
		Skillet.data.recipeList[id].numMade = tonumber(numMade)
		
		Skillet.data.recipeList[id].slot = slot
		
		Skillet.data.recipeList[id].reagentData = {}

		local reagentList = { string.split(":",reagentString) }
		local numReagents = #reagentList / 2
		
		for i=1,numReagents do
			Skillet.data.recipeList[id].reagentData[i] = {}
			
			Skillet.data.recipeList[id].reagentData[i].id = tonumber(reagentList[1 + (i-1)*2])
			Skillet.data.recipeList[id].reagentData[i].numNeeded = tonumber(reagentList[2 + (i-1)*2])
		end
		
		if toolString ~= "-" then
			Skillet.data.recipeList[id].tools = {}
		
			local toolList = { string.split(":",toolString) }

			for i=1,#toolList do
				Skillet.data.recipeList[id].tools[i] = string.gsub(toolList[i],"_"," ")
			end
		end
	end
	
	return Skillet.data.recipeList[id] or Skillet.unknownRecipe
end




function Skillet:GetNumSkills(player, trade)

	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetNumSkills(skillModule, player, trade)
	end
end




function Skillet:GetSkillRanks(player, trade)	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetSkillRanks(skillModule, player, trade)
	end
end


function SkilletLink:GetSkillRanks(player, trade)
	if (IsTradeSkillLinked()) then
		local _, linkedPlayer = IsTradeSkillLinked()
		
		if linkedPlayer == player then
			local skill, rank, max = GetTradeSkillLine()
		
			if GetSpellInfo(trade) == skill then
				return rank.." "..max
			end
		end
	end
end


function SkilletLink:GetNumSkills(player, trade)
	if (IsTradeSkillLinked()) then
		local _, linkedPlayer = IsTradeSkillLinked()
		
		if linkedPlayer == player then
			local skill, rank, max = GetTradeSkillLine()
			
			if GetSpellInfo(trade) == skill then
				return GetNumTradeSkills()
			end
		end
	end
	
	return 0
end


function SkilletData:GetSkillRanks(player, trade)
	return Skillet.db.server.skillRanks[player][trade]
end


function SkilletData:GetNumSkills(player, trade)
	return #Skillet.db.server.skillDB[player][trade]
end



function Skillet:GetSkill(player,trade,index)
--DEFAULT_CHAT_FRAME:AddMessage("getrecipe "..(id or "nil")
	
	local skillModule = self.dataGatheringModules[player]
	
	if skillModule then
		return skillModule.GetSkill(skillModule, player,trade,index)
	else
		return self.unknownRecipe, 0
	end
end




function SkilletLink:GetSkill(player,trade,index)
	if player and trade and index then
		if not Skillet.data.skillList[player] then
			self:RescanTrade()
		end
		
		return Skillet.data.skillList[player][trade][index]
	end
end



-- reconstruct a recipe from a recipeString and cache it into our system for this session
function SkilletLink:GetRecipe(id)
	if not id or id == 0 then return self.unknownRecipe end
--DEFAULT_CHAT_FRAME:AddMessage("skilletData "..(id or "nil"))

	if (not Skillet.data.recipeList[id]) then	
		self:RescanTrade()
--DEFAULT_CHAT_FRAME:AddMessage("can't find recipe "..id);
	end
	
	return Skillet.data.recipeList[id] or Skillet.unknownRecipe
end





function SkilletLink:ScanTrade()
DebugSpam("ScanTrade")
	if self.scanInProgress == true then
DebugSpam("SCAN BUSY!")
		return
	end
	
	self.scanInProgress = true
	
	local tradeID
	
	local API = {}
	
	local profession, rank, maxRank = GetTradeSkillLine()
DebugSpam("GetTradeSkill: "..(profession or "nil"))

	
	-- get the tradeID from the profession name (data collected earlier).
	tradeID = TradeSkillIDsByName[profession] or 2656				-- "mining" doesn't exist as a spell, so instead use smelting (id 2656)

	if tradeID ~= Skillet.currentTrade then
DebugSpam("TRADE MISMATCH for player "..(Skillet.currentPlayer or "nil").."!  "..(tradeID or "nil").." vs "..(Skillet.currentTrade or "nil"));
	end

	
	local player = Skillet.currentPlayer
	
	if not self.recacheRecipe then
		self.recacheRecipe = {}
	end
	
	self:ResetTradeSkillFilter()						-- verify the search filter is blank (so we get all skills)

	
	local numSkills = GetNumTradeSkills()
	
DebugSpam("Scanning Trade "..(profession or "nil")..":"..(tradeID or "nil").." "..numSkills.." recipes")

	if not Skillet.data.skillIndexLookup[player] then
		Skillet.data.skillIndexLookup[player] = {}
	end
	
	local skillData = Skillet.data.skillList[player][tradeID]

	local lastHeader = nil
	local gotNil = false
	
	local currentGroup = nil
	
	local mainGroup = Skillet:RecipeGroupNew(player,tradeID,"Blizzard")
	
	mainGroup.locked = true
	
	Skillet:RecipeGroupClearEntries(mainGroup)
	
	local groupList = {}
	
	
	for i = 1, numSkills, 1 do
		repeat
--DebugSpam("scanning index "..i)
			local skillName, skillType, isExpanded, subSpell, extra
			
			
			skillName, skillType, _, isExpanded = GetTradeSkillInfo(i)
			
			
--DebugSpam("**** skill: "..(skillName or "nil"))

			gotNil = false
		
			
			if skillName then
				if skillType == "header" then
					if not isExpanded then
						ExpandTradeSkillSubClass(i)
					end

					local groupName
					
					if groupList[skillName] then
						groupList[skillName] = groupList[skillName]+1
						groupName = skillName.." "..groupList[skillName]
					else
						groupList[skillName] = 1
						groupName = skillName
					end
					
--					skillDB[i] = "header "..skillName
					skillData[i] = nil
					
					currentGroup = Skillet:RecipeGroupNew(player, tradeID, "Blizzard", groupName)
					
					Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
				else
					local recipeLink = GetTradeSkillRecipeLink(i)
					local recipeID = Skillet:GetItemIDFromLink(recipeLink)
					
					if not recipeID then
						gotNil = true
						break
					end
					
					if currentGroup then
						Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, i)
					else
						Skillet:RecipeGroupAddRecipe(mainGroup, recipeID, i)
					end
					
					
					-- break recipes into lists by profession for ease of sorting
					skillData[i] = {}
				
	--					skillData[i].name = skillName
					skillData[i].id = recipeID					
					skillData[i].difficulty = skillType
					skillData[i].color = skill_style_type[skillType]
	--				skillData[i].category = lastHeader
					
					
--					local skillDBString = DifficultyChar[skillType]..recipeID
					
					
					local tools = { GetTradeSkillTools(i) }

					skillData[i].tools = {}
					
					local slot = 1
					for t=2,#tools,2 do
						skillData[i].tools[slot] = (tools[t] or 0)						
						slot = slot + 1
					end
					
					local cd = GetTradeSkillCooldown(i)
					
					if cd then
						skillData[i].cooldown = cd + time()		-- this is when your cooldown will be up
				
--						skillDBString = skillDBString.." cd=" .. cd + time()
					end

					local numTools = #tools+1
					
					if numTools > 1 then
						local toolString = ""
						local toolsAbsent = false
						local slot = 1
						
						for t=2,numTools,2 do
							if not tools[t] then
								toolsAbsent = true
								toolString = toolString..slot
							end
							
							slot = slot + 1
						end
						
						if toolsAbsent then										-- only point out missing tools
--							skillDBString = skillDBString.." t="..toolString
						end
					end
					
--					skillDB[i] = skillDBString
					
					Skillet.data.skillIndexLookup[player][recipeID] = i
					
--[[
					if recipeDB[recipeID] and not self.recacheRecipe[recipeID] then
						-- presumably the data is the same, so there's not much that needs to happen here.
						-- potentially, however, i could see an instance where a mod might feed tradeskill info and then "better" tradeskill info
						-- might be retrieved from the server which should over-ride the earlier tradeskill info
						-- (eg, tradeskillinfo sends skillet some data and then we learn that data was not quite up-to-date)

					else
]]
						Skillet.data.recipeList[recipeID] = {}
						
						local recipe = Skillet.data.recipeList[recipeID]
						local recipeString
						local toolString = "-"
						
						recipe.tradeID = tradeID
						recipe.spellID = recipeID
						
						recipe.name = skillName
						
						if #tools >= 1 then
							recipe.tools = { tools[1] }
							
							toolString = string.gsub(tools[1]," ", "_")
					
							for t=3,#tools,2 do
								table.insert(recipe.tools, tools[t])
								toolString = toolString..":"..string.gsub(tools[t]," ", "_")
							end
							
						end
						
						
						local itemLink = GetTradeSkillItemLink(i)
						
						if not itemLink then
							gotNil = true
							break
						end
						
						local itemString = "0"
						
						if GetItemInfo(itemLink) then
							local itemID = Skillet:GetItemIDFromLink(itemLink)
							
							local minMade,maxMade = GetTradeSkillNumMade(i)
						
							recipe.itemID = itemID
							recipe.numMade = (minMade + maxMade)/2
							
							if recipe.numMade > 1 then
								itemString = itemID..":"..recipe.numMade
							else
								itemString = itemID
							end
							
							Skillet:ItemDataAddRecipeSource(itemID,recipeID)					-- add a cross reference for the source of particular items
						else
							recipe.numMade = 1												
							recipe.itemID = 0												-- indicates an enchant
						end
						
						local reagentString = nil
						
						
						local reagentData = {}
		

						for j=1, GetTradeSkillNumReagents(i), 1 do
							local reagentName, _, numNeeded = GetTradeSkillReagentInfo(i,j)

							local reagentID = 0
							
							if reagentName then
								local reagentLink = GetTradeSkillReagentItemLink(i,j)

								reagentID = Skillet:GetItemIDFromLink(reagentLink)
							else
								gotNil = true
								break
							end
							
							reagentData[j] = {}
							
							reagentData[j].id = reagentID
							reagentData[j].numNeeded = numNeeded
							
--							if reagentString then
--								reagentString = reagentString..":"..reagentID..":"..numNeeded
--							else
--								reagentString = reagentID..":"..numNeeded
--							end
							
							Skillet:ItemDataAddUsedInRecipe(reagentID, recipeID)				-- add a cross reference for where a particular item is used
						end
						
						recipe.reagentData = reagentData
						
						if gotNil then
							self.recacheRecipe[recipeID] = true
						else
--							recipeString = tradeID.." "..itemString.." "..reagentString
							
--							if #tools then
--								recipeString = recipeString.." "..toolString
--							end
							
--							recipeDB[recipeID] = recipeString
						end
						
--					end
				end
			else
				gotNil = true
			end
		until true
		
		if gotNil and recipeID then
			self.recacheRecipe[recipeID] = true
		end
	end
	
	
	Skillet:RecipeGroupConstructDBString(mainGroup)

DebugSpam("Scan Complete")
	
--	CloseTradeSkill()
		
	Skillet:InventoryScan()
	Skillet:CalculateCraftableCounts()
	Skillet:SortAndFilterRecipes()
DebugSpam("all sorted")
	self.scanInProgress = false
	
	collectgarbage("collect")
	
	return true
--	AceEvent:TriggerEvent("Skillet_Scan_Complete", profession)
end





-- reconstruct a skill from a skillString and cache it into our system for this session
function SkilletData:GetSkill(player,trade,index)
	if player and trade and index then
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][trade] then
			Skillet.data.skillList[player][trade] = {}
		end
		
		if not Skillet.data.skillList[player][trade][index] then	
			local skillString = Skillet.db.server.skillDB[player][trade][index]
			
			if skillString then
				local skill = {}
				
				local data = { string.split(" ",skillString) }
				
				if data[1] == "header" then
					skill.id = 0
				else
					local difficulty = string.sub(data[1],1,1)
					local recipeID = string.sub(data[1],2)
					
					skill.id = recipeID
					skill.difficulty = DifficultyText[difficulty]
					skill.color = skill_style_type[DifficultyText[difficulty]]
					skill.tools = nil
					
					for i=2,#data do
						local subData = { string.split("=",data[i]) }
						
						if subData[1] == "cd" then
							skill.cooldown = tonumber(subData[2])

						elseif subData[1] == "t" then
							local recipe = Skillet:GetRecipe(recipeID)
						
							skill.tools = {}
							
							for j=1,string.len(subData[2]) do
								local missingTool = tonumber(string.sub(subData[2],j,j))
								skill.tools[missingTool] = true
							end
						end
					end
				end
				
				Skillet.data.skillList[player][trade][index] = skill
			end
		end
		
		return Skillet.data.skillList[player][trade][index]
	end
end


-- collects generic tradeskill data (id to name and name to id)
function Skillet:CollectTradeSkillData()
	for i=1,#TradeSkillList,1 do
		local id = TradeSkillList[i]
		local name, _, icon = GetSpellInfo(id)
		
		TradeSkillIDsByName[name] = id
	end

	self.tradeSkillIDsByName = TradeSkillIDsByName
	self.tradeSkillList = TradeSkillList
end


-- this routine collects the basic data (which tradeskills a player has)
-- clean = true means wipe the old data
function SkilletData:ScanPlayerTradeSkills(player, clean)	
	if player == (UnitName("player")) then			            -- only for active player

		if clean or not Skillet.db.server.skillRanks[player] then
			Skillet.db.server.skillRanks[player] = {}
		end
		
		local skillRanksData = Skillet.db.server.skillRanks[player]
		
		for i=1,#TradeSkillList,1 do

			local id = TradeSkillList[i]
			local name = GetSpellInfo(id)			            -- always returns data
			local _, rankName, icon = GetSpellInfo(name)		    -- only returns data if you have this spell in your spellbook
	
			
DebugSpam("collecting tradeskill data for "..name.." "..(rank or "nil"))

			if rankName then
				if not skillRanksData[id] then
					skillRanksData[id] = ""
				end
			else
				skillRanksData[id] = nil	
			end
		end
	end

	
	return Skillet.db.server.skillRanks[player]
end



-- this routine collects the basic data (which tradeskills a player has)
-- clean = true means wipe the old data
function SkilletLink:ScanPlayerTradeSkills(player, clean)	
	local isLinked, playerLinked = IsTradeSkillLinked()
	
	if isLinked and player == playerLinked then
		return true
	end
end


function Skillet:EnableDataGathering(addon)
	self:RegisterEvent("CHAT_MSG_SKILL")
	self:RegisterEvent("CHAT_MSG_SYSTEM")
	self:RegisterEvent("TRADE_SKILL_UPDATE")
	
	self.dataScanned = false
	
	self:CollectTradeSkillData()
	
	self:RegisterRecipeDatabase("sk",SkilletData)
	
	if self.db.server.skillRanks then
		for player in pairs(self.db.server.skillRanks) do
			self:RegisterPlayerDataGathering(player,SkilletData,"sk")
		end
	end
	
	self:RegisterPlayerDataGathering((UnitName("player")),SkilletData, "sk")		-- make sure to add the current player as well
	
	
	
	
	SkilletTSI:Enable()
end
	


function Skillet:EnableQueue(addon)
	assert(tostring(addon),"Usage: EnableDataGathering('addon')")
--	self.queueaddons[addon] = true
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED",   "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_FAILED",      "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "StopCastCheckUnit")
	self:RegisterEvent("UNIT_SPELLCAST_STOPPED",     "StopCastCheckUnit")
--	if not self.queue then
--		self.queue = {}
--	end
--	self.queueenabled = true
end


function Skillet:DisableQueue(addon)
--[[	if not addon then
		self.queue = nil
		self.queueaddons = {}
		self.queueenabled = false
		return
	end
	assert(tostring(addon),"Usage: DisableDataGathering(['addon'])")
	self.queueaddons[addon] = false
	if next(self.queueaddons) then
		return
	end
]]--
	self:UnregisterEvent("UNIT_SPELLCAST_SUCCEEDED")
	self:UnregisterEvent("UNIT_SPELLCAST_FAILED")
	self:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED")
	self:UnregisterEvent("UNIT_SPELLCAST_STOPPED")
--	self.queueenabled = false
--	self.queue = nil
end


-- takes a profession and a skill index and returns the recipe
function Skillet:GetRecipeDataByTradeIndex(tradeID, index)
	if not tradeID or not index then
		return self.unknownRecipe
	end
	
	local skill = self:GetSkill(self.currentPlayer, tradeID, index)
	
	if skill then 
		local recipeID = skill.id
		
		if recipeID then
	--		local recipeData = self.db.account.recipeData[recipeID] or selfUnknownRecipe
			local recipeData = self:GetRecipe(recipeID)
			
			return recipeData, recipeData.spellID
		end
	end
end


function Skillet:StopCastCheckUnit(unit, spell, rank)
DebugSpam(event.." "..(unit or "nil"))
	if unit == "player" then
		self:StopCast(spell)
--		AceEvent:ScheduleEvent("Skillet_StopCast", self.StopCast, 0.1,self,event,spell)
	end
end


-- Internal
function Skillet:Skillet_AutoRescan()
local start = GetTime()
DebugSpam("AUTO RESCAN")
	if InCombatLockdown() then
		return
	end

	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
	end

	self:RescanTrade()
	
	self:UpdateTradeSkillWindow()
DebugSpam("AUTO RESCAN COMPLETE")

local elapsed = GetTime() - start

--DEFAULT_CHAT_FRAME:AddMessage("Skillet Auto-Rescan: "..(math.floor(elapsed*100+.5)/100).." seconds")
end


function Skillet:TRADE_SKILL_UPDATE()
--DEFAULT_CHAT_FRAME:AddMessage("TRADE_SKILL_UPDATE "..(event or "nil"))
--	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
--		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
--	end
	
--	AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
end


function Skillet:CHAT_MSG_SKILL()
--DEFAULT_CHAT_FRAME:AddMessage("CHAT_MSG_SKILL "..(event or "nil"))
--	self:Skillet_AutoRescan()									-- the problem here is that the message comes before the actuality, it seems
	if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
		AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
	end
	
	AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
end

function Skillet:CHAT_MSG_SYSTEM()
	local cutString = string.sub(1,(string.find(ERR_LEARN_RECIPE_S,"%s")))
--DebugSpam("CHAT_MSG_SYSTEM "..(arg1 or "nil").." vs "..cutString)
	if arg1 and string.find(arg1, cutString) then
--		self:Skillet_AutoRescan()								-- the problem here is that the message comes before the actuality, it seems
		if AceEvent:IsEventScheduled("Skillet_AutoRescan") then
			AceEvent:CancelScheduledEvent("Skillet_AutoRescan")
		end

		AceEvent:ScheduleEvent("Skillet_AutoRescan", self.Skillet_AutoRescan, 0.5,self)
	end
end



function Skillet:CalculateCraftableCounts(playerOverride)
DebugSpam("CalculateCraftableCounts")
	local player = playerOverride or self.currentPlayer
--	local skillDB = self.db.server.skillDB[player][self.currentTrade]
DebugSpam((player or "nil").." "..(self.currentTrade or "nil"))

DebugSpam("recalculating crafting counts")
	self.visited = {}
	

	for i=1,self:GetNumSkills(player, self.currentTrade) do
		local skill = self:GetSkill(player, self.currentTrade, i)
		
		if skill then			-- skip headers
			skill.numCraftable, skill.numCraftableVendor, skill.numCraftableBank, skill.numCraftableAlts = self:InventorySkillIterations(self.currentTrade, i, player)
		end
	end

DebugSpam("CalculateCraftableCounts Complete")
end





function Skillet:RescanTrade(force)
DebugSpam("RescanTrade")
	if not self.currentPlayer or not self.currentTrade then return end
	
	local dataModule = self.dataGatheringModules[self.currentPlayer]
	
	if dataModule and dataModule.RescanTrade then
		return dataModule.RescanTrade(dataModule, force)
	end	
end



-- Triggers a rescan of the currently selected tradeskill
function SkilletLink:RescanTrade(force)

	if not Skillet.currentPlayer or not Skillet.currentTrade then return end
	
	local player, tradeID = Skillet.currentPlayer, Skillet.currentTrade


	if not Skillet.data.skillList[player] then
		Skillet.data.skillList[player] = {}
	end
	
	if not Skillet.data.skillList[player][tradeID] then
		Skillet.data.skillList[player][tradeID]={}
	end
	

	if force then
DebugSpam("Forced Rescan")
--			self.db.server.skillRanks[self.currentPlayer]={}
		Skillet.data.skillList[player]={}
--			self.db.server.skillDB[self.currentPlayer]={}
--			self.db.server.groupDB = {}

		Skillet:InitializeDatabase(player, true)
	end

	
	Skillet:ScanQueuedReagents()

	self:ScanTrade()

	Skillet.dataScanned = true
		
	DebugSpam("TRADESKILL HAS BEEN SCANNED")
end




-- Triggers a rescan of the currently selected tradeskill
function SkilletData:RescanTrade(force)
--	if not SkilletFrame:IsVisible() then
--DebugSpam("Skillet frame not open")
--		return
--	end
	
	if not Skillet.currentPlayer or not Skillet.currentTrade then return end
	
	local player, tradeID = Skillet.currentPlayer, Skillet.currentTrade
	
--	self:InitializeDatabase(self.currentPlayer, false)
	
	if player == (UnitName("player")) then			-- only allow actual skill rescans of current player data
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][tradeID] then
			Skillet.data.skillList[player][tradeID]={}
		end
		
					
		if not Skillet.db.server.skillDB[player] then
			Skillet.db.server.skillDB[player] = {}
		end
	
		if not Skillet.db.server.skillDB[player][tradeID] then
			Skillet.db.server.skillDB[player][tradeID] = {}
		end
		
		if force then
DebugSpam("Forced Rescan")
--			self.db.server.skillRanks[self.currentPlayer]={}
			Skillet.data.skillList[player]={}
--			self.db.server.skillDB[self.currentPlayer]={}
--			self.db.server.groupDB = {}

			Skillet:InitializeDatabase(player, true)
			
			local firstSkill
			
			for id,list in pairs(Skillet.db.server.skillRanks[player]) do
				if not firstSkill then
					firstSkill = id
				end
				
				Skillet.data.skillList[player][id] = {}
				Skillet.db.server.skillDB[player][id] = {}
			end
            
			Skillet.data.skillIndexLookup[player] = {}
				
			if not Skillet.db.server.skillRanks[player] then
				Skillet.currentTrade = firstSkill
			end
		end

		
		Skillet:ScanQueuedReagents()
	
		self:ScanTrade()

		Skillet.dataScanned = true
	else				-- it's an alt, just do the inventory and craftability update stuff
		Skillet:ScanQueuedReagents()
		Skillet:InventoryScan()
		Skillet:CalculateCraftableCounts()
		
		Skillet.dataScanned = true
	end
		
	DebugSpam("TRADESKILL HAS BEEN SCANNED")
end





function SkilletData:ScanTrade()
DebugSpam("ScanTrade")
	if self.scanInProgress == true then
DebugSpam("SCAN BUSY!")
		return
	end
	
	self.scanInProgress = true
	
	local tradeID
	
	local API = {}
	
	local profession, rank, maxRank = GetTradeSkillLine()
DebugSpam("GetTradeSkill: "..(profession or "nil"))


	API.GetNumSkills = GetNumTradeSkills
	API.ExpandLine = ExpandTradeSkillSubClass
	API.GetRecipeLink = GetTradeSkillRecipeLink
	API.GetTools = GetTradeSkillTools
	API.GetCooldown = GetTradeSkillCooldown
	API.GetItemLink = GetTradeSkillItemLink
	API.GetNumMade = GetTradeSkillNumMade
	API.GetNumReagents = GetTradeSkillNumReagents
	API.GetReagentInfo = GetTradeSkillReagentInfo
	API.GetReagentLink = GetTradeSkillReagentItemLink
	
	-- get the tradeID from the profession name (data collected earlier).
	tradeID = TradeSkillIDsByName[profession] or 2656				-- "mining" doesn't exist as a spell, so instead use smelting (id 2656)
	
--[[
	if profession ~= GetSpellName(tradeID) then
		DEFAULT_CHAT_FRAME:AddMessage("Skillet Error in Trade ID "..(profession or "nil").." ("..tradeID..")")
		self.scanInProgress = false
		return
	end
]]	
	
	if tradeID ~= Skillet.currentTrade then
DebugSpam("TRADE MISMATCH for player "..(Skillet.currentPlayer or "nil").."!  "..(tradeID or "nil").." vs "..(Skillet.currentTrade or "nil"));
	end

	
	local player = Skillet.currentPlayer
	
	if not self.recacheRecipe then
		self.recacheRecipe = {}
	end
	

	if not IsTradeSkillLinked() then
		Skillet.db.server.skillRanks[player][tradeID] = rank.." "..maxRank
	end
	
	
	self:ResetTradeSkillFilter()						-- verify the search filter is blank (so we get all skills)

	
	local numSkills = API.GetNumSkills()
	

DebugSpam("Scanning Trade "..(profession or "nil")..":"..(tradeID or "nil").." "..numSkills.." recipes")

	if not Skillet.data.skillIndexLookup[player] then
		Skillet.data.skillIndexLookup[player] = {}
	end
	
	local skillDB = Skillet.db.server.skillDB[player][tradeID]
	local skillData = Skillet.data.skillList[player][tradeID]
	local recipeDB = Skillet.db.account.recipeDB
	
	local lastHeader = nil
	local gotNil = false
	
	local currentGroup = nil
	
	local mainGroup = Skillet:RecipeGroupNew(player,tradeID,"Blizzard")
	
	mainGroup.locked = true
	
	Skillet:RecipeGroupClearEntries(mainGroup)
	
	local groupList = {}
	
	
	for i = 1, numSkills, 1 do
		repeat
--DebugSpam("scanning index "..i)
			local skillName, skillType, isExpanded, subSpell, extra
			
			
			skillName, skillType, _, isExpanded = GetTradeSkillInfo(i)
			
			
--DebugSpam("**** skill: "..(skillName or "nil"))

			gotNil = false
		
			
			if skillName then
				if skillType == "header" then
					if not isExpanded then
						API.ExpandLine(i)
					end

					local groupName
					
					if groupList[skillName] then
						groupList[skillName] = groupList[skillName]+1
						groupName = skillName.." "..groupList[skillName]
					else
						groupList[skillName] = 1
						groupName = skillName
					end
					
					skillDB[i] = "header "..skillName
					skillData[i] = nil
					
					currentGroup = Skillet:RecipeGroupNew(player, tradeID, "Blizzard", groupName)
					
					Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
				else
					local recipeLink = API.GetRecipeLink(i)
					local recipeID = Skillet:GetItemIDFromLink(recipeLink)
					
					if not recipeID then
						gotNil = true
						break
					end
					
					if currentGroup then
						Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, i)
					else
						Skillet:RecipeGroupAddRecipe(mainGroup, recipeID, i)
					end
					
					
					-- break recipes into lists by profession for ease of sorting
					skillData[i] = {}
				
	--					skillData[i].name = skillName
					skillData[i].id = recipeID					
					skillData[i].difficulty = skillType
					skillData[i].color = skill_style_type[skillType]
	--				skillData[i].category = lastHeader
					
					
					local skillDBString = DifficultyChar[skillType]..recipeID
					
					
					local tools = { API.GetTools(i) }

					skillData[i].tools = {}
					
					local slot = 1
					for t=2,#tools,2 do
						skillData[i].tools[slot] = (tools[t] or 0)						
						slot = slot + 1
					end
					
					local cd = API.GetCooldown(i)
					
					if cd then
						skillData[i].cooldown = cd + time()		-- this is when your cooldown will be up
				
						skillDBString = skillDBString.." cd=" .. cd + time()
					end

					local numTools = #tools+1
					
					if numTools > 1 then
						local toolString = ""
						local toolsAbsent = false
						local slot = 1
						
						for t=2,numTools,2 do
							if not tools[t] then
								toolsAbsent = true
								toolString = toolString..slot
							end
							
							slot = slot + 1
						end
						
						if toolsAbsent then										-- only point out missing tools
							skillDBString = skillDBString.." t="..toolString
						end
					end
					
					skillDB[i] = skillDBString
					
					Skillet.data.skillIndexLookup[player][recipeID] = i
					
					if recipeDB[recipeID] and not self.recacheRecipe[recipeID] then
						-- presumably the data is the same, so there's not much that needs to happen here.
						-- potentially, however, i could see an instance where a mod might feed tradeskill info and then "better" tradeskill info
						-- might be retrieved from the server which should over-ride the earlier tradeskill info
						-- (eg, tradeskillinfo sends skillet some data and then we learn that data was not quite up-to-date)

					else
						Skillet.data.recipeList[recipeID] = {}
						
						local recipe = Skillet.data.recipeList[recipeID]
						local recipeString
						local toolString = "-"
						
						recipe.tradeID = tradeID
						recipe.spellID = recipeID
						
						recipe.name = skillName
						
						if #tools >= 1 then
							recipe.tools = { tools[1] }
							
							toolString = string.gsub(tools[1]," ", "_")
					
							for t=3,#tools,2 do
								table.insert(recipe.tools, tools[t])
								toolString = toolString..":"..string.gsub(tools[t]," ", "_")
							end
							
						end
						
						
						local itemLink = API.GetItemLink(i)
						
						if not itemLink then
							gotNil = true
							break
						end
						
						local itemString = "0"
						
						if GetItemInfo(itemLink) then
							local itemID = Skillet:GetItemIDFromLink(itemLink)
							
							local minMade,maxMade = API.GetNumMade(i)
						
							recipe.itemID = itemID
							recipe.numMade = (minMade + maxMade)/2
							
							if recipe.numMade > 1 then
								itemString = itemID..":"..recipe.numMade
							else
								itemString = itemID
							end
							
							Skillet:ItemDataAddRecipeSource(itemID,recipeID)					-- add a cross reference for the source of particular items
						else
							recipe.numMade = 1												
							recipe.itemID = 0												-- indicates an enchant
						end
						
						local reagentString = nil
						
						
						local reagentData = {}
		

						for j=1, API.GetNumReagents(i), 1 do
							local reagentName, _, numNeeded = API.GetReagentInfo(i,j)

							local reagentID = 0
							
							if reagentName then
								local reagentLink = API.GetReagentLink(i,j)

								reagentID = Skillet:GetItemIDFromLink(reagentLink)
							else
								gotNil = true
								break
							end
							
							reagentData[j] = {}
							
							reagentData[j].id = reagentID
							reagentData[j].numNeeded = numNeeded
							
							if reagentString then
								reagentString = reagentString..":"..reagentID..":"..numNeeded
							else
								reagentString = reagentID..":"..numNeeded
							end
							
							Skillet:ItemDataAddUsedInRecipe(reagentID, recipeID)				-- add a cross reference for where a particular item is used
						end
						
						recipe.reagentData = reagentData
						
						if gotNil then
							self.recacheRecipe[recipeID] = true
						else
							recipeString = tradeID.." "..itemString.." "..reagentString
							
							if #tools then
								recipeString = recipeString.." "..toolString
							end
							
							recipeDB[recipeID] = recipeString
						end
						
					end
				end
			else
				gotNil = true
			end
		until true
		
		if gotNil and recipeID then
			self.recacheRecipe[recipeID] = true
		end
	end
	
	
	Skillet:RecipeGroupConstructDBString(mainGroup)

DebugSpam("Scan Complete")
	
--	CloseTradeSkill()
		
	Skillet:InventoryScan()
	Skillet:CalculateCraftableCounts()
	Skillet:SortAndFilterRecipes()
DebugSpam("all sorted")
	self.scanInProgress = false
	
	collectgarbage("collect")
	
	return true
--	AceEvent:TriggerEvent("Skillet_Scan_Complete", profession)
end


function SkilletData:EnchantingRecipeSlotAssign(recipeID, slot)
	local recipeString = Skillet.db.account.recipeDB[recipeID]
		
	local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
	
	if itemString == "0" then
		itemString = "0:"..slot
		
		Skillet.db.account.recipeDB[recipeID] = tradeID.." 0:"..slot.." "..reagentString.." "..toolString
		
		Skillet:GetRecipe(recipeID)
--DEFAULT_CHAT_FRAME:AddMessage(Skillet.data.recipeList[recipeID].name or "noName")
			
		Skillet.data.recipeList[recipeID].slot = slot
	end
end



local invSlotLookup = {
	["HEADSLOT"] = "HeadSlot",
	["NECKSLOT"] = "NeckSlot",
	["SHOULDERSLOT"] = "ShoulderSlot",
	["CHESTSLOT"] = "ChestSlot",
	["WAISTSLOT"] = "WaistSlot",
	["LEGSSLOT"] = "LegsSlot",
	["FEETSLOT"] = "FeetSlot",
	["WRISTSLOT"] = "WristSlot",
	["HANDSSLOT"] = "HandsSlot",
	["FINGER0SLOT"] = "Finger0Slot",
	["TRINKET0SLOT"] = "Trinket0Slot",
	["BACKSLOT"] =	"BackSlot",
	["ENCHSLOT_WEAPON"] = "MainHandSlot",
	["ENCHSLOT_2HWEAPON"] = "MainHandSlot",
	["SHIELDSLOT"] = "SecondaryHandSlot",
}



function SkilletData:ScanEnchantingGroups(mainGroup)
	local groupList = {}
	
	if mainGroup then	
		local craftSlots = { GetCraftSlots() }
		
		Skillet:RecipeGroupClearEntries(mainGroup)
		
		for i=1,#craftSlots do
			local groupName
			local slotName = getglobal(craftSlots[i])
			
			local invSlot
			
			if groupList[slotName] then
				groupList[slotName] = groupList[slotName]+1
				groupName = slotName.." "..groupList[slotName]
			else
				groupList[slotName] = 1
				groupName = slotName
			end
					
			local currentGroup = Skillet:RecipeGroupNew(Skillet.currentPlayer, 7411, "Blizzard", groupName)			-- 7411 = enchanting
			
			SetCraftFilter(i+1)
			
			for s=1,GetNumCrafts() do
				local recipeLink = GetCraftRecipeLink(s)
				local recipeID = Skillet:GetItemIDFromLink(recipeLink)
				
				if craftSlots[i] ~= "NONEQUIPSLOT" then
					invSlot = GetInventorySlotInfo(invSlotLookup[craftSlots[i]])
					self:EnchantingRecipeSlotAssign(recipeID, invSlot)
				end
				
DebugSpam("adding "..(recipeLink or "nil").." to "..groupName)				
				Skillet:RecipeGroupAddRecipe(currentGroup, recipeID, Skillet.data.skillIndexLookup[Skillet.currentPlayer][recipeID])
				
--				local e = Skillet:RecipeGroupFindRecipe(mainGroup, "sk/"..recipeID)
--				
--				if e then
--					Skillet:RecipeGroupMoveEntry(e, currentGroup)
--				end
			end
			
			Skillet:RecipeGroupAddSubGroup(mainGroup, currentGroup, i)
		end
	end
	
	SetCraftFilter(1)
end



function SkilletData:RecipeGroupGenerateAutoGroups()
	Skillet:RecipeGroupDeconstructDBStrings()
end



function SkilletLink:RecipeGroupGenerateAutoGroups()
	Skillet:RecipeGroupDeconstructDBStrings()
end



-- tsi hooks



SkilletTSI = {}




local TSITradeIDs = {
	A = 2259,           -- alchemy
	B = 2018,           -- blacksmithing
	D = 7411,           -- enchanting 
	E = 4036,           -- engineering
	J = 25229,          -- jewelcrafting
	L = 2108,           -- leatherworking
--	2575,			-- mining (or smelting?)
	Y = 2656,           -- smelting (from mining)
	T = 3908,           -- tailoring
	W = 2550,           -- cooking
	X = 3273,           -- first aid
--	Z = 2842,           -- poisons
}




-- this routine collects the basic data (which tradeskills a player has)
-- clean = true means wipe the old data
function SkilletTSI:ScanPlayerTradeSkills(player, clean)
	if not self.data then
		self.data = {}
	end

	if not self.data.skillRanks then
		self.data.skillRanks = {}
		self.data.skillList = {}
		
		local skillRanksData = self.data.skillRanks
DebugSpam("tsi: "..player)

		for i=1,#TradeSkillList do

			local id = TradeSkillList[i]
			local name, rankName, icon = GetSpellInfo(id)			            -- always returns data

			skillRanksData[id] = "1 375"
			
			Skillet:SetTradeSkillOption("grouping","Flat",player,id)
			
			self.data.skillList[id] = {}
		end

		Skillet.data.skillIndexLookup[player] = {}

		local skillList = self.data.skillList
		
		for i in pairs(TradeskillInfo.vars.combines) do
			local t = TradeskillInfo:GetCombineSkill(i)
			
			local tradeID = TSITradeIDs[t]
DebugSpam((t or "nil") .. " = "..(tradeID or "nil"))
			
			if tradeID then
				skillList[tradeID][#skillList[tradeID] + 1] = i
			
				Skillet.data.skillIndexLookup[player]["tsi/"..i] = #skillList[tradeID]
			end
		end
	end
	
	return self.data.skillRanks
end





-- reconstruct a recipe from a recipeString and cache it into our system for this session
function SkilletTSI:GetRecipe(id)
	if not id or id == 0 then return self.unknownRecipe end
	
	id = tonumber(id)
	
	if not self.data.recipeList then
		self.data.recipeList = {}
	end
	
	if id and TradeskillInfo.vars.combines[id]  then	-- should i cache it?
		local spellID = TradeskillInfo:GetCombineEnchantId(id)
	
		if not self.data.recipeList[id] then
			local found, _, skill, spec, level, components, recipe, yield, item = string.find(TradeskillInfo.vars.combines[id],"%d*|?(%u)(%l*)(%d+)|([^|]+)[|]?(%d*)[|]?([^|]*)[|]?(%d*)")
			
			local recipe = {}
			
			recipe.spellID = spellID
			
			recipe.name = TradeskillInfo:GetCombineName(id)
				
--DebugSpam("name ".. recipe.name)
		
			recipe.tradeID = TSITradeIDs[skill]
			
			if id>0 then
				recipe.itemID = tonumber(item) or id
			else
				recipe.itemID = 0
			end
			
			recipe.numMade = tonumber(yield) or 1
			
			local reagentData = {}
	--DebugSpam(recipe.name or "nil")

			for s in string.gmatch(components,"%S+") do
				local _,_,i,num = string.find(s,"(%d+):(%d+)")
				local data = {}
				
				data.id = tonumber(i) or tonumber(s)
				data.numNeeded = tonumber(num) or 1
				
				reagentData[#reagentData+1] = data
			
			end
			
			recipe.reagentData = reagentData
			
			self.data.recipeList[id] = recipe
		end
		
		return self.data.recipeList[id]
	end
	
	return self.unknownRecipe
end

--[[
function SkilletTSI:CollectRecipeData()
	for recipeID, recipeString in pairs(self.db.account.recipeDB) do

		local tradeID, itemString, reagentString, toolString = string.split(" ",recipeString)
		local itemID, numMade = 0, 1
		local slot = nil
		
		if itemString ~= "0" then
			local a, b = string.split(":",itemString)
			
			if a ~= "0" then 
				itemID, numMade = a,b
			else
				itemID = 0
				numMade = 1
				slot = tonumber(b)
			end
			
			if not numMade then
				numMade = 1
			end
		end
		
		itemID = tonumber(itemID)
		
		if itemID ~= 0 then
			self:ItemDataAddRecipeSource(itemID, recipeID)
		end
		

		local reagentList = { string.split(":",reagentString) }
		local numReagents = #reagentList / 2
		
		for i=1,numReagents do
			local reagentID = tonumber(reagentList[1 + (i-1)*2])
			
			self:ItemDataAddUsedInRecipe(reagentID, recipeID)
		end
	end
	
	
	for player,tradeList in pairs(self.db.server.skillDB) do
		self.data.skillIndexLookup[player] = {}
		
		for trade,skillList in pairs(tradeList) do
			for i=1,#skillList do
--				local skillData = self:GetSkill(player, trade, i)
				local skillString = self.db.server.skillDB[player][trade][i]

				local data = { string.split(" ",skillString) }
				
				if data[1] ~= "header" then
					local recipeID = string.sub(data[1],2)
				
					self.data.skillIndexLookup[player][recipeID] = i
				end
			end
		end
	end
]]

-- reconstruct a skill from a skillString and cache it into our system for this session
function SkilletTSI:GetSkill(player,trade,index)
	if player and trade and index then
		
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][trade] then
			Skillet.data.skillList[player][trade] = {}
		end
		
		if not Skillet.data.skillList[player][trade][index] then
			local skill = {}

--DebugSpam("new skill ".. index)
	
			local skillList = self.data.skillList[trade]
			
			local difficulty = "o" -- string.sub(data[1],1,1)
			local recipeID = skillList[index]
			
		
			
--DebugSpam("recipe ".. (recipeID or "nil"))



			skill.id = (recipeID or 0)
			skill.difficulty = DifficultyText[difficulty]
			skill.color = skill_style_type[DifficultyText[difficulty]]
			skill.tools = nil
			
				
			Skillet.data.skillList[player][trade][index] = skill
		end
		
		return Skillet.data.skillList[player][trade][index]
	end
	
DebugSpam("can't find skill "..player.." "..(trade or "nil").." "..(index or "nil"))
end


function SkilletTSI:GetSkillRanks(player, trade)
	return self.data.skillRanks[trade]
end


function SkilletTSI:GetNumSkills(player, trade)
	return #self.data.skillList[trade]
end

	
function SkilletTSI:GetRecipeName(id)
	return TradeskillInfo:GetCombineName(id), TradeskillInfo:GetCombineEnchantId(id)
end
	
	
function SkilletTSI:RescanTrade(force)
	if not Skillet.currentPlayer or not Skillet.currentTrade then return end
	
	local player, tradeID = Skillet.currentPlayer, Skillet.currentTrade
	
	self:RecipeGroupGenerateAutoGroups()
	
	if player == (UnitName("player")) then			-- only allow actual skill rescans of current player data
		if not Skillet.data.skillList[player] then
			Skillet.data.skillList[player] = {}
		end
		
		if not Skillet.data.skillList[player][tradeID] then
			Skillet.data.skillList[player][tradeID]={}
		end
		
					
		if not Skillet.db.server.skillDB[player] then
			Skillet.db.server.skillDB[player] = {}
		end
	
		if not Skillet.db.server.skillDB[player][tradeID] then
			Skillet.db.server.skillDB[player][tradeID] = {}
		end
		
		if force then
DebugSpam("Forced Rescan")
--			self.db.server.skillRanks[self.currentPlayer]={}
			Skillet.data.skillList[player]={}
--			self.db.server.skillDB[self.currentPlayer]={}
--			self.db.server.groupDB = {}

			Skillet:InitializeDatabase(player, true)
			
			local firstSkill
			
			for id,list in pairs(Skillet.db.server.skillRanks[player]) do
				if not firstSkill then
					firstSkill = id
				end
				
				Skillet.data.skillList[player][id] = {}
				Skillet.db.server.skillDB[player][id] = {}
			end
            
			Skillet.data.skillIndexLookup[player] = {}
				
			if not Skillet.db.server.skillRanks[player] then
				Skillet.currentTrade = firstSkill
			end
		end

		
		Skillet:ScanQueuedReagents()
	
		self:ScanTrade()

		Skillet.dataScanned = true
	else				-- it's an alt, just do the inventory and craftability update stuff
		Skillet:ScanQueuedReagents()
		Skillet:InventoryScan()
		Skillet:CalculateCraftableCounts()
		
		Skillet.dataScanned = true
	end
		
	DebugSpam("TRADESKILL HAS BEEN SCANNED")
end	


function SkilletTSI:RecipeGroupGenerateAutoGroups()
	local tradeID = Skillet.currentTrade
	local player = Skillet.currentPlayer
	
	local knownRecipes = {}
	local unknownRecipes = {}
	
	for label in pairs(Skillet.dataGatheringModules) do
		local rankString = Skillet:GetSkillRanks(label, tradeID)
	
		if label ~= "tsiData" and rankString then
			Skillet:InitGroupList(player, tradeID, label, true)
			
			if label == Skillet.currentGroupLabel then
				
				local mainGroup =  Skillet:RecipeGroupNew(player, tradeID, label)
				
			
				
				if not mainGroup.initialized then
					mainGroup.initialized = true
					
					local rank = string.split(" ", rankString)
					
					rank = tonumber(rank)
					
					-- first, accumulate all tsiData
					for id, skill in pairs(Skillet.data.skillList[player][tradeID]) do
						local recipeID = skill.id
						
						local spellID = TradeskillInfo:GetCombineEnchantId(tonumber(recipeID))
						
						unknownRecipes[spellID] = skill.id
					end


					-- then, move over all known recipes for this toon
					local numSkills = #Skillet.db.server.skillDB[label][tradeID]
					
					for i=1, numSkills do
						local skill = Skillet:GetSkill(label, tradeID, i)
						if skill and skill.id ~= 0 then
							local recipe = Skillet:GetRecipe(skill.id)
						
							knownRecipes[recipe.spellID] = unknownRecipes[recipe.spellID]
							unknownRecipes[recipe.spellID] = nil
						end
					end
					
					
					local knownGroup = Skillet:RecipeGroupNew(player, tradeID, label, "Known Recipes")
					local unknownGroup = Skillet:RecipeGroupNew(player, tradeID, label, "Unknown Recipes")
				
					Skillet:RecipeGroupAddSubGroup(mainGroup, knownGroup, 1)
					Skillet:RecipeGroupAddSubGroup(mainGroup, unknownGroup, 2)
					
					
					for spellID,recipeID in pairs(unknownRecipes) do
						local index = Skillet.data.skillIndexLookup[player][recipeID]
					
						local entry = Skillet:RecipeGroupAddRecipe(unknownGroup, recipeID, index)
						
						entry.color = Skillet:GetTradeSkillLevelColor(spellID, rank)
						
						if entry.color then
							entry.difficulty = entry.color.level
						end
					end
				
					for spellID,recipeID in pairs(knownRecipes) do
						local index = Skillet.data.skillIndexLookup[player][recipeID]
--DEFAULT_CHAT_FRAME:AddMessage("adding "..recipeID.." "..(index or "nil"))					
						local entry = Skillet:RecipeGroupAddRecipe(knownGroup, recipeID, index)
						
						entry.color = Skillet:GetTradeSkillLevelColor(spellID, rank)
						
						if entry.color then
							entry.difficulty = entry.color.level
						end
					end
				end
			end

		end
	end
	
	knownRecipes = nil
	unknownRecipes = nil
	
	DebugSpam("done making groups")
end


--[[
<CheckButton name="SkilletInvFilterButtonTemplate" virtual="true">
		<Size>
			<AbsDimension x="20" y="20"/>
		</Size>
		
		<CheckedTexture name="$parentChecked" alphaMode="ADD" file="Interface\Addons\Skillet\Icons\highlight.tga"/>

		<HighlightTexture alphaMode="ADD" file="Interface\Buttons\ButtonHilight-Square"/>
		
		<Scripts>
			<OnLoad>
				this:SetFrameLevel(this:GetFrameLevel()+5)
			</OnLoad>
			<OnLeave>
				Skillet:InventoryFilterButton_OnLeave(this)
			</OnLeave>
			<OnEnter>
				Skillet:InventoryFilterButton_OnEnter(this)
			</OnEnter>
			<OnClick>
				Skillet:InventoryFilterButton_OnClick(this)
			</OnClick>
			<OnShow>
				Skillet:InventoryFilterButton_OnShow(this)
			</OnShow>
		</Scripts>
	</CheckButton>

			<CheckButton name="SkilletHideUncraftableRecipes" hidden="false">
				
				</Layers>
				
				<Scripts>
					<OnShow>
						local hideUncraftable = Skillet:GetTradeSkillOption("hideuncraftable")
						
						if hideUncraftable then
							this:SetChecked(1)
						else
							this:SetChecked(0)
						end
					</OnShow>
					<OnLoad>
						this:RegisterForClicks("LeftButtonUp","RightButtonUp")
					</OnLoad>
					<OnClick>
						if arg1=="LeftButton" then
							Skillet:InventoryFilterButtons_Hide()	
							if this:GetChecked() then
								PlaySound("igMainMenuOptionCheckBoxOn");
							end
							local before = Skillet:GetTradeSkillOption("hideuncraftable")
							Skillet:SetTradeSkillOption("hideuncraftable", not before)
							Skillet:SortAndFilterRecipes()
							Skillet:UpdateTradeSkillWindow()
						else
							if SkilletInventoryFilterBag:IsVisible() then
								Skillet:InventoryFilterButtons_Hide()
							else
								Skillet:InventoryFilterButtons_Show()
							end
							
							if Skillet:GetTradeSkillOption("hideuncraftable") then
								this:SetChecked(1)
							else
								this:SetChecked(0)
							end
						end
						
					</OnClick>
	
					<OnEnter>
						GameTooltip:SetOwner(this, "ANCHOR_TOPLEFT")
						GameTooltip:SetText(CRAFT_IS_MAKEABLE_TOOLTIP, nil, nil, nil, nil, 1)
						GameTooltip:AddLine("Left-Click to toggle")
						GameTooltip:AddLine("Right-Click for filtering options")
						GameTooltip:Show()
					</OnEnter>
					<OnLeave>
						GameTooltip:Hide()
					</OnLeave>
				</Scripts>
			</CheckButton>

			
			<!--
				inventory filter selector
			-->
			
			
			<CheckButton name="SkilletInventoryFilterBag" inherits="SkilletInvFilterButtonTemplate" hidden="true">
				<Anchors>
					<Anchor point="TOPLEFT" relativeTo="SkilletHideUncraftableRecipes" relativePoint="BOTTOMLEFT">
						<Offset>
							<AbsDimension x="-30" y="0"/>
						</Offset>
					</Anchor>
				</Anchors>
				
				<NormalTexture name="$parentIcon" file="Interface\Addons\Skillet\Icons\backpack_icon.tga"/>
				
				<Scripts>
					<OnLoad>
						this:SetFrameLevel(this:GetFrameLevel()+5)
						this.slot = "bag"
						getglobal(this:GetName().."Checked"):SetGradient("vertical",1,1,.5, 1,1,.5)
					</OnLoad>
				</Scripts>
			</CheckButton>
]]			
			

			
local function initFilterButton(name, icon, parent, slot)
	local b = CreateFrame("CheckButton", name)
	b:SetWidth(20)
	b:SetHeight(20)
	
	b:SetParent(parent)
	
	
	b:SetNormalTexture(icon)
	b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
	b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
	
	b:SetFrameLevel(this:GetFrameLevel()+5)
	
	b:SetScript("OnEnter", function(button) SkilletTSI:RecipeFilterButton_OnEnter(button) end)
	b:SetScript("OnLeave", function(button) SkilletTSI:RecipeFilterButton_OnLeave(button) end)
	b:SetScript("OnClick", function(button) SkilletTSI:RecipeFilterButton_OnClick(button) end)
	b:SetScript("OnShow", function(button) SkilletTSI:RecipeFilterButton_OnShow(button) end)
	
	b.slot = slot
	
	return b
end



function SkilletTSI:RecipeFilterButtons_Hide()
	local b = self.tsiRecipeSourceButton
	
	if b then
		b.trainerButton:Hide()
		b.vendorButton:Hide()
		b.questButton:Hide()
		b.dropButton:Hide()
	end
end



function SkilletTSI:RecipeFilterButtons_Show()
	local b = self.tsiRecipeSourceButton
	
	if b then
		b.trainerButton:Show()
		b.vendorButton:Show()
		b.questButton:Show()
		b.dropButton:Show()
	end
end




function SkilletTSI:RecipeFilterButton_OnClick(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	
	Skillet:ToggleTradeSkillOption(option)

	self:RecipeFilterButton_OnEnter(button)
	self:RecipeFilterButton_OnShow(button)
	Skillet:SortAndFilterRecipes()
	Skillet:UpdateTradeSkillWindow()
end


function SkilletTSI:RecipeFilterButton_OnEnter(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	local value = Skillet:GetTradeSkillOption(option)
	
	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")
	
	if value then
		GameTooltip:SetText(slot.." on")
	else
		GameTooltip:SetText(slot.." off")
	end
--	GameTooltip:AddLine(player,1,1,1)
		
	GameTooltip:Show()
end


function SkilletTSI:RecipeFilterButton_OnLeave(button)
	GameTooltip:Hide()
end

function SkilletTSI:RecipeFilterButton_OnShow(button)
	local slot = button.slot or ""
	local option = "recipeSourceFilter-"..slot
	
	local value = Skillet:GetTradeSkillOption(option)
	
	if value then
		button:SetChecked(1)
	else
		button:SetChecked(0)
	end
end


function SkilletTSI:RecipeFilterToggleButton_OnShow(button)
	local filter = Skillet:GetTradeSkillOption("recipeSourceFilter")

	if filter then
		this:SetChecked(1)
	else
		this:SetChecked(0)
	end
end


function SkilletTSI:RecipeFilterToggleButton_OnEnter(button)
	GameTooltip:SetOwner(button, "ANCHOR_TOPLEFT")

	GameTooltip:SetText("Filter recipes by source", nil, nil, nil, nil, 1)
	GameTooltip:AddLine("Left-Click to toggle", .7, .7, .7)
	GameTooltip:AddLine("Right-Click for filtering options", .7, .7, .7)
	GameTooltip:Show()
		
	GameTooltip:Show()
end


function SkilletTSI:RecipeFilterToggleButton_OnLeave(button)
	GameTooltip:Hide()
end



function SkilletTSI:RecipeFilterToggleButton_OnClick(button, mouse)
	if mouse=="LeftButton" then
		SkilletTSI:RecipeFilterButtons_Hide()	
		if button:GetChecked() then
			PlaySound("igMainMenuOptionCheckBoxOn");
		end
		local before = Skillet:GetTradeSkillOption("recipeSourceFilter")
		Skillet:SetTradeSkillOption("recipeSourceFilter", not before)
		Skillet:SortAndFilterRecipes()
		Skillet:UpdateTradeSkillWindow()
	else
		if TSIRecipeSourceTrainerButton:IsVisible() then
			SkilletTSI:RecipeFilterButtons_Hide()
		else
			SkilletTSI:RecipeFilterButtons_Show()
		end
		
		if Skillet:GetTradeSkillOption("recipeSourceFilter") then
			button:SetChecked(1)
		else
			button:SetChecked(0)
		end
	end
end



function SkilletTSI:RecipeSourceButtonInit()
	if not self.tsiRecipeSourceButton then

		local b = CreateFrame("CheckButton", "TSIRecipeSourceFilterButton")
		
		b:SetWidth(20)
		b:SetHeight(20)

		b:SetNormalTexture("Interface\\Icons\\INV_Scroll_03")
		b:SetPushedTexture("Interface\\Icons\\INV_Scroll_03")
		b:SetCheckedTexture("Interface\\Buttons\\CheckButtonHilight", "ADD")
		b:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		b:SetDisabledTexture("Interface\\Icons\\INV_Scroll_03")
		b:RegisterForClicks("LeftButtonUp", "RightButtonDown")
		
		self.tsiRecipeSourceButton = b
		
		b:SetScript("OnClick", function(button) SkilletTSI:RecipeFilterToggleButton_OnClick(button, arg1) end)
		b:SetScript("OnEnter", function(button) SkilletTSI:RecipeFilterToggleButton_OnEnter(button) end)
		b:SetScript("OnLeave", function(button) SkilletTSI:RecipeFilterToggleButton_OnLeave(button) end)
		b:SetScript("OnShow", function(button) SkilletTSI:RecipeFilterToggleButton_OnShow(button) end)
		
		b.trainerButton = initFilterButton("TSIRecipeSourceTrainerButton", "Interface\\Addons\\Skillet\\Icons\\vendor_icon.tga", b, "trainer")
		b.trainerButton:SetPoint("TOP", b:GetName(), "BOTTOM", -30,0)
	
		
		b.vendorButton = initFilterButton("TSIRecipeSourceVendorButton", "Interface\\Addons\\Skillet\\Icons\\vendor_icon.tga", b, "vendor")
		b.vendorButton:SetPoint("LEFT", "TSIRecipeSourceTrainerButton", "RIGHT", 0,0)
	
		
		b.questButton = initFilterButton("TSIRecipeSourceQuestButton", "Interface\\Icons\\INV_Misc_Map_01", b, "quest")
		b.questButton:SetPoint("LEFT", "TSIRecipeSourceVendorButton", "RIGHT", 0,0)

		
		b.dropButton = initFilterButton("TSIRecipeSourceQuestButton", "Interface\\Icons\\Ability_DualWield", b, "drop")
		b.dropButton:SetPoint("LEFT", "TSIRecipeSourceQuestButton", "RIGHT", 0,0)
	end
	
	local _,_,icon = GetSpellInfo(Skillet.currentTrade)
	
	if icon then
		self.tsiRecipeSourceButton.trainerButton:SetNormalTexture(icon)
	end
	
	self:RecipeFilterButtons_Hide()
	
	return self.tsiRecipeSourceButton
end



function SkilletTSI:RecipeFilterOperator(skillIndex)
	if Skillet:GetTradeSkillOption("recipeSourceFilter") then	
		local skill = Skillet:GetSkill(Skillet.currentPlayer, Skillet.currentTrade, skillIndex)
		local recipe = Skillet:GetRecipe(skill.id)
		
		local combineID = recipe.itemID

		if combineID == 0 and recipe.spellID then
			combineID = -recipe.spellID
		elseif combineID then
			combineID = TradeskillInfo:MakeSpecialCase(combineID, recipe.name)
		end
		
		if combineID then
			local recipeID = TradeskillInfo:GetCombineRecipe(combineID)
			local found, _, sources = string.find(TradeskillInfo.vars.recipes[recipeID] or "","[^|]+|(%w+)[|]?(%d*)[|]?(%d*)")
			
			if string.find(sources or "","D") and Skillet:GetTradeSkillOption("recipeSourceFilter-drop") then
				return false
			end
			
			if string.find(sources or "","V") and Skillet:GetTradeSkillOption("recipeSourceFilter-vendor") then
				return false
			end
			
			if string.find(sources or "","Q") and Skillet:GetTradeSkillOption("recipeSourceFilter-quest") then
				return false
			end
		
			if not found and Skillet:GetTradeSkillOption("recipeSourceFilter-trainer") then
				return false
			end	
		end

		return true
	end
	
	return false
end


function SkilletTSI:Enable()
	
	if TradeskillInfo then
		Skillet:RegisterRecipeDatabase("tsi",SkilletTSI)
		Skillet:RegisterPlayerDataGathering("tsiData",SkilletTSI,"tsi")
		
--		SkilletTSI:RecipeSourceButtonInit()
	
		Skillet:RegisterRecipeFilter("tsiRecipeSource", self, self.RecipeSourceButtonInit, self.RecipeFilterOperator)
				
				
		Skillet.defaultOptions["recipeSourceFilter"] = false
		Skillet.defaultOptions["recipeSourceFilter-drop"] = true
		Skillet.defaultOptions["recipeSourceFilter-vendor"] = true
		Skillet.defaultOptions["recipeSourceFilter-trainer"] = true
		Skillet.defaultOptions["recipeSourceFilter-quest"] = true
	end
end




-- common skills hooks

-- [id] = itemCreated[:count] itemReagents:count[:...] [level]
local commonSkillsRecipes = {
	[13361] = "10939 10938:3",			-- greater magic essence
	[13362] = "10938:3 10939:1",			-- lesser magic essence
}


SkilletCommonSkills = {}





