RegisterNetEvent('bbv_blipcreator:server:DeleteBlip',function(data)
    TriggerClientEvent('bbv_blipcreator:client:DeleteBlip',-1,data)
    local response = MySQL.query.await('DELETE FROM `bbv_blips` WHERE `id` = ?', {data})
end)

RegisterNetEvent('bbv_blipcreator:server:savedata', function(data)

    local jsonData = json.encode(data)
    
    local query = MySQL.insert.await('INSERT INTO `bbv_blips` (`data`) VALUES (?)', {jsonData})
    TriggerClientEvent('bbv_blipcreator:client:createblip',-1, data,query)
    if Config.Debug then 
        if query then
            print("Data inserted successfully!")
        else
            print("Error inserting data!")
        end
    end
end)

Wrapper.CreateCallback('bbv_blipcreator:GetAllBlips', function(source, cb, args)
    local result = MySQL.query.await('SELECT `data` FROM `bbv_blips`')
    local result2 = MySQL.query.await('SELECT `id` FROM `bbv_blips`')

    TheResult = {
        id = result2,
        data = result
    }
    cb(TheResult)
end)

Wrapper.CreateCallback('bbv_blipcreator:HasPermission', function(source, cb, args)
    local src = source
    for k,v in pairs(Config.Settings.Allowed) do
        local src = source
        local myid = Identifiers(src)
        if v == myid.discord or Config.Settings.Permissions == false then 
            cb(true)
            return
        else
            cb(false)
            return
        end
    end
end)

function Identifiers(src)
    local identifiers = {
        steam = "",
        ip = "",
        discord = "",
        license = "",
        xbl = "",
        live = ""
    }

    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)

        if string.find(id, "steam") then
            identifiers.steam = id
        elseif string.find(id, "ip") then
            identifiers.ip = id
        elseif string.find(id, "discord") then
            identifiers.discord = id
        elseif string.find(id, "license") then
            identifiers.license = id
        elseif string.find(id, "xbl") then
            identifiers.xbl = id
        elseif string.find(id, "live") then
            identifiers.live = id
        end
    end

    return identifiers
end