TargetParticle = GameObject:extend()

function TargetParticle:new(area, x, y, opts)
    TargetParticle.super.new(self, area, x, y, opts)

    self.radius = opts.radius or random(2, 3)
    self.timer:tween(opts.duration or random(0.1, 0.3), self, {radius = 0, x = self.target_x, y = self.target_y}, 'out-cubic', function() self.dead = true end)
end

function TargetParticle:update(dt)
    TargetParticle.super.update(self, dt)
end

function TargetParticle:draw()
    love.graphics.setColor(self.color)
    draft:rhombus(self.x, self.y, 2*self.radius, 2*self.radius, 'fill')
    love.graphics.setColor(default_color)
end

function TargetParticle:destroy()
    TargetParticle.super.destroy(self)
end
