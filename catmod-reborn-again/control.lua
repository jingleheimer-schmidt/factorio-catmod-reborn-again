script.on_event(defines.events.on_player_cursor_stack_changed, function(event)
  local player = game.get_player(event.player_index)
  if not player.cursor_stack or not player.character then
    return
  else
    if player.cursor_stack.valid_for_read and player.cursor_stack.name and player.cursor_stack.name == "raw-fish" then
      local cats = player.surface.find_entities_filtered({
        position = player.position,
        radius = 15,
        name = "cat",
      })
      if cats then
        local unit_group = player.surface.create_unit_group{position = player.position, force = player.force}
        for each, cat in pairs(cats) do
          unit_group.add_member(cat)
        end
        unit_group.set_command({type = defines.command.go_to_location, destination_entity = player.character})
        if not global.unit_groups then global.unit_groups = {} end
        global.unit_groups[unit_group.group_number] = {unit_group = unit_group, command = unit_group.command}
        if not global.players then global.players = {} end
        global.players[player.index] = player
      end
    end
  end
end)

script.on_event(defines.events.on_ai_command_completed, function(event)
  if global.unit_groups then
    if global.unit_groups[event.unit_number] then
      global.unit_groups[event.unit_number].unit_group.set_autonomous()
      global.unit_groups[event.unit_number] = nil
    end
  end
end)

script.on_nth_tick(5, function()
  if not global.players then
    return
  else
    for index, player in pairs(global.players) do
      if player.valid and player.cursor_stack.valid_for_read and player.cursor_stack.name and player.cursor_stack.name == "raw-fish" then
        local cats = player.surface.find_entities_filtered({
          position = player.position,
          radius = 20,
          name = "cat",
        })
        if cats then
          local unit_group = player.surface.create_unit_group{position = player.position, force = player.force}
          for each, cat in pairs(cats) do
            if not cat.unit_group then
              unit_group.add_member(cat)
            elseif not cat.unit_group.is_script_driven then
                unit_group.add_member(cat)
            elseif cat.unit_group.command then
              local cat_command = cat.unit_group.command
              if global.unit_groups and global.unit_groups[cat.unit_group.group_number] then
                local stored_command = global.unit_groups[cat.unit_group.group_number].command
                if stored_command.destination_entity and stored_command.destination_entity.valid then
                  if cat_command.destination_entity and cat_command.destination_entity.valid then
                    if cat_command.destination_entity.associated_player and stored_command.destination_entity.associated_player then
                      if cat_command.destination_entity.associated_player.index ~= stored_command.destination_entity.associated_player.index then
                        unit_group.add_member(cat)
                      end
                    end
                  end
                end
              end
            end
          end
          unit_group.set_command({type = defines.command.go_to_location, destination_entity = player.character})
          if not global.unit_groups then
            global.unit_groups = {}
          end
          global.unit_groups[unit_group.group_number] = {unit_group = unit_group, command = unit_group.command}
        end
      end
    end
  end
end
)
