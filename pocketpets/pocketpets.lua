addon.name      = 'pocketpets';
addon.author    = 'Sithel';
addon.version   = '1.0.0';
addon.desc      = 'Automatically resizes all active pets (SMN, BST, PUP, DRG) in view.';

require('common');
local chat = require('chat');
local settings = require('settings');

----------------------------------------------------------------------------------------------------
-- Default Configuration
----------------------------------------------------------------------------------------------------
local default_settings = T{
    enabled     = true,
    hidePets    = false,
    targetSize  = 1.0,
    interval    = 0.5,
};

local user_settings = settings.load(default_settings);
local last_update   = 0;

----------------------------------------------------------------------------------------------------
-- Settings Logic
----------------------------------------------------------------------------------------------------
local function SaveSettings()
    settings.save();
end

settings.register('settings', 'settings_update', function(new_settings)
    user_settings = new_settings;
end)

----------------------------------------------------------------------------------------------------
-- Pet Detection
----------------------------------------------------------------------------------------------------
local function is_pet(entity)
    if (entity == nil or entity.Name == nil) then 
        return false; 
    end
    -- Ignore all real players (Type 0)
    if (entity.Type == 0) then
        return false;
    end
    -- Pet Check via SpawnFlags
    if (bit.band(entity.SpawnFlags, 0x100) ~= 0) then
        return true;
    end
    return false;
end

----------------------------------------------------------------------------------------------------
-- Reset All Pet Sizes
----------------------------------------------------------------------------------------------------
local function reset_pet_sizes()
    for i = 0, 2303 do
        local entity = GetEntity(i);
        if entity and is_pet(entity) then
            entity.ModelSize = 1.0;
            entity.ModelUpdateFlags = 0x10;
        end
    end
end

----------------------------------------------------------------------------------------------------
-- Main Resize Loop
----------------------------------------------------------------------------------------------------
ashita.events.register('d3d_present', 'present_cb', function()
    if not user_settings.enabled then
        return;
    end

    local now = os.clock();
    if (now - last_update) < user_settings.interval then
        return;
    end
    last_update = now;

    for i = 0, 2303 do
        local entity = GetEntity(i);
        if entity and is_pet(entity) then

            if user_settings.hidePets then
                -- Hide pets
                if entity.ModelSize ~= 0.0 then
                    entity.ModelSize = 0.0;
                    entity.ModelUpdateFlags = 0x10;
                end
            else
                -- Normal resize mode
                if entity.ModelSize ~= user_settings.targetSize then
                    entity.ModelSize = user_settings.targetSize;
                    entity.ModelUpdateFlags = 0x10;
                end
            end

        end
    end
end)

----------------------------------------------------------------------------------------------------
-- Commands
----------------------------------------------------------------------------------------------------
ashita.events.register('command', 'command_cb', function(e)
    local args = e.command:lower():args();
    if #args == 0 then return end;

    if table.contains({'/pocketpets', '/pp'}, args[1]) then
        e.blocked = true;

        ----------------------------------------------------------------------
        -- Toggle
        ----------------------------------------------------------------------
        if #args == 1 then
            user_settings.enabled = not user_settings.enabled;
            SaveSettings();

            if not user_settings.enabled then
                reset_pet_sizes();
            end

            local status = user_settings.enabled and chat.success('Enabled') or chat.error('Disabled');
            print(chat.header(addon.name):append(chat.message('Auto-resizing is now: ')):append(status));
            return;
        end

        ----------------------------------------------------------------------
        -- Size
        ----------------------------------------------------------------------
        if table.contains({'size','s'}, args[2]) then
            local newSize = tonumber(args[3]);
        
            if newSize then
                -- Snap to stable values
                local stableSizes = {0.5, 1.0, 1.5, 2.0};
                local closest = 1.0;
                local bestDiff = math.huge;
        
                for _, s in ipairs(stableSizes) do
                    local diff = math.abs(newSize - s);
                    if diff < bestDiff then
                        bestDiff = diff;
                        closest = s;
                    end
                end
        
                user_settings.targetSize = closest;
                SaveSettings();
        
                print(chat.header(addon.name)
                    :append(chat.message('Pet size: '))
                    :append(chat.success(tostring(closest)))
                );
            else
                print(chat.header(addon.name):append(chat.error('Please specify a valid numeric size.')));
            end
            return;
        end

        ----------------------------------------------------------------------
        -- Status
        ----------------------------------------------------------------------
        if table.contains({'status','st'}, args[2]) then
            local status = user_settings.enabled and chat.success('Enabled') or chat.error('Disabled');
            local size   = chat.success(tostring(user_settings.targetSize));
        
            local hidden = user_settings.hidePets
                and chat.error('Hidden')
                or chat.success('Visible');
        
            print(chat.header(addon.name)
                :append(chat.message('Status: '))
                :append(status)
                :append(chat.message(' | Size: '))
                :append(size)
                :append(chat.message(' | Pets: '))
                :append(hidden)
            );
            return;
        end

        ----------------------------------------------------------------------
        -- Hide Pets
        ----------------------------------------------------------------------
        if table.contains({'hide','h'}, args[2]) then
            user_settings.hidePets = not user_settings.hidePets;
            SaveSettings();

            if user_settings.hidePets then
                print(chat.header(addon.name):append(chat.success('\31\123Pets are now hidden.')));
            else
                print(chat.header(addon.name):append(chat.message('\31\204Pets are now visible.')));
                reset_pet_sizes(); 
            end
            return;
        end

        ----------------------------------------------------------------------
        -- Reset
        ----------------------------------------------------------------------
        if table.contains({'reset','r'}, args[2]) then
            user_settings.targetSize = 1.0;
            SaveSettings();
            reset_pet_sizes();
            print(chat.header(addon.name):append(chat.message('\31\8All pets reset to default size \31\204(1.0)')));
            return;
        end

        ----------------------------------------------------------------------
        -- Help
        ----------------------------------------------------------------------
        print(chat.header(addon.name):append(chat.message('\31\207Commands:')));
        print('\31\207 /pp                \31\8 - Toggle automatic pet resizing.');
        print('\31\207 /pp s|size <value> \31\8 - Set pet size (0.5 to 2.0).');
        print('\31\207 /pp st|status      \31\8 - Show current status.');
        print('\31\207 /pp h|hide         \31\8 - Hide all pets (ModelSize = 0).');
        print('\31\207 /pp r|reset        \31\8 - Reset all pets to size 1.0.');
        return;
    end
end)

----------------------------------------------------------------------------------------------------
-- Unload
----------------------------------------------------------------------------------------------------
ashita.events.register('unload', 'unload_cb', function()
    reset_pet_sizes();
end)