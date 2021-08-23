--[[
    Script Name: Brick's Script
    Author: Sri Hari#0001
    Author's Note: Feel free to use any part of this script for your code (Just credit me plz)
]]

-- Prevents multiple instances of the script running!
if is_brick_loaded then
    menu.notify("Script is already loaded you dummy!", "Brick's Script", 5, 0x0000FF)
end
is_brick_loaded = true

-- General paths required for the script
local path = {}
path["appdata"] = utils.get_appdata_path("PopstarDevs", "")
path["2t1folder"] = path["appdata"] .. "\\2Take1Menu"
path["scripts"] = path["2t1folder"] .. "\\scripts"
path["bricks"] = path["scripts"] .. "\\bricks_script"

-- Script Parents
local script_parent = {}
script_parent.home = menu.add_feature("Brick's Script", "parent", 0).id
script_parent.self = menu.add_feature("Self", "parent", script_parent.home).id
script_parent.lobby = menu.add_feature("Lobby", "parent", script_parent.home).id
script_parent.animal = menu.add_feature("Animal Changer", "parent", script_parent.home).id
script_parent.utils = menu.add_feature("Utils", "parent", script_parent.home).id
script_parent.vehicle = menu.add_feature("Vehicle", "parent", script_parent.home).id

script_parent.logs = menu.add_feature("Clear Individual Logs", "parent", script_parent.utils).id

-- Player Feat Parents
local player_parent = {}
player_parent.home = menu.add_player_feature("Brick's Script", "parent", 0).id
player_parent.spam_big_veh = menu.add_player_feature("Spam Big Vehicles", "parent", player_parent.home, function()
    menu.notify("Use with caution! Will cause extreme lag", "Brick's Script", 8, 0x0000FF)
end).id

if not utils.dir_exists(path["bricks"]) then
    utils.make_dir(path["bricks"])
end

local mypid = player.player_id

------------------------
-- Functions :)
------------------------

local function log(msg)
    local log_file = io.open(path["bricks"] .. "\\bricks-log.log", "a")
    if not msg then
        error("log() | Msg cannot be nil")
    end
    local t = os.date("*t")
    if t.day < 10 then
        t.day = "0"..tostring(t.day)
    end
    if t.month < 10 then
        t.month = "0"..tostring(t.month)
    end
    if t.hour < 10 then
        t.hour = "0"..tostring(t.hour)
    end
    if t.min < 10 then
        t.min = "0"..tostring(t.min)
    end
    if t.sec < 10 then
        t.sec = "0"..tostring(t.sec)
    end
    t = t.day.."-"..t.month.."-"..t.year.." | "..t.hour..":"..t.min..":"..t.sec.." | "
    log_file:write(t .. msg .. "\n")
    log_file:close()
    print(t .. msg .. "\n")
end

local function notify(msg, title, sec, color, _log)
    if not msg then
        error("notify() | Msg cannot be nil")
    end
    if title == "" then
        title = "Brick's Script"
    end
    sec = sec or 6
    -- Color management so I dont have to memorize the hex lol
    if color == "R" then
        color = 0x0000FF
    elseif color == "B" then
        color = 0xCC0000
    elseif color == "G" then
        color = 0x00FF00
    elseif color == "BLACK" then
        color = 0x000001
    elseif color == "Y" then
        color = 0x00E8FF
    else
        color = nil
    end
    _log = _log or true
    menu.notify(msg, title, sec, color)
    log(msg)
end

local function own_ped()
    return player.get_player_ped(mypid())
end

local function req_model(model)
    if not model then
        log("req_model | Line 110 | No model specified")
        return false
    end
    if not streaming.is_model_valid(model) then
        log("req_model | Line 114 | Invalid model")
        return false
    end
    streaming.request_model(model)
    local check_time = utils.time_ms() + 2000
    while not streaming.has_model_loaded(model) and check_time > utils.time_ms() do
        system.yield(0)
    end
    return streaming.has_model_loaded(model)
end

local function getped(pid)
    if not player.is_player_valid(pid) then
        log("Invalid PID")
        return
    end
    return player.get_player_ped(pid)
end

local function req_control(ent)
    if ent and not entity.is_an_entity(ent) then
        log("Invalid entity")
        return 0
    end
    local check_time = utils.time_ms() + 2000
    while not network.has_control_of_entity(ent) and check_time > utils.time_ms() do
        system.yield(0)
    end
    return network.has_control_of_entity(ent)
