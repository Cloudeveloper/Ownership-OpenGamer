-- https://bit.ly/robloxownership
local unpack = table.unpack or unpack
local RS = game:GetService("RunService")
repeat RS.RenderStepped:Wait() until game:IsLoaded() 

local StarterGui = game:GetService("StarterGui")
local function InvokeCore(...)
    local Args = {...}
    local ErrMsg;
    local Err;

    repeat
        Err, ErrMsg = pcall(function()
            StarterGui:SetCore(unpack(Args)) -- wth i cant use varargs in a function
        end)
        
        if not ErrMsg then ErrMsg = "" end
        RS.RenderStepped:Wait()
    until not string.match(ErrMsg, "has not been registered")
end

local Players = game:GetService("Players")
local Player = Players.LocalPlayer

local gethiddenprop = gethiddenproperty or get_hidden_property or gethiddenprop or get_hidden_prop
local sethiddenprop = sethiddenproperty or set_hidden_property or sethiddenprop or set_hidden_prop
local setsimrad = setsimulationradius or set_simulation_radius or function(Radius) sethiddenprop(Player, "SimulationRadius", math.huge) end
local function ClaimOwnership()
    sethiddenprop(Player, "MaximumSimulationRadius", math.huge)
    setsimrad(math.huge)
end

local function RevokeOwnership(Other)
    sethiddenprop(Other, "MaximumSimulationRadius", 0.1)
    sethiddenprop(Other, "SimulationRadius", 0.1)
end

coroutine.wrap(function() -- New thread
	if not isPrimaryOwner then
        if gethiddenprop and (setsimrad or sethiddenprop) then
            local UHaveOwnership = "[NetworkService]: Claimed ownership."
            local ThereNoHoggers = "[NetworkService]: Great! No users are hogging the network."
            local ThereArHoggers = "[NetworkService]: There are %s users hogging the network:\n%s."

			getgenv().isPrimaryOwner = true
			settings().Physics.AllowSleep = false
			settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.Disabled
			
            -- Perform Network Scan
            local Result = ""
            local ContaminatedPlayers = 0
            local Players = game:GetService("Players")
            for _, _Player in pairs(Players:GetChildren()) do
                if _Player ~= Player then
                    local TheirRadius = gethiddenprop(_Player, "SimulationRadius")
                    if TheirRadius >= math.huge then
                        ContaminatedPlayers = ContaminatedPlayers + 1
                        Result = Result..Player.Name..", "
                    end
                end
            end

            if ContaminatedPlayers > 0 then
                Result = Result:sub(1, -3)
            end

            InvokeCore("ChatMakeSystemMessage", {
			    ["Text"] = (ContaminatedPlayers > 0) and string.format(ThereArHoggers, ContaminatedPlayers, Result) or ThereNoHoggers
            })
            
            Player.ReplicationFocus = workspace
            InvokeCore("ChatMakeSystemMessage", {
			    ["Text"] = UHaveOwnership
            })
            
			while RS.Stepped:Wait() do
				for _, Other in pairs(Players:GetChildren()) do
				    if Other ~= Player then
				        RevokeOwnership(Other)
				    end
				end
		    
		        ClaimOwnership()
			end
		else
			InvokeCore("ChatMakeSystemMessage", {
                ["Text"] = "[NetworkService]: Exploit not supported."
            })
		end
	end
end)()
-- <eof>
