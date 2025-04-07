Stage = Object:extend()

function Stage:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()

    self.area.world:addCollisionClass('Player')
    self.area.world:addCollisionClass('Enemy')
    self.area.world:addCollisionClass('Projectile', {ignores = {'Projectile', 'Player'}})
    self.area.world:addCollisionClass('Collectable', {ignores = {'Collectable', 'Projectile'}})
    self.area.world:addCollisionClass('EnemyProjectile', {ignores = {'EnemyProjectile', 'Projectile', 'Enemy'}})

    self.main_canvas = love.graphics.newCanvas(global_width, global_height)
    self.player = self.area:addGameObject('Player', global_width / 2, global_height / 2)
    input:bind('p', function() self.area:addGameObject('Boost', 0, 0) end)
    input:bind('o', function() self.area:addGameObject('Ammo', 0, 0) end)
    input:bind('r', function() self.area:addGameObject('Rock', 110, 110) end)
    input:bind('s', function() self.area:addGameObject('Shooter', 222, 110) end)
end

function Stage:update(dt)
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
