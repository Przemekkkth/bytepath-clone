ProjectileDeathEffect = GameObject:extend()

function ProjectileDeathEffect:new(area, x, y, opts)
    ProjectileDeathEffect.super.new(self, area, x, y, opts)
    self.depth = 75

    self.first = true
    self.timer:after(0.1, function()
        self.first = false
        self.second = true
        self.timer:after(0.15, function()
            self.second = false
            self.dead = true
        end)
    end)
end

function ProjectileDeathEffect:update(dt)
    ProjectileDeathEffect.super.update(self, dt)
end

function ProjectileDeathEffect:draw()
    if self.first then 
        love.graphics.setColor(default_color)
    elseif 
        self.second then love.graphics.setColor(self.color) 
    end
    love.graphics.rectangle('fill', self.x - self.width/2, self.y - self.width/2, self.width, self.width)
end

function ProjectileDeathEffect:destroy()
    ProjectileDeathEffect.super.destroy(self)
end