end

local function get_input(title, def, len,type)
    title = title or ""
    def = def or ""
    len = len or 10
    type = type or 0
    local status, msg
    repeat
        system.yield(0)
        status, msg = input.get(title, def, len, type)
        if status == 2 then
            notify("Input cancelled", "", 5, "BLACK")
            return
        end
    until status == 0
    return msg
end

-- Credits to Proddy
local function RGBAToInt(R, G, B, A)
	A = A or 255
	return ((R&0x0ff)<<0x00)|((G&0x0ff)<<0x08)|((B&0x0ff)<<0x10)|((A&0x0ff)<<0x18)
end

local function change_model(hash)
    local load_model = req_model(hash)
    if load_model and streaming.is_model_a_ped(hash) then
        player.set_player_model(hash)
    else
        log("change_model | Line 276 | Unable to load model")
    end
    streaming.set_model_as_no_longer_needed(hash)
end

-------------------------------------------------
--              SCRIPT FEATURES
-------------------------------------------------


--------------------------------------------------
-- SCRIPT FEAT > SELF > FAST FORWARD TIME
--------------------------------------------------
menu.add_feature("Fast Forward Time (Local)", "toggle", script_parent.self, function(feat)
    while feat.on do
        local cur_hour = time.get_clock_hours()
        local cur_min = time.get_clock_minutes()
        local cur_sec = time.get_clock_seconds()
        for i = cur_sec, 59 do
            time.set_clock_time(cur_hour, cur_min, i)
            system.yield(100)
            if i == 59 then
                i = 0
                cur_min = cur_min + 1
            end
            if cur_min == 59 then
                cur_min = 0
                cur_hour = cur_hour + 1
            end
            if not feat.on then
                return HANDLER_POP
            end
        end
        system.yield(0)
    end
end)

--------------------------------------------------
-- SCRIPT FEAT > SELF > CRASH
--------------------------------------------------
menu.add_feature("Crash", "action_value_str", script_parent.self, function(feat)
    if feat.value == 0 then
        local model = 0x81441B71
        if not req_model(model) then
            notify("Unable to load the model", "", 5, "R")
            return HANDLER_POP
        end
        local cur_pos = player.get_player_coords(mypid())
        for i = 1, 200 do
            ped.create_ped(25, model, cur_pos, 0, false, false)
            system.yield(100)
        end
        streaming.set_model_as_no_longer_needed(model)
    else
        local model = 0x15F27762
        if not req_model(model) then
            notify("Unable to load the model", "", 5, "R")
            return HANDLER_POP
        end
        local cur_pos = player.get_player_coords(mypid())
        for i = 1, 500 do
            vehicle.create_vehicle(model, cur_pos, 0, false, false)
            system.yield(100)
        end
        streaming.set_model_as_no_longer_needed(model)
    end

end):set_str_data({"Peds", "Vehicles"})



-------------------------------------------------
-- SCRIPT FEATURES > UTILS > CLEAR LOGS
-------------------------------------------------

local clear_logs = {} -- Stores all the log clearing var
clear_logs.brick = function()
    local log_file = io.open(path["bricks"] .. "\\bricks-log.log", "w")
    log_file:write("x---CLEARED BRICKS-LOG.LOG---x\n")
    log_file:close()
    notify("Cleared bricks-log.log successfully!", nil, 4, "G")
end
clear_logs._2t1 = function()
    local log_file = io.open(path["2t1folder"] .. "\\2Take1Menu.log", "w")
    log_file:write("x---CLEARED 2TAKE1MENU.LOG---x\n")
    log_file:close()
    notify("Cleared 2Take1Menu.log successfully!", nil, 4, "G")
end
clear_logs._2t1prep = function()
    local log_file = io.open(path["2t1folder"] .. "\\2Take1Prep.log", "w")
    log_file:write("x---CLEARED 2TAKE1PREP.LOG---x\n")
    log_file:close()
    notify("Cleared 2Take1Prep.log successfully!", nil, 4, "G")
end
clear_logs.ne = function()
    local ne_path = path["2t1folder"] .. "\\net_event.log"
    if not utils.file_exists(ne_path) then
        notify("You are not logging net events!", nil, 4, "Y")
        return HANDLER_POP
    end
    local log_file = io.open(ne_path, "w")
    log_file:write("x---CLEARED NET_EVENT.LOG---x\n")
    log_file:close()
    notify("Cleared net_event.log successfully!", nil, 4, "G")
