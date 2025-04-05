Object = require 'libraries/Classic'
Timer = require 'libraries/hump/timer'
Input = require 'libraries/boipushy/Input'
fn = require 'libraries/moses/moses'
Camera = require 'libraries/hump/camera'
Physics = require 'libraries/windfield'
Vector = require 'libraries/hump/vector'
draft = require 'libraries/draft/draft'()

require 'libraries/utf8'
require 'GameObject'
require 'utils'
require 'globals'

function love.load(arg)
    time = 0

    love.graphics.setDefaultFilter('nearest', 'nearest')
    love.graphics.setLineStyle('rough')

	loadFonts('resources/fonts')
	
	local object_files = {}
	recursiveEnumerate('objects', object_files)
	requireFiles(object_files)

	local room_files = {}
	recursiveEnumerate('rooms', room_files)
	requireFiles(room_files)

	timer = Timer()
    input = Input()
    camera = Camera(global_width / 2, global_height / 2)

    input:bind('left', 'left')
    input:bind('right', 'right')
	input:bind('up', 'up')
    input:bind('down', 'down')

	current_room = nil
	goToRoom('Stage')
	resize(2)

	slow_amount = 1
end

function love.update(dt)
    timer:update(dt)
    --camera:update(dt)
    if current_room then current_room:update(dt) end
end

function love.draw()
	if current_room then current_room:draw() end

    if flash_frames then 
        flash_frames = flash_frames - 1
        if flash_frames == -1 then flash_frames = nil end
    end
    if flash_frames then
        love.graphics.setColor(background_color)
        love.graphics.rectangle('fill', 0, 0, scale_x*global_width, scale_y*global_height)
        love.graphics.setColor(255, 255, 255)
    end
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end

function recursiveEnumerate(folder, file_list)
    local items = love.filesystem.getDirectoryItems(folder)
    for _, item in ipairs(items) do
        local file = folder .. '/' .. item
		
        if love.filesystem.getInfo(file).type == 'file' then
            table.insert(file_list, file)
        elseif love.filesystem.getInfo(file).type == 'directory' then
            recursiveEnumerate(file, file_list)
        end
    end
end

function requireFiles(files)
    for _, file in ipairs(files) do
        local file = file:sub(1, -5)
		print('file ', file)
        require(file)
    end
end

function loadFonts(path)
    fonts = {}
    local font_paths = {}
    recursiveEnumerate(path, font_paths)
    for i = 8, 16, 1 do
        for _, font_path in pairs(font_paths) do
            local last_forward_slash_index = font_path:find("/[^/]*$")
            local font_name = font_path:sub(last_forward_slash_index+1, -5)
            local font = love.graphics.newFont(font_path, i)
            font:setFilter('nearest', 'nearest')
            fonts[font_name .. '_' .. i] = font
        end
    end
end

-- Memory --
function count_all(f)
    local seen = {}
	local count_table
	count_table = function(t)
		if seen[t] then return end
		f(t)
		seen[t] = true
		for k,v in pairs(t) do
			if type(v) == "table" then
				count_table(v)
			elseif type(v) == "userdata" then
				f(v)
			end
		end
	end
	count_table(_G)
end

function type_count()
	local counts = {}
	local enumerate = function (o)
		local t = type_name(o)
		counts[t] = (counts[t] or 0) + 1
	end
	count_all(enumerate)
	return counts
end

global_type_table = nil
function type_name(o)
	if global_type_table == nil then
		global_type_table = {}
		for k,v in pairs(_G) do
			global_type_table[v] = k
		end
		global_type_table[0] = "table"
	end
	return global_type_table[getmetatable(o) or 0] or "Unknown"
end

function resize(s)
	love.window.setMode(s * global_width, s * global_height)
	scale_x = s
	scale_y = s
end

function flash(frames)
    flash_frames = frames
end

function slow(amount, duration)
    slow_amount = amount
	timer:tween(duration, _G, {slow_amount = 1}, 'in-out-cubic')
end

function goToRoom(room_type, ...)
	if current_room and current_room.destroy then 
		current_room:destroy() 
	end
    current_room = _G[room_type](...)
end