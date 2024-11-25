Main = {
    SelectedCoords = nil,
    NewBlip = {}
}

CreateThread(function()
    Wrapper.TriggerCallback('bbv_blipcreator:GetAllBlips', function(data)
        TriggerEvent('bbv_blipcreator:client:addblips', data)
    end)
end)

RegisterCommand(Config.Settings.CommandCreate, function()
    Wrapper.TriggerCallback('bbv_blipcreator:HasPermission', function(allowed)
        if not allowed then 
            Main:Notify('You dont have permission to do that','error')
            return 
        end
        Main.SelectedCoords = GetBlipInfoIdCoord(GetFirstBlipInfoId(8))
        if Main.SelectedCoords == vec3(0.000000, 0.000000, 0.000000) then 
            Main.SelectedCoords = nil
        end
        if Main.SelectedCoords == nil then
            Main:Notify('You dont have a selected location','error')
            return 
        end

        local input = lib.inputDialog('Blip Creator', {
            {type = 'input', label = 'Blip Name', description = 'Name displayed on the blip', icon = 'sign', required = true, min = 1, max = 16},
            {type = 'number', label = 'Blip Sprite', description = 'Sprite number of the blip', icon = 'map', required = true},
            {type = 'number', label = 'Blip Scale', description = 'The Size of the blip', icon = 'marker', required = true},
            {type = 'color', label = 'Colour input', default = '#eb4034', required = true},
            {type = 'input', label = 'Coords', icon = 'location', default = tostring(Main.SelectedCoords), required = true}
        })
        if input == nil then 
            Main:Notify('Creation Cancelled','error')
            return
        end
        TriggerServerEvent('bbv_blipcreator:server:savedata', input)
        Main:Notify('Blip created successfully','success')
    end)
end)

RegisterCommand(Config.Settings.CommandInfo, function()
    Wrapper.TriggerCallback('bbv_blipcreator:HasPermission', function(allowed)
        if not allowed then 
            Main:Notify('You dont have permission to do that','error')
            return 
        end
        Wrapper.TriggerCallback('bbv_blipcreator:GetAllBlips', function(data)
            local options = {}

            for _, blip in ipairs(data.data) do
                local decodedData = json.decode(blip.data)
                local eventName = decodedData[1] or "Unknown Event"
                local option = {
                    title = "Blip Name: " .. eventName,  
                    description = "Coords: " .. (decodedData[5] or "N/A"),
                    icon = 'map',
                    onSelect = function()

                        lib.registerContext({
                            id = decodedData[1],
                            title = "Blip Name: " .. decodedData[1],  
                            menu = decodedData[1],
                            options = {
                                {
                                    title = 'Blip Name : '.. decodedData[1],
                                    icon = 'hand',
                                    disabled = true
                                },
                                {
                                    title = 'Blip Sprite : '.. decodedData[2],
                                    icon = 'hand',
                                    disabled = true
                                },
                                {
                                    title = 'Blip Scale : '.. decodedData[3],
                                    icon = 'hand',
                                    disabled = true
                                },
                                {
                                    title = 'Blip Color : '.. decodedData[4],
                                    icon = 'hand',
                                    disabled = true
                                },
                                {
                                    title = 'Blip Coords : '.. decodedData[5],
                                    icon = 'hand',
                                    disabled = true
                                },
                                {
                                    title = 'Teleport To Blip',
                                    icon = 'location',
                                    onSelect = function()
                                        local coords = decodedData[5]
                                        local x, y, z = coords:match("vec3%(([^,]+),%s*([^,]+),%s*([^,]+)%)")
                                        x, y, z = tonumber(x), tonumber(y), tonumber(z)
                                        if not (x and y and z) then
                                            if Config.Debug then 
                                                print("Error: Invalid coordinates format. Expected 'vec3(x, y, z)'")
                                            end
                                            return
                                        end

                                        local position = vec3(x, y, z)
                                        DoScreenFadeOut(1000)
                                        Wait(1000)
                                        for z = 1, 1000 do
                                            SetPedCoordsKeepVehicle(PlayerPedId(), x, y, z + 0.0)
                            
                                            local ground, zpos = GetGroundZFor_3dCoord(x, y, z + 0.0)
                            
                                            if ground then
                                                SetPedCoordsKeepVehicle(PlayerPedId(), x, y, z + 0.0)
                            
                                                break
                                            end
                            
                                            Citizen.Wait(5)
                                        end
                                        DoScreenFadeIn(1000)
                                        Main:Notify('Teleported to blip','success')
                                    end,
                                },
                                {
                                    title = 'Delete Blip',
                                    icon = 'trash',
                                    onSelect = function()
                                        local idData = json.encode(data.id[_])
                                        local id = json.decode(idData)
                                        TriggerServerEvent('bbv_blipcreator:server:DeleteBlip',id.id)
                                        Main:Notify('Blip with id ' .. id.id .. ' has been deleted successfully','error')
                                    end,
                                },
                            } 
                        })
                        
                        lib.showContext(decodedData[1])

                    end,
                }
                table.insert(options, option)
            end

            lib.registerContext({
                id = 'BlipInfo',
                title = 'Blip Info',
                menu = 'BlipInfo',
                options = options 
            })
            
            lib.showContext('BlipInfo')
        end)
    end)
end)

RegisterNetEvent('bbv_blipcreator:client:DeleteBlip',function(_data)
    RemoveBlip(Main.NewBlip[_data])
end)

RegisterNetEvent('bbv_blipcreator:client:createblip',function(_data,id)
    Main:CreateBlip(_data,id)
end)

RegisterNetEvent('bbv_blipcreator:client:addblips', function(data)
    for _, blipData in ipairs(data.data) do
        local decodedData = json.decode(blipData.data)
        local idData = json.encode(data.id[_])
        local id = json.decode(idData)
        if decodedData then
            Main:CreateBlip(decodedData,id.id)
        else
            if Config.Debug then 
                print("Error decoding data!")
            end
        end
    end
end)

function Main:CreateBlip(data,id)
    
    local coords = data[5]
    local x, y, z = coords:match("vec3%(([^,]+),%s*([^,]+),%s*([^,]+)%)")
    x, y, z = tonumber(x), tonumber(y), tonumber(z)
    if not (x and y and z) then
        if Config.Debug then
            print("Error: Invalid coordinates format. Expected 'vec3(x, y, z)'")
        end
        return
    end
    
    local position = vec3(x, y, z)
    
    local scale = tonumber(data[3]) or 1.0
    if scale % 1 == 0 then
        scale = scale + 0.0
    end

    local hexColor = data[4]:gsub("#", "")
    local fullHexColor = "F" .. hexColor .. "FF" 
    local colorValue = tonumber(fullHexColor, 16)
    if not colorValue then
        if Config.Debug then
            print("Error: Invalid color format. Expected a valid hex value.")
        end
        return
    end
    
    Main.NewBlip[id] = AddBlipForCoord(position)
    SetBlipSprite(Main.NewBlip[id], data[2])
    SetBlipDisplay(Main.NewBlip[id], 4)
    SetBlipScale(Main.NewBlip[id], scale)
    SetBlipColour(Main.NewBlip[id], colorValue)
    SetBlipAsShortRange(Main.NewBlip[id], true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(data[1])
    EndTextCommandSetBlipName(Main.NewBlip[id])
end

function Main:Notify(text,type)
    lib.notify({
        description = text,
        type = type
    })
end