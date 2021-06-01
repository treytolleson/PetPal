--[[
    Functionality wanted:
    Show pets happiness, dmg percent,loyalty stats,loyalty flavor, and food type on slash command ----- GetPetHappiness(), GetPetLoyalty(), GetPetFoodTypes()
    Display warning on combat if the pet is on not summoned--DONE, not attacking, passive, or dead-- DONE 
]]--

    local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED");
	f:RegisterEvent("PLAYER_LOGIN");
    f:RegisterEvent("PLAYER_STARTED_MOVING");
    f:RegisterEvent("PLAYER_REGEN_DISABLED");
    f:RegisterEvent("PLAYER_REGEN_ENABLED");
    local deadPet = false;
    local dismissedPet = false;
    f:SetScript("OnEvent", function(self,event, ...)

        if event == "PLAYER_LOGIN" then
            print("PetPal Loaded")
            print("Happy Hunting :)")
        end

        if event == "PLAYER_REGEN_DISABLED" then
            if (not UnitIsDead("player")) then
                if select(2,UnitClass("player"))=="HUNTER" then
                    if UnitIsDead("pet") then
                        deadPet = true;
                        if (deadPet) then
                            local msg = "Your Pet is Dead!"
                            RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                        end	
                    elseif(not UnitExists("pet")) then
                            dismissedPet = true;
                            if (dismissedPet) then
                                local msg = "Call Your Pet!"
                                RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                            end
                         
                    elseif UnitExists("pet") then
                        deadPet = false;
                        dismissedPet =false;
                    end
                end 
            end
        end

        if event == "PLAYER_REGEN_ENABLED" then
            happiness, damagePercentage, loyaltyRate = GetPetHappiness()
            if (not UnitIsDead("player")) then
                if select(2,UnitClass("player"))=="HUNTER" then
                    if(UnitExists("pet")) then 
                        if(happiness == 1) then
                            local msg = "Feed your pet!"
                            RaidNotice_AddMessage(RaidBossEmoteFrame, msg, ChatTypeInfo["RAID_BOSS_EMOTE"])
                        end
                    end
                end
            end
        end
    end)