end
clear_logs.notifs = function()
    local notif_path = path["2t1folder"] .. "\\notification.log"
    if not utils.file_exists(notif_path) then
        notify("You are not logging notifications!", nil, 4, "Y")
        return HANDLER_POP
    end
    local log_file = io.open(notif_path, "w")
    log_file:write("x---CLEARED NOTIFICATION.LOG---x\n")
    log_file:close()
    notify("Cleared notification.log successfully!", nil, 4, "G")
end
clear_logs.player = function()
    local se_path = path["2t1folder"] .. "\\player.log"
    if not utils.file_exists(se_path) then
        notify("You are not logging players!", nil, 4, "Y")
        return HANDLER_POP
    end
    local log_file = io.open(se_path, "w")
    log_file:write("x---CLEARED PLAYER.LOG---x\n")
    log_file:close()
    notify("Cleared player.log successfully!", nil, 4, "G")
end
clear_logs.se = function()
    local se_path = path["2t1folder"] .. "\\script_event.log"
    if not utils.file_exists(se_path) then
        notify("You are not logging script events!", nil, 4, "Y")
        return HANDLER_POP
    end
    local log_file = io.open(se_path, "w")
    log_file:write("x---CLEARED SCRIPT_EVENT.LOG---x\n")
    log_file:close()
    notify("Cleared script_event.log successfully!", nil, 4, "G")
end
menu.add_feature("Clear all logs", "action", script_parent.utils, function()
    clear_logs.brick()
    clear_logs._2t1()
    clear_logs._2t1prep()
    clear_logs.ne()
    clear_logs.notifs()
    clear_logs.player()
    clear_logs.se()
end)
-- Clear for all the logs individually
menu.add_feature("Clear Brick's Log", "action", script_parent.logs, function()
    clear_logs.brick()
end)
menu.add_feature("Clear 2Take1Menu.log", "action", script_parent.logs, function()
    clear_logs._2t1()
end)
menu.add_feature("Clear 2Take1Prep.log", "action", script_parent.logs, function()
    clear_logs._2t1prep()
end)
menu.add_feature("Clear net_event.;og", "action", script_parent.logs, function()
    clear_logs.ne()
end)
menu.add_feature("Clear notification.log", "action", script_parent.logs, function()
    clear_logs.notifs()
end)
menu.add_feature("Clear player.log", "action", script_parent.logs, function()
    clear_logs.player()
end)
menu.add_feature("Clear script_event.log", "action", script_parent.logs, function()
    clear_logs.se()
end)


