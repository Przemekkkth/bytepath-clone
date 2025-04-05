Ammo = GameObject:extend()

function Ammo:new(area, x, y, opts)
    Ammo.super.new(self, area, x, y, opts)

    self.width, self.height = 8, 8
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.radians = random(0, 2*math.pi)
    self.velocity = random(10, 20)
    self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians))
    self.collider:applyAngularImpulse(random(-24, 24))
end

function Ammo:update(dt)
    Ammo.super.update(self, dt)

    local target = current_room.player
    if target then
        local projectile_heading = Vector(self.collider:getLinearVelocity()):normalized()
        local angle = math.atan2(target.y - self.y, target.x - self.x)
        local to_target_heading = Vector(math.cos(angle), math.sin(angle)):normalized()
        local final_heading = (projectile_heading + 0.1*to_target_heading):normalized()
        self.collider:setLinearVelocity(self.velocity*final_heading.x, self.velocity*final_heading.y)
    else 
        self.collider:setLinearVelocity(self.velocity*math.cos(self.radians), self.velocity*math.sin(self.radians)) 
    end
end

function Ammo:draw()
    love.graphics.setColor(ammo_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, self.width, self.height, 'line')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Ammo:destroy()
    Ammo.super.destroy(self)
end

function Ammo:die()
    self.dead = true
    for i = 1, love.math.random(4, 8) do 
        self.area:addGameObject('ExplodeParticle', self.x, self.y, {size = 3, color = ammo_color}) 
    end
    self.area:addGameObject('AmmoEffect', self.x, self.y, {color = ammo_color, width = self.width, height = self.height})
end
