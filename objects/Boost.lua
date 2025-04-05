Boost = GameObject:extend()

function Boost:new(area, x, y, opts)
    Boost.super.new(self, area, x, y, opts)

    local direction = table.random({-1, 1})
    self.x = global_width/2 + direction*(global_width/2 + 48)
    self.y = random(48, global_height - 48)

    self.width, self.height = 12, 12
    self.collider = self.area.world:newRectangleCollider(self.x, self.y, self.width, self.height)
    self.collider:setObject(self)
    self.collider:setCollisionClass('Collectable')
    self.collider:setFixedRotation(false)
    self.velocity = -direction*random(20, 40)
    self.collider:setLinearVelocity(self.velocity, 0)
    self.collider:applyAngularImpulse(random(-24, 24))
end

function Boost:update(dt)
    Boost.super.update(self, dt)

    self.collider:setLinearVelocity(self.velocity, 0) 
end

function Boost:draw()
    love.graphics.setColor(boost_color)
    pushRotate(self.x, self.y, self.collider:getAngle())
    draft:rhombus(self.x, self.y, 1.5*self.width, 1.5*self.height, 'line')
    draft:rhombus(self.x, self.y, 0.5*self.width, 0.5*self.height, 'fill')
    love.graphics.pop()
    love.graphics.setColor(default_color)
end

function Boost:destroy()
    Boost.super.destroy(self)
end

function Boost:die()
    self.dead = true
    self.area:addGameObject('BoostEffect', self.x, self.y, {color = boost_color, width = self.width, height = self.height})
    self.area:addGameObject('InfoText', self.x + table.random({-1, 1})*self.width, self.y + table.random({-1, 1})*self.height, {color = boost_color, text = '+BOOST'})
end