------------------------------------------------
-- SCRIPT FEATURES > ANIMAL CHANGER
------------------------------------------------
menu.add_feature("Reset (Fix loading screen)", "action", script_parent.animal, function(feat)
    local is_ped_dead = entity.is_entity_dead(own_ped())
    change_model(0x9B22DBAF)
    system.yield(100)
    ped.set_ped_health(player.get_player_ped(mypid()), 0)
    if is_ped_dead then
        system.yield(1500)
        change_model(0x9B22DBAF)
        system.yield(100)
        ped.set_ped_health(player.get_player_ped(mypid()), 0)
    end
    notify("Reset model successful", "", 6, "G")
    log("Reset model")
end)
-- Animal models
local animal_models = {
    ["boar"] = 0xCE5FF074,
    ["cat"] = 0x573201B8,
    ["chickenhawk"] = 0xAAB71F62,
    ["chimp"] = 0xA8683715,
    ["chop"] = 0x14EC17EA, --Chop doesnt work in story
    ["cormorant"] = 0x56E29962,
    ["cow"] = 0xFCFA9E1E,
    ["coyote"] = 0x644AC75E,
    ["crow"] = 0x18012A9F,
    ["deer"] = 0xD86B5A95,
    ["dolphin"] = 0x8BBAB455,
    ["fish"] = 0x2FD800B7,
    ["hen"] = 0x6AF51FAF,
    ["humpback"] = 0x471BE4B2,
    ["husky"] = 0x4E8F95A2,
    ["killerwhale"] = 0x8D8AC8B9,
    ["lion"] = 0x1250D7BA,
    ["panther"] = 0xE71D5E68,
    ["pig"] = 0xB11BAB56,
    ["pigeon"] = 0x6A20728,
    ["poodle"] = 0x431D501C,
    ["pug"] = 0x6D362854,
    ["rabbit"] = 0xDFB55C81,
    ["rat"] = 0xC3B52966,
    ["retriever"] = 0x349F33E1,
    ["rhesus"] = 0xC2D06F53,
    ["rottweiler"] = 0x9563221D,
    ["seagull"] = 0xD3939DFD,
    ["sharkhammer"] = 0x3C831724,
    ["sharktiger"] = 0x6C3F072,
    ["shepherd"] = 0x431FC24C,
    ["stingray"] = 0xA148614D,
    ["westy"] = 0xAD7844BB
}
menu.add_feature("Boar", "action", script_parent.animal, function()
    change_model(animal_models["boar"])
    log("Animcal Changer | Changed model to Boar")
end)
menu.add_feature("Cat", "action", script_parent.animal, function()
    change_model(animal_models["cat"])
    log("Animcal Changer | Changed model to Cat")
end)
menu.add_feature("Chimp", "action", script_parent.animal, function()
    change_model(animal_models["chimp"])
    log("Animcal Changer | Changed model to Chimp")
end)
menu.add_feature("Cormorant", "action", script_parent.animal, function()
    change_model(animal_models["cormorant"])
    log("Animcal Changer | Changed model to Cormorant")
end)
menu.add_feature("Cow", "action", script_parent.animal, function()
    change_model(animal_models["cow"])
    log("Animcal Changer | Changed model to Cow")
end)
menu.add_feature("Coyote", "action", script_parent.animal, function()
    change_model(animal_models["coyote"])
    log("Animcal Changer | Changed model to Coyote")
end)
menu.add_feature("Crow", "action", script_parent.animal, function()
    change_model(animal_models["crow"])
    log("Animcal Changer | Changed model to Crow")
end)
menu.add_feature("Deer", "action", script_parent.animal, function()
    change_model(animal_models["deer"])
    log("Animcal Changer | Changed model to Deer")
end)
menu.add_feature("Dolphin", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["dolphin"])
    log("Animcal Changer | Changed model to Dolphin")
end)
menu.add_feature("Fish", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["Fish"])
    log("Animcal Changer | Changed model to Fish")
end)
menu.add_feature("Hen", "action", script_parent.animal, function()
    change_model(animal_models["hen"])
    log("Animcal Changer | Changed model to Hen")
end)
menu.add_feature("Humpback Whale", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["humpback"])
    log("Animcal Changer | Changed model to Humpback Whale")
end)
menu.add_feature("Husky", "action", script_parent.animal, function()
    change_model(animal_models["husky"])
    log("Animcal Changer | Changed model to Boar")
end)
menu.add_feature("Killer Whale", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["killerwhale"])
    log("Animcal Changer | Changed model to Killer Whale")
end)
menu.add_feature("Lion", "action", script_parent.animal, function()
    change_model(animal_models["lion"])
    log("Animcal Changer | Changed model to Lion")
end)
menu.add_feature("Panther", "action", script_parent.animal, function()
    change_model(animal_models["panther"])
    log("Animcal Changer | Changed model to Panther")
end)
menu.add_feature("Pig", "action", script_parent.animal, function()
    change_model(animal_models["pig"])
    log("Animcal Changer | Changed model to Pig")
end)
menu.add_feature("Pigeon", "action", script_parent.animal, function()
    change_model(animal_models["pigeon"])
    log("Animcal Changer | Changed model to Pigeon")
end)
menu.add_feature("Poodle", "action", script_parent.animal, function()
    change_model(animal_models["poodle"])
    log("Animcal Changer | Changed model to Poodle")
end)
menu.add_feature("Pug", "action", script_parent.animal, function()
    change_model(animal_models["pug"])
    log("Animcal Changer | Changed model to Pug")
end)
menu.add_feature("Rabbit", "action", script_parent.animal, function()
    change_model(animal_models["rabbit"])
    log("Animcal Changer | Changed model to Rabbit")
end)
menu.add_feature("Rat", "action", script_parent.animal, function()
    change_model(animal_models["rat"])
    log("Animcal Changer | Changed model to Rat")
end)
menu.add_feature("Retriever", "action", script_parent.animal, function()
    change_model(animal_models["retriever"])
    log("Animcal Changer | Changed model to Retriever")
end)
menu.add_feature("Rhesus", "action", script_parent.animal, function()
    change_model(animal_models["rhesus"])
    log("Animcal Changer | Changed model to Rhesus")
end)
menu.add_feature("Rottweiler", "action", script_parent.animal, function()
    change_model(animal_models["rottweiler"])
    log("Animcal Changer | Changed model to Rottweiler")
end)
menu.add_feature("Seagull", "action", script_parent.animal, function()
    change_model(animal_models["seagull"])
    log("Animcal Changer | Changed model to Seagull")
end)
menu.add_feature("Shark Hammer", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["sharkhammer"])
    log("Animal Changer | Changed model to Shark Hammer")
