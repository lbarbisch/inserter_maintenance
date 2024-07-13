-- control.lua

-- Ensure global table to keep track of inserter states is initialized
local function initialize_global()
if not global.inserter_states then
    global.inserter_states = {}
end
end

local function alert_on_destroyed(pole, consumption, log_to_chat)
    local force = pole.force
    if force then
        for _, player in pairs(force.players) do
            player.add_alert(pole, defines.alert_type.entity_destroyed)
        end
    end
end

-- Function to handle inserter cycles
local function handle_inserter_cycle(inserter)
    if inserter and inserter.valid then
        -- Get the inserter's unit number
        local unit_number = inserter.unit_number
        local has_held_stack = inserter.held_stack.valid_for_read

        if has_held_stack then
        if not global.inserter_states[unit_number] then
            -- Inserter just picked up an item
            global.inserter_states[unit_number] = true
            --game.print("Inserter " .. unit_number .. " picked up an item!")

            -- distinguish betwenn different inserter types
            if inserter.name == "burner-inserter" then
                inserter.health = inserter.health - 4
            end
            if inserter.name == "inserter" then
                inserter.health = inserter.health - 4
            end
            if inserter.name == "long-handed-inserter" then
                inserter.health = inserter.health - 3
            end
            if inserter.name == "fast-inserter" then
                inserter.health = inserter.health - 3
            end
            if inserter.name == "filter-inserter" then
                inserter.health = inserter.health - 3
            end
            if inserter.name == "stack-inserter" then
                inserter.health = inserter.health - 1
            end
            if inserter.name == "stack-filter-inserter" then
                inserter.health = inserter.health - 1
            end

            -- destroy item once health is 0
            if inserter.health == 0 then
                alert_on_destroyed(inserter, defines.alert_type.entity_destroyed)
                inserter.die()
            end
        end
        elseif global.inserter_states[unit_number] then
        -- Inserter just dropped an item
        global.inserter_states[unit_number] = nil
        --game.print("Inserter " .. unit_number .. " dropped an item!")
            
        end
    end
end

-- Event handler to track inserter creation
local function on_built_entity(event)
    local entity = event.created_entity or event.entity
    if entity and entity.valid and entity.type == "inserter" then
        global.inserter_states[entity.unit_number] = nil
    end
end

-- Event handler to track inserter removal
local function on_removed_entity(event)
    local entity = event.entity
    if entity and entity.valid and entity.type == "inserter" then
        global.inserter_states[entity.unit_number] = nil
    end
end

-- Event handler to update inserter states every tick
local function on_tick(event)
    initialize_global() -- Ensure global.inserter_states is initialized
    for _, surface in pairs(game.surfaces) do
        for _, inserter in pairs(surface.find_entities_filtered({ type = "inserter" })) do
        handle_inserter_cycle(inserter)
        end
    end
end

-- Register event handlers
script.on_event(defines.events.on_built_entity, on_built_entity)
script.on_event(defines.events.on_robot_built_entity, on_built_entity)
script.on_event(defines.events.on_entity_died, on_removed_entity)
script.on_event(defines.events.on_player_mined_entity, on_removed_entity)
script.on_event(defines.events.on_robot_mined_entity, on_removed_entity)
script.on_event(defines.events.on_tick, on_tick)

-- Initialize global state
script.on_init(function()
initialize_global()
end)

script.on_configuration_changed(function()
initialize_global()
end)