Projectile = GameObject:extend()

function Projectile:new(area, x, y, opts)
    Projectile.super.new(self, area, x, y, opts)

    self.size = opts.size or 2.5
    self.velocity = opts.velocity or 200
    self.color = attacks[self.attack].color

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.size)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Projectile')
    self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians))
end

function Projectile:update(dt)
    Projectile.super.update(self, dt)

    self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians))

    if self.x < 0 then
         self:die() 
    end
    if self.y < 0 then 
        self:die() 
    end
    if self.x > global_width then 
        self:die() 
    end
    if self.y > global_height then 
        self:die() 
    end
end

function Projectile:draw()
    local vx, vy = self.collider:getLinearVelocity()
    
    local angle = math.atan2(vy, vx)
    --print('angle ', angle)
    --print('angle ', math.pi / 4)
    pushRotate(self.x, self.y, angle) 
    love.graphics.setLineWidth(self.size - self.size/4)
    love.graphics.setColor(self.color)
    love.graphics.line(self.x - 2*self.size, self.y, self.x, self.y)
    love.graphics.setColor(default_color)
    love.graphics.line(self.x, self.y, self.x + 2*self.size, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
end

function Projectile:destroy()
    Projectile.super.destroy(self)
end

function Projectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = self.color or default_color, width = 3*self.size})
end