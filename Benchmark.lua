Enabled = true
Running = false
SpellId = nil
WaitTime = nil
TestTime = nil
LastTime = 0
Elapsed = 0
BenchmarkStart = nil

local function print(text)
    DEFAULT_CHAT_FRAME:AddMessage(text)
end

local function TableFind(table, text)
    for _, value in ipairs(table) do
        if value == text then
            return true
        end
    end
    return false
end

function Benchmark_OnLoad()
	SLASH_Benchmark1 = "/bm"
    SlashCmdList["Benchmark"] = Benchmark_Main

	print("|cFFFF962F Benchmark |rLoaded, write |cFF00FF00/bm|r for options")

	this:RegisterEvent("PLAYER_TARGET_CHANGED")
	this:RegisterEvent("PLAYER_LEAVE_COMBAT")
end 

function Benchmark_OnEvent(event, arg1)
	if not Enabled then return end 

	if event == "PLAYER_TARGET_CHANGED" then
		local name = UnitName'target'
		if name then 
			-- print("|cFFFF962F Benchmark |rTarget changed " .. UnitName'target')
		else 
			Benchmark_End()
			-- print("|cFFFF962F Benchmark |rDeselected target.")
		end 
	elseif event == "PLAYER_LEAVE_COMBAT" then
		-- print("|cFFFF962F Benchmark |rLeave combat.")
		Benchmark_End()
	end
end

local function UseTrinket(slotId)
	local trinketCD, trinketDuration, trinketEnabled = GetInventoryItemCooldown("player", slotId)
	if trinketCD == 0 and trinketEnabled == 1 then
		UseInventoryItem(slotId)
		print("|cFFFF962F Benchmark |cFFFFFF00Activating trinket " .. slotId);
		Elapsed = Elapsed - 0.2
		return true 
	end 
	return false 
end 

function Benchmark_OnUpdate()
	if Running then 
		if LastTime > 0 then 
			local now = GetTime()

			if now - BenchmarkStart > TestTime then 
				Benchmark_End()
				return 
			end 

			local diff = now - LastTime
			Elapsed = Elapsed + diff 
			if Elapsed > WaitTime / 1000 then 
				if not UseTrinket(13) and not UseTrinket(14) then 
					Elapsed = 0
					Benchmark_Cast()
				end 
			end 
		end 
		LastTime = GetTime()
	end 
end

function Benchmark_End() 
	if Running then 
		print("|cFFFF962F Benchmark |cFFFFFF00Benchmark ended!");
		Benchmark_Run() 
		local playerName = UnitName("player")
		SendChatMessage(".combatstop " .. playerName, "SAY")
	end 
end 

function Benchmark_Cast() 
	print("|cFFFF962F Benchmark |r" .. GetTime() .. " |cFFFFFF00Casting " .. SpellId);
	SendChatMessage(".cast " .. SpellId, "SAY")
end 

function Benchmark_Run() 
	if not SpellId then
		print("|cFFFF962F Benchmark |rNo spell chosen, write |cFF00FF00/bm spell <SPELLID>|r to set.")
		return 
	end 
	if not WaitTime then
		print("|cFFFF962F Benchmark |rNo wait time set, write |cFF00FF00/bm time <MILISECONDS>|r to set.")
		return 
	end 
	if not TestTime then
		print("|cFFFF962F Benchmark |rTotal benchmark time not set, write |cFF00FF00/bm test <SECONDS>|r to set.")
		return 
	end 

	Running = not Running

	if Running then 
		BenchmarkStart = GetTime() + WaitTime / 1000
		Elapsed = 0
		LastTime = 0
			print("|cFFFF962F Benchmark |rWill start running in " .. WaitTime .. " ms")
	else 
		print("|cFFFF962F Benchmark |rStopped running.")
	end 
end 

function Benchmark_Main(msg) 
	local _, _, cmd, arg1 = string.find(string.upper(msg), "([%w]+)%s*(.*)$");
    -- print("|cFFFF962F RaidLogger |rcmd " .. cmd .. " / arg1 " .. arg1)
    if not cmd then
        Benchmark_Run()
	elseif  "S" == cmd or "SPELL" == cmd then
		SpellId = arg1 
        print("|cFFFF962F Benchmark |rSpell set to " .. SpellId)
	elseif  "W" == cmd or "WAIT" == cmd then
		WaitTime = tonumber(arg1)
        print("|cFFFF962F Benchmark |rWait time set to " .. WaitTime .. " ms")
	elseif  "T" == cmd or "TIME" == cmd then
		TestTime = tonumber(arg1)
        print("|cFFFF962F Benchmark |rTotal benchmark test time set to " .. TestTime .. " seconds")
    elseif  "H" == cmd or "HELP" == cmd then
        print("|cFFFF962F Benchmark |rCommands: ")
        print("|cFFFF962F Benchmark |r  |cFF00FF00/bm|r - start / stop")
        print("|cFFFF962F Benchmark |r  |cFF00FF00/bm spell <SPELL_ID>|r - set spell to cast")
        print("|cFFFF962F Benchmark |r  |cFF00FF00/bm wait <MILISECONDS>|r - how much time to wait between casts")
        print("|cFFFF962F Benchmark |r  |cFF00FF00/bm time <SECONDS>|r - benchmark time")
	end
end 