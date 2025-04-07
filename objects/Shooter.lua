Shooter = GameObject:extend()

function Shooter:new(area, x, y, opts)
    Shooter.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = global_width/2 + direction*(global_width/2 + 48)
    self.y = random(16, global_height - 16)

    self.width, self.height = 12, 6
    self.collider = self.area.world:newPolygonCollider({self.width, 0, -self.width/2, self.height, -self.width, 0, -self.width/2, -self.height})
    self.collider:setPosition(self.x, self.y)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Enemy')
    self.velocity = -direction*random(20, 40)
    self.collider:setFixedRotation(false)
    self.collider:setAngle(direction == 1 and math.pi or 0)
    self.collider:setFixedRotation(true)
    self.collider:setLinearVelocity(self.velocity, 0)

    self.hp = 100

    self.timer:every(random(3, 5), function()
        self.area:addGameObject('PreAttackEffect', self.x + 1.4*self.width*math.cos(self.collider:getAngle()), self.y + 1.4*self.width*math.sin(self.collider:getAngle()), 
        {shooter = self, color = hp_color, duration = 1})
        self.timer:after(1, function()
            self.area:addGameObject('EnemyProjectile', self.x + 1.4*self.width*math.cos(self.collider:getAngle()), self.y + 1.4*self.width*math.sin(self.collider:getAngle()), 
            {radians = math.atan2(current_room.player.y - self.y, current_room.player.x - self.x), velocity = random(80, 100), size = 3.5})
        end)
    end)
end

function Shooter:update(dt)
    Shooter.super.update(self, dt)

    self.collider:setLinearVelocity(self.velocity, 0) 
end

function Shooter:draw()
    love.graphics.setColor(hp_color)
    if self.hit_flash then love.graphics.setColor(default_color) end
    local points = {self.collider:getWorldPoints(self.collider.shapes.main:getPoints())}
    love.graphics.polygon('line', points)
    love.graphics.setColor(default_color)
end

function Shooter:destroy()
    Shooter.super.destroy(self)
end

function Shooter:hit(damage)
    if self.dead then return end

    self.hp = self.hp - (damage or 100)
    if self.hp <= 0 then
        self.dead = true
        self.area:addGameObject('Ammo', self.x, self.y)
        self.area:addGameObject('EnemyDeathEffect', self.x, self.y, {color = hp_color, width = 2.5*self.width})
    else
        self.hit_flash = true
        self.timer:after('hit_flash', 0.2, function() self.hit_flash = false end)
    end
end
