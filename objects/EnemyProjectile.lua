EnemyProjectile = GameObject:extend()

function EnemyProjectile:new(area, x, y, opts)
    EnemyProjectile.super.new(self, area, x, y, opts)

    self.size = opts.size or 2.5
    self.velocity = opts.velocity or 200

    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.size)
    self.collider:setObject(self)
    self.collider:setCollisionClass('EnemyProjectile')
    self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians))

    self.damage = 1000
end

function EnemyProjectile:update(dt)
    EnemyProjectile.super.update(self, dt)

    self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians))

    if self.collider:enter('Player') then
        local collision_data = self.collider:getEnterCollisionData('Player')
        local object = collision_data.collider:getObject()

        if object then
            object:hit(self.damage)
            self:die()
        end
    end

    if self.collider:enter('Projectile') then
        local collision_data = self.collider:getEnterCollisionData('Projectile')
        local object = collision_data.collider:getObject()

        if object then
            object:die()
            self:die()
        end
    end

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

function EnemyProjectile:draw()
    love.graphics.setColor(hp_color)
    local vx, vy = self.collider:getLinearVelocity()
    local angle = math.atan2(vy, vx)
    pushRotate(self.x, self.y, angle) 
    love.graphics.setLineWidth(self.size - self.size/4)
    love.graphics.line(self.x - 2*self.size, self.y, self.x, self.y)
    love.graphics.line(self.x, self.y, self.x + 2*self.size, self.y)
    love.graphics.setLineWidth(1)
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function EnemyProjectile:destroy()
    EnemyProjectile.super.destroy(self)
end

function EnemyProjectile:die()
    self.dead = true
    self.area:addGameObject('ProjectileDeathEffect', self.x, self.y, {color = hp_color, width = 3*self.size})
end
