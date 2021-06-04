--[[
    DONE:
    Show pets happiness, dmg percent,loyalty stats,loyalty flavor, and food type on slash command ----- GetPetHappiness(), GetPetLoyalty(), GetPetFoodTypes()
    Display warning on combat if the pet is on not summoned, not attacking, passive, or dead

    NEXT:
    Make tab for showing information and allow the toggling of alerts
]]--

    local f = CreateFrame("Frame")

	f:RegisterEvent("PLAYER_LOGIN");
    f:RegisterEvent("PLAYER_REGEN_DISABLED");
    f:RegisterEvent("PLAYER_REGEN_ENABLED");

    local deadPet = false;
    local dismissedPet = false;

    --commands in chat window that load slashPetPal
    SLASH_PETPAL1 = "/petpal" 
    SLASH_PETPAL2 = "/pp"

    local function slashPetPal()

        -- Position 0 in stable is current pet
        petIcon, petName, petLevel, petType, petLoyalty = GetStablePetInfo(0)

        happiness, damagePercentage, loyaltyRate = GetPetHappiness() 

        currXP, nextXP = GetPetExperience()

        petFoodList = { GetPetFoodTypes() }

        if not happiness then   -- if no happiness retrieved, no pet currently
            DEFAULT_CHAT_FRAME:AddMessage("No Pet")
        else

            happy = ({"unhappy", "content", "happy"})[happiness]

	        loyalty = loyaltyRate > 0 and "gaining" or "losing"

            DEFAULT_CHAT_FRAME:AddMessage("PET NAME: " ..petName.. " ---  PET LEVEL: " ..petLevel.." --- PET TYPE: " ..petType)
            DEFAULT_CHAT_FRAME:AddMessage(petName.. "'s loyalty:  " ..petLoyalty)
	        DEFAULT_CHAT_FRAME:AddMessage(petName.. " is " .. happy.. ", " .. loyalty .. " loyalty ,and doing " ..damagePercentage.. "% damage")
            DEFAULT_CHAT_FRAME:AddMessage(petName.. " eats: " .. table.concat(petFoodList, " "))
            DEFAULT_CHAT_FRAME:AddMessage(petName.. "'s experience: " .. currXP .. " / " .. nextXP .. " until level " .. petLevel+1)
        end
    end

    SlashCmdList["PETPAL"] = slashPetPal

    --handle when events we registered take place
    f:SetScript("OnEvent", function(self,event, ...)

        --show PetPal load when players log in
        if event == "PLAYER_LOGIN" then 
            if select(2,UnitClass("player"))=="HUNTER" then
                pinkText = "|cffC67171"
                DEFAULT_CHAT_FRAME:AddMessage(pinkText .. "PetPal Loaded ")
            end
        end

        if event == "PLAYER_REGEN_DISABLED" then  -- player regen is disabled when players enter combat
            if (not UnitIsDead("player")) then    -- if player is alive
                if select(2,UnitClass("player"))=="HUNTER" then -- and a hunter
                    if UnitIsDead("pet") then  -- if pet is dead
                        deadPet = true;
                        if (deadPet) then
                            local msg = "Your Pet is Dead!"
                            RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                        end	
                    elseif(not UnitExists("pet")) then -- if no pet summoned
                            dismissedPet = true;
                            if (dismissedPet) then
                                local msg = "Call Your Pet!"
                                RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                            end
                         
                    elseif UnitExists("pet") then  -- pet is summoned and alive
                        deadPet = false;           -- reset checker variables
                        dismissedPet =false;
                    end
                end 
            end
        end

        if event == "PLAYER_REGEN_ENABLED" then  --player regen is enabled when players leave combat
            happiness, damagePercentage, loyaltyRate = GetPetHappiness()
            if (not UnitIsDead("player")) then
                if select(2,UnitClass("player"))=="HUNTER" then
                    if(UnitExists("pet")) then 
                        if(not UnitIsDead("pet")) then -- if pet is alive and needs to be fed
                            if(happiness == 1) then -- pet happiness 1 is unhappy , 2 is content, 3 is happy
                                local msg = "Feed your pet!"
                                RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                            end
                        elseif UnitIsDead("pet") then --if pet is dead and needs to be fed
                            if(happiness == 1) then
                                local msg = "Revive and feed your pet!"
                                RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                            end
                        end
                    end
                end
            end
        end
    end)