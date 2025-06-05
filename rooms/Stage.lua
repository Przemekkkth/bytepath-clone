Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()

    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Enemy')
    self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile', 'Player'}})
    self.area.world:addCollisionClass('Collectable', {ignores = {'Collectable', 'Projectile'}})
    self.area.world:addCollisionClass('EnemyProjectile', {ignores = {'EnemyProjectile', 'Projectile', 'Enemy'}})

    self.font = fonts.m5x7_16
    self.director = Director(self)

    self.main_canvas = love.graphics.newCanvas(global_width, global_height)
    self.player = self.area:addGameObject('Player', global_width / 2, global_height / 2)
    input:bind('p', function() self.area:addGameObject('Boost', 0, 0) end)
    input:bind('o', function() self.area:addGameObject('Ammo', 0, 0) end)
    input:bind('r', function() self.area:addGameObject('Rock', 110, 110) end)
    input:bind('s', function() self.area:addGameObject('Shooter', 222, 110) end)
    self.score = 0
end

function Stage:update(dt)
    self.director:update(dt)
    camera.smoother = Camera.smooth.damped(5)
    --camera:lockPosition(dt, global_width / 2, global_height / 2)
    self.area:update(dt)
end

function Stage:draw()
    love.graphics.setCanvas(self.main_canvas)
    love.graphics.clear()
        camera:attach(0,0, global_width, global_height)
        self.area:draw()
        camera:detach()
        love.graphics.setFont(self.font)

        -- Score
        love.graphics.setColor(default_color)
        love.graphics.print(self.score, global_width - 20, 10, 0, 1, 1, math.floor(self.font:getWidth(self.score)/2), math.floor(self.font:getHeight()/2))
        love.graphics.setColor(255, 255, 255)

        -- HP
        local r, g, b = unpack(hp_color)
        local hp, max_hp = self.player.hp, self.player.max_hp
        love.graphics.setColor(r, g, b)
        love.graphics.rectangle('fill', global_width/2 - 52, global_height - 16, 48*(hp/max_hp), 4)
        love.graphics.setColor(r - (32/255), g - (32/255), b - (32/255))
        love.graphics.rectangle('line', global_width/2 - 52, global_height - 16, 48, 4)
        love.graphics.print('HP', global_width/2 - 52 + 24, global_height - 24, 0, 1, 1, math.floor(self.font:getWidth('HP')/2), math.floor(self.font:getHeight()/2))
        love.graphics.print(hp .. '/' .. max_hp, global_width/2 - 52 + 24, global_height - 6, 0, 1, 1, math.floor(self.font:getWidth(hp .. '/' .. max_hp)/2), math.floor(self.font:getHeight()/2))
        love.graphics.setColor(1, 1, 1)

        -- Ammmo
        r, g, b = unpack(ammo_color)
        local ammo, max_ammo = self.player.ammo, self.player.max_ammo
        love.graphics.setColor(r, g, b) 
        love.graphics.rectangle('fill', global_width/2 - 52, 16, 48*(ammo/max_ammo), 4)
        love.graphics.setColor(r - (32/255), g - (32/255), b - (32/255))
        love.graphics.rectangle('line', global_width/2 - 52, 16, 48, 4)
        love.graphics.print('Ammo', global_width/2 - 52 + 24, 8, 0, 1, 1, math.floor(self.font:getWidth('Ammo')/2), math.floor(self.font:getHeight()/2))

        -- Boost
        r, g, b = unpack(boost_color)
        local boost, max_boost = self.player.boost, self.player.max_boost
        love.graphics.setColor(r, g, b) 
        love.graphics.rectangle('fill', global_width/2 + 4, 16, 48*(boost/max_boost), 4)
        love.graphics.setColor(r - (32/255), g - (32/255), b - (32/255))
        love.graphics.rectangle('line', global_width/2 + 4, 16, 48, 4)
        love.graphics.print('Boost', global_width/2 + 4 + 24, 8, 0, 1, 1, math.floor(self.font:getWidth('Boost')/2), math.floor(self.font:getHeight()/2))
    love.graphics.setCanvas()

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.draw(self.main_canvas, 0, 0, 0, scale_x, scale_y)
    love.graphics.setBlendMode('alpha')

    
end

function Stage:destroy()
    self.area:destroy()
    self.area = nil
end

function Stage:finish()
    timer:after(1, function()
        goToRoom('Stage')
    end)
end