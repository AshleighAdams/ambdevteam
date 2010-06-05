ENT.Type = "point"

if SERVER then AddCSLuaFile('shared.lua') end

function ENT:AcceptInput(name, act, caller, data)  
    if caller:IsPlayer() then return end  
    if string.lower(name) == "command" then  
        game.ConsoleCommand(data.."\n")  
    end  
end  