end)
menu.add_feature("Shark Tiger", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["sharktiger"])
    log("Animcal Changer | Changed model to Shark Tiger")
end)
menu.add_feature("Shepherd", "action", script_parent.animal, function()
    change_model(animal_models["shepherd"])
    log("Animcal Changer | Changed model to Shepherd")
end)
menu.add_feature("Sting Ray", "action", script_parent.animal, function()
    -- Water animal
    if not entity.is_entity_in_water(own_ped()) then
        notify("This is a water animal! | Please go inside the water", "", 4, "R")
        return
    end
    change_model(animal_models["stingray"])
    log("Animcal Changer | Changed model to Sting Ray")
end)
menu.add_feature("Westy", "action", script_parent.animal, function()
    change_model(animal_models["westy"])
    log("Animcal Changer | Changed model to Westy")
end)



-------------------------------------------------
-- SCRIPT FEAT > VEHICLE > PRECISE COLOR CHANGER
-------------------------------------------------
local precise_change = {}
precise_change.home = menu.add_feature("Precise Color Changer", "parent", script_parent.vehicle).id
precise_change.primary = menu.add_feature("Primary Color", "parent", precise_change.home).id
precise_change.secondary = menu.add_feature("Secondary Color", "parent", precise_change.home).id
precise_change.pearl = menu.add_feature("Pearlescent Color", "parent", precise_change.home).id
precise_change.window = menu.add_feature("Window Tint Color", "parent", precise_change.home).id

local prim_r,prim_g,prim_b = 0,0,0
local sec_r, sec_g, sec_b = 0,0,0
------------------------
local get_prim_r = menu.add_feature("Set R value", "action", precise_change.primary, function(feat)
    local val
    val = get_input("Set R value", "", 3, 3)
    notify("Set Primary R to "..val, nil, 4, "G")
    prim_r = val
end)
-- get_prim_r.value = prim_r
local get_prim_g = menu.add_feature("Set G value", "action", precise_change.primary, function(feat)
    local val
    val = get_input("Set G value", "", 3, 3)
    notify("Set Primary G to "..val, nil, 4, "G")
    prim_g = val
end)
local get_prim_b = menu.add_feature("Set B value", "action", precise_change.primary, function(feat)
    local val
    val = get_input("Set B value", "", 3, 3)
    notify("Set Primary B to "..val, nil, 4, "G")
    prim_b = val
end)

menu.add_feature("Change primary color", "action", precise_change.primary, function(f)
    if not player.is_player_in_any_vehicle(mypid()) then
        notify("Get in a vehicle first", "", 6, "R")
        log("Script Feat > Vehicle > Primary Color | Player not in any vehicle!")
        return
    end
    local cur_veh = player.get_player_vehicle(mypid())
    if not network.has_control_of_entity(cur_veh) then
        req_control(cur_veh)
    end
    prim_r = tonumber(prim_r)
    prim_g = tonumber(prim_g)
    prim_b = tonumber(prim_b)
    vehicle.set_vehicle_custom_primary_colour(cur_veh, RGBAToInt(prim_b, prim_g, prim_r, 255))
end)
------------------------
local get_sec_r = menu.add_feature("Set R value", "action", precise_change.secondary, function(feat)
    local val
    val = get_input("Set R value", "", 3, 3)
    notify("Set Secondary R to "..val, nil, 4, "G")
    sec_r = val
end)
local get_sec_g = menu.add_feature("Set G value", "action", precise_change.secondary, function(feat)
    local val
    val = get_input("Set G value", "", 3, 3)
    notify("Set Secondary G to "..val, nil, 4, "G")
    sec_g = val
end)
local get_sec_b = menu.add_feature("Set B value", "action", precise_change.secondary, function(feat)
    local val
    val = get_input("Set B value", "", 3, 3)
    notify("Set Secondary B to "..val, nil, 4, "G")
    sec_b = val
end)

menu.add_feature("Change secondary color", "action", precise_change.secondary, function(f)
    if not player.is_player_in_any_vehicle(mypid()) then
        notify("Get in a vehicle first", "", 6, "R")
        log("Script Feat > Vehicle > Secondary Color | Player not in any vehicle!")
        return
    end
    local cur_veh = player.get_player_vehicle(mypid())
    if not network.has_control_of_entity(cur_veh) then
        req_control(cur_veh)
    end
    sec_r = tonumber(sec_r)
    sec_g = tonumber(sec_g)
    sec_b = tonumber(sec_b)
    vehicle.set_vehicle_custom_secondary_colour(cur_veh, RGBAToInt(sec_b, sec_g, sec_r, 255))
end)

-------------------------------------------------
-- SCRIPT FEAT > VEHICLE > SPEED PLATE
-------------------------------------------------
menu.add_feature("Speedometer Plate", "value_str", script_parent.vehicle, function(feat)
    local in_veh_at_the_beginning = true
    while feat.on do
        system.yield(0)
        if not player.is_player_in_any_vehicle(mypid()) then
            in_veh_at_the_beginning = false
            feat.on = false
            return HANDLER_POP
        end
        local cur_veh = player.get_player_vehicle(mypid())
        if not network.has_control_of_entity(cur_veh) then
            req_control(cur_veh)
        end
        if feat.value == 0 then
            vehicle.set_vehicle_number_plate_text(cur_veh, tostring(math.floor((entity.get_entity_speed(cur_veh)*2.25*1.6)).." KMPH"))
        end
        if feat.value == 1 then
            vehicle.set_vehicle_number_plate_text(cur_veh, tostring(math.floor((entity.get_entity_speed(cur_veh)*2.25)).." MPH"))
        end
    end
    if not feat.on then
        if not player.is_player_in_any_vehicle(mypid()) and in_veh_at_the_beginning then
            return
        end
        local cur_veh = player.get_player_vehicle(mypid())
        if not network.has_control_of_entity(cur_veh) then
            req_control(cur_veh)
        end
        vehicle.set_vehicle_number_plate_text(cur_veh, "BRICK")
    end
end):set_str_data({"KMPH", "MPH"})


-------------------------------------------------
-- SCRIPT FEAT > VEHICLE > DRIFT MODE
-------------------------------------------------
local drift_min_speed = 8.0
local dift_max_angle = 50.0
local ctrl_veh_acc = 71
local ctrl_veh_brake = 72
local ctrl_veh_duck = 73
local ctrl_veh_select_nxt_weap = 99
local input_frontend_ls = 209
local ctrl_veh_move_up = 61
local drift_activate_key = input_frontend_ls
local is_drifting = 0
local was_drifting = 0
local is_drift_finished = 1
local prev_grip_state = 0
local last_drift_angle = 0.0
local old_grip_state = 0
local debug_notif = 0

local function as_degrees(angle)
    return angle * (180.0/math.pi)
end
local function wrap360(val)
    while val < 0.0 do
        val = val + 360.0
    end
    while val > 360.0 do
        val = val - 360.0
    end
    return val
end
local function drift_get_cur_veh()
    local pped = own_ped()
    local cur_veh
    if ped.is_ped_in_any_vehicle(pped) then
        local temp_var = ped.get_vehicle_ped_is_using(pped)
        if network.has_control_of_entity(temp_var) then
            cur_veh = temp_var
        end
    end
    return cur_veh
end
local function get_heading_of_travel(veh)
    local velocity = entity.get_entity_velocity(veh)
    local x = velocity.x
    local y = velocity.y
    local at2  = math.atan(y, x)
    return math.fmod(270.0 + math.deg(at2), 360.0)
end
local function apply_force(veh, height)
    if vehicle.is_vehicle_on_all_wheels(veh) and not entity.is_entity_in_air(veh) then
        entity.apply_force_to_entity(veh, 1, 0, 0, height, 0, 0, 0, true, true)
    end
end
local function drift_mod_on_tick()
    local veh = drift_get_cur_veh()
    if not entity.is_entity_a_vehicle(veh) then
        return
    end
    local in_veh = veh ~= 0
    local is_driving = true
    local mps = entity.get_entity_speed
    local mph = mps * 2.23694
    local kmph = mps * 3.6
    if in_veh and is_driving and not is_drifting and not is_drift_finished then
        is_drift_finished = true
    end
    if not in_veh or not is_driving then
        return
    end
    -- local drift_key_pressed = controls.is_control_pressed(2, controlVehicleDuck)
end

-------------------------------------------------
-- SCRIPT FEAT > LOBBY > VEHICLES EXPLODE ON IMPACT
-------------------------------------------------
menu.add_feature("Vehicles Explode on Impact", "toggle", script_parent.lobby, function(feat)
    local temp_ped = nil
    local cache_ped
    while feat.on do
        local pcount = player.player_count()
        if temp_ped == nil then
            req_model(0xA28E71D7)
            temp_ped = ped.create_ped(5, 0xA28E71D7, v3(100, 100, 100), 0, true, false)
            entity.set_entity_god_mode(temp_ped, true)
            entity.set_entity_visible(temp_ped, false)
            entity.freeze_entity(temp_ped, true)
            weapon.give_delayed_weapon_to_ped(temp_ped, 0xB1CA77B1, 100, true)
            cache_ped = temp_ped
        end
        for i = 0, pcount do
            if player.is_player_in_any_vehicle(i) then
                local cur_veh = player.get_player_vehicle(i)
                if entity.has_entity_collided_with_anything(cur_veh) then
                    local cur_ped = player.get_player_ped(i)
                    local cur_coords = entity.get_entity_coords(cur_veh)
                    gameplay.shoot_single_bullet_between_coords(cur_coords, cur_coords, 10, 0xB1CA77B1, temp_ped, true, false, 3)
                end
            end
            system.yield(0)
        end
        system.yield(0)
    end
    entity.delete_entity(cache_ped)
end)



-------------------------------------------------
--             PLAYER FEATURES
-------------------------------------------------


-------------------------------------------------
-- PLAYER FEAT > RACIST NIGGER KILL
-------------------------------------------------

local send_racist_msg
menu.add_player_feature("Racist Kill", "value_str", player_parent.troll, function(feat, pid)
    local count = 1
    local is_logged = false
    local pid_name
    local pid_scid
    while feat.on do
        local ped_model = 0x403DB4FD
        local request = req_model(ped_model)
        
        if not request then
            notify("Line 85 | An unexpected error has occured. Unable to load model!", "", 6, "R")
            return
        end
        
        pid_name = player.get_player_name(pid)
        pid_scid = player.get_player_scid(pid)
        local pped = player.get_player_ped(pid)
        
        if player.is_player_in_any_vehicle(pid) then
            local loop_time = utils.time_ms() + 100
            -- To kick them out of their vehicle if they are in one :)
            while loop_time > utils.time_ms() do
                ped.clear_ped_tasks_immediately(pped)
                system.yield(0)
            end
        end
        
        local pid_coords = player.get_player_coords(pid)
        pid_coords.y = pid_coords.y + 5
        local pid_heading = player.get_player_heading(pid)
        pid_heading = -pid_heading -- To make the entity face the player
        local created_ped = ped.create_ped(6, ped_model, pid_coords, pid_heading, true, false)
        local curr_ped_coords = entity.get_entity_coords(created_ped)
        local scare_bullet_coords = curr_ped_coords
        scare_bullet_coords.x = scare_bullet_coords.x + 1
        if not weapon.has_ped_got_weapon(pped, 0x97EA20B8) then
            weapon.give_delayed_weapon_to_ped(pped, 0x97EA20B8, 100, false) 
        end
        gameplay.shoot_single_bullet_between_coords(scare_bullet_coords, scare_bullet_coords, 0, 0x97EA20B8, pped, true, true, 5)
        system.yield(1500)
        
        while not entity.is_entity_dead(created_ped) do
            local __curr_coords = entity.get_entity_coords(created_ped)
            if not weapon.has_ped_got_weapon(pped, 0xB1CA77B1) then
                weapon.give_delayed_weapon_to_ped(pped, 0xB1CA77B1, 100, false) 
            end
            gameplay.shoot_single_bullet_between_coords(__curr_coords, __curr_coords, 100, 0xB1CA77B1, pped, true, false, 150)
            system.yield(0)
        end
        
        system.yield(3000)
        entity.delete_entity(created_ped)
        
        if feat.value == 0 then
            if not send_racist_msg or send_racist_msg == "" then
                send_racist_msg = "DIE NIGGERS!!"
            end
            network.send_chat_message("@"..pid_name..", "..send_racist_msg, false)
        end
        
        notify("Completed "..count.." racist round")
        count = count + 1
        if not is_logged then
            log("Racist Nigger Kill | "..pid_name..":"..pid_scid.." | Toggled on")
            is_logged = true
        end
    end
    if not feat.on then
        streaming.set_model_as_no_longer_needed(0x403DB4FD)
        log("Racist Nigger Kill | "..pid_name..":"..pid_scid.." | Toggled off")
    end
end):set_str_data({"Send Racist stuff in chat", "Don't Send Racist Stuff"})
menu.add_player_feature("Change Racist Chat message", "action_value_str", player_parent.troll, function(feat)
    if feat.value == 0 then
        local msg = get_input("Enter new chat message", "", 100, 0)
        send_racist_msg = msg
        notify("Changed message to: @PLAYER_NAME, "..send_racist_msg, "", 5, "G")
        log("Change Racist Chat Message | Changed message to: "..send_racist_msg)
    end
    if feat.value == 1 then
        send_racist_msg = ""
        notify("Successfully reset the message to default | @PLAYER_NAME, DIE NIGGERS!!", "", 4, "G")
        log("Change Racist Chat message | Reset to default executed")
    end
end):set_str_data({"Enter New Message", "Reset to Default"})

-- -----------------------------------------------
-- PLAYER FEAT > SPAM BIG VEHICLES
-- -----------------------------------------------
local spawned_veh = {}

menu.add_player_feature("Delete Spawned Vehicles", "action", player_parent.spam_big_veh, function()
    for i = 1, #spawned_veh do
        req_control(spawned_veh[i])
        entity.set_entity_as_no_longer_needed(spawned_veh[i])
        entity.set_entity_coords_no_offset(spawned_veh[i], v3(21220, -12237, 100))
        entity.delete_entity(spawned_veh[i])
        system.yield(200)
    end
    spawned_veh = {}
end)

menu.add_player_feature("Spam Cargo Plane", "action", player_parent.spam_big_veh, function(feat, pid)
    local veh_hash = 0x15F27762
    local pid_coords = player.get_player_coords(pid)
    pid_coords.z = pid_coords.z + 3
    req_model(veh_hash)
    for i = 1, 20 do
        spawned_veh[#spawned_veh + 1] = vehicle.create_vehicle(veh_hash, pid_coords, -180, true, false)
        system.yield(100)
    end
    streaming.set_model_as_no_longer_needed(veh_hash)
end)

menu.add_player_feature("Spam Jet", "action", player_parent.spam_big_veh, function(feat, pid)
    local veh_hash = 0xB39B0AE6
    local pid_coords = player.get_player_coords(pid)
    pid_coords.z = pid_coords.z + 3
    req_model(veh_hash)
    for i = 1, 20 do
        spawned_veh[#spawned_veh + 1] = vehicle.create_vehicle(veh_hash, pid_coords, -180, true, false)
        system.yield(100)
    end
    streaming.set_model_as_no_longer_needed(veh_hash)
end)

menu.add_player_feature("Spam Blazer", "action", player_parent.spam_big_veh, function(feat, pid)
    local veh_hash = 0xA1355F67
    local pid_coords = player.get_player_coords(pid)
    pid_coords.z = pid_coords.z + 3
    req_model(veh_hash)
    for i = 1, 20 do
        spawned_veh[#spawned_veh + 1] = vehicle.create_vehicle(veh_hash, pid_coords, -180, true, false)
        system.yield(100)
    end
    streaming.set_model_as_no_longer_needed(veh_hash)
end)

menu.add_player_feature("Spam Random Vehicles", "action", player_parent.spam_big_veh, function(feat, pid)
    local all_veh_hashes = vehicle.get_all_vehicle_model_hashes()
    for i = 1, 20 do
        math.randomseed(os.time())
        local rando_num = math.random(1, #all_veh_hashes)
        local veh_hash = all_veh_hashes[rando_num]
        local pid_coords = player.get_player_coords(pid)
        pid_coords.z = pid_coords.z + 3
        req_model(veh_hash)
        spawned_veh[#spawned_veh + 1] = vehicle.create_vehicle(veh_hash, pid_coords, -180, true, false)
        system.yield(100)
    end
    streaming.set_model_as_no_longer_needed(veh_hash)
end)