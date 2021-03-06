--Copyright © 2020, Lili
--All rights reserved.

--Redistribution and use in source and binary forms, with or without
--modification, are permitted provided that the following conditions are met:

--    * Redistributions of source code must retain the above copyright
--      notice, this list of conditions and the following disclaimer.
--    * Redistributions in binary form must reproduce the above copyright
--      notice, this list of conditions and the following disclaimer in the
--      documentation and/or other materials provided with the distribution.
--    * Neither the name of position_manager nor the
--      names of its contributors may be used to endorse or promote products
--      derived from this software without specific prior written permission.

--THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
--ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
--WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
--DISCLAIMED. IN NO EVENT SHALL Lili BE LIABLE FOR ANY
--DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
--(INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
--ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
--(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
--SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'position_manager'
_addon.author = 'Lili'
_addon.version = '1.1.2'
_addon.command = 'pm'

if not windower.file_exists(windower.windower_path .. '\\plugins\\WinControl.dll') then
    print('position_manager: error - Please install the WinControl plugin in the launcher.')
    windower.send_command('lua u position_manager')
    return
else
    print('position_manager: loading WinControl...')
    windower.send_command('load wincontrol')
end

config = require('config')

default = {
    x = 0,
    y = 0,
    delay = 0,
}

settings = config.load(default)

function move(settings)
    if settings.delay > 0 then
        coroutine.sleep(settings.delay)
    end
    windower.send_command('wincontrol move %s %s':format(settings.x, settings.y))
end

function show_help()
    windower.add_to_chat(207, 'position_manager: Commands:')
    windower.add_to_chat(207, '  //pm set <x> <y> [name]')
    windower.add_to_chat(207, '  //pm set delay <seconds> [name]')
    windower.add_to_chat(207, 'position_manager: See the readme for details.')
end

function handle_commands(cmd, ...)
    cmd = cmd or cmd:lower()

    if cmd == 'r' then
        windower.send_command('lua r position_manager')
        return
    elseif cmd == 'set' then
        local arg = {...}
        local name = arg[3]
        local err = false
        
        if name ~= nil and name:find('[%A]') then
            err = 'invalid name provided'
        elseif not name then
            name = windower.ffxi.get_player().name
        elseif name == ':all' then
            name = 'all'
        end

        if arg[1] == 'delay' then
            settings.delay = tonumber(arg[2])
            
            if settings.delay > 0 then
                config.save(settings, name)
                windower.add_to_chat(207, 'position_manager: Delay set to %s for %s.':format(settings.delay, name))
                return -- don't move window if we just set delay.
            else
                err = 'invalid delay provided'
            end
        elseif arg[1] and arg[2] then
            settings.x = tonumber(arg[1])
            settings.y = tonumber(arg[2])

            if settings.x and settings.y then
                config.save(settings, name)
                windower.add_to_chat(207, 'position_manager: Position set to %s, %s for %s.':format(settings.x, settings.y, name))
            else
                err = 'invalid position provided.'
            end
        else
            err = 'invalid arguments provided.'
        end

        if err then
            windower.add_to_chat(207, 'position_manager: ERROR - %s.':format(err))
            show_help()
        else
            if windower.ffxi.get_info().logged_in then
                player_name = windower.ffxi.get_player().name
                if name:lower() == player_name:lower() then
                    move(settings)
                end
            end
        end

        -- TODO: possibly add IPC
        return
    elseif cmd ~= 'help' then
        windower.add_to_chat(207, 'position_manager: %s command not found.':format(cmd))
    end
    show_help()
end

config.register(settings, move)

windower.register_event('addon command', handle_commands)
