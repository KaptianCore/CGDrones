if SERVER then
    util.AddNetworkString("dronesrewrite_keyvalue")
    util.AddNetworkString("dronesrewrite_addweapon")

    -- New net system
    -- Main requests
    -- Keys
    net.Receive("dronesrewrite_keyvalue", function(len, ply)
        local key = net.ReadUInt(7)
        local pressed = net.ReadBit()
        local drone = ply:GetNWEntity("DronesRewriteDrone")

        if drone:IsValid() then
            local bind = DRONES_REWRITE.KeyNames[key]

            if bind then
                if not drone.Keys[bind] then
                    drone.Keys[bind] = {}
                end

                drone.Keys[bind].Pressed = tobool(pressed)
            end

            for k, v in pairs(DRONES_REWRITE.Keys) do
                if ply:GetInfoNum("dronesrewrite_key_" .. k, 0) == key then
                    if not drone.Keys[k] then
                        drone.Keys[k] = {}
                    end

                    drone.Keys[k].Pressed = tobool(pressed)
                    break
                end
            end
        end
    end)

    net.Receive("dronesrewrite_addweapon", function(len, ply)
        if not ply:IsAdmin() then return end
        local drone = net.ReadEntity()
        if not IsValid(drone) then return end
        local wepName = net.ReadString()
        local wep = net.ReadString()
        if not DRONES_REWRITE.Weapons[wep] then return end
        local ang = net.ReadAngle()
        local pos = net.ReadVector()
        local sync = net.ReadTable()
        local select = net.ReadBool()
        local prims = net.ReadBool()
        local att = net.ReadString()
        drone:FastAddWeapon(wepName, wep, pos, sync, ang, select, prims, att)
    end)

    -- Clientside
    util.AddNetworkString("dronesrewrite_updcam")
    util.AddNetworkString("dronesrewrite_playsound")
    util.AddNetworkString("dronesrewrite_doprecache")
    util.AddNetworkString("dronesrewrite_opencontroller")
    util.AddNetworkString("dronesrewrite_addline")
    util.AddNetworkString("dronesrewrite_removehook")
    util.AddNetworkString("dronesrewrite_addhook")
    -- Serverside
    util.AddNetworkString("dronesrewrite_controldr")
    util.AddNetworkString("dronesrewrite_controllerlookup")
    util.AddNetworkString("dronesrewrite_conexit")
    util.AddNetworkString("dronesrewrite_concmd")
    util.AddNetworkString("dronesrewrite_clickkey")
end

if SERVER then
    net.Receive("dronesrewrite_controldr", function(len, ply)
        local con = net.ReadEntity()
        local drone = con.Drone

        if IsValid(drone) then
            drone:SetDriver(ply, con.DistanceMaxDRR, con)
        end
    end)

    net.Receive("dronesrewrite_controllerlookup", function(len, ply)
        local con = net.ReadEntity()
        local unit = net.ReadString()
        if not IsValid(con) then return end
        local drone = DRONES_REWRITE.FindDroneByUnit(unit)
        if IsValid(drone) and not drone:CanBeControlledBy(ply) then return end
        con:SetDrone(drone)
    end)

    net.Receive("dronesrewrite_conexit", function(len, ply)
        local con = net.ReadEntity()
        if not IsValid(con) then return end
        if con:GetClass() ~= "dronesrewrite_console" then return end
        if ply ~= con.User then return end
        con:Exit()
    end)

    net.Receive("dronesrewrite_concmd", function(len, ply)
        local console = net.ReadEntity()
        local cmd = net.ReadString()
        local unk = net.ReadString()
        if not IsValid(console) then return end
        local _args = string.Explode(" ", unk)
        if console:GetClass() ~= "dronesrewrite_console" then return end
        if not IsValid(console.User) then return end
        if ply ~= console.User then return end
        if console.CatchCommand and not console.CatchCommand(console, _args, string.lower(cmd)) then return end

        if console.Commands[string.lower(cmd)] then
            console.Commands[string.lower(cmd)](console, _args)
        else
            console:AddLine("Unknown command: " .. cmd)
        end
    end)

    net.Receive("dronesrewrite_clickkey", function(len, ply)
        local drone = net.ReadEntity()
        local key = net.ReadString()
        if not IsValid(drone) then return end
        if not drone:CanBeControlledBy_skipai(ply) then return end
        drone:ClickKey(key)
    end)

    net.Receive("dronesrewrite_presskey", function(len, ply)
        local drone = net.ReadEntity()
        local key = net.ReadInt(8)
        if not IsValid(drone) then return end
        if not drone:CanBeControlledBy_skipai(ply) then return end
        local bind = DRONES_REWRITE.KeyNames[key]

        for k, v in pairs(DRONES_REWRITE.Keys) do
            if ply:GetInfoNum("dronesrewrite_key_" .. k, 0) == key then
                bind = k
                break
            end
        end

        if not bind then return end
        drone:PressKey(bind)
    end)
else
    net.Receive("dronesrewrite_updcam", function()
        DRONES_REWRITE.UpdateCamera()
    end)

    net.Receive("dronesrewrite_playsound", function()
        local name = net.ReadString()
        surface.PlaySound(name)
    end)

    net.Receive("dronesrewrite_doprecache", function()
        DRONES_REWRITE.DoPrecache()
    end)

    net.Receive("dronesrewrite_opencontroller", function()
        local con = net.ReadEntity()
        if not IsValid(con) then return end
        con:OpenMenu()
    end)

    net.Receive("dronesrewrite_removehook", function()
        local drone = net.ReadEntity()
        local class = net.ReadString()
        local name = net.ReadString()
        if not IsValid(drone) then return end
        drone:RemoveHook(class, name)
    end)

    net.Receive("dronesrewrite_addhook", function()
        local drone = net.ReadEntity()
        local class = net.ReadString()
        local name = net.ReadString()
        local func = net.ReadString()
        if not IsValid(drone) then return end
        if not drone.AddHook then return end
        drone:AddHook(class, name, func)
    end)
end