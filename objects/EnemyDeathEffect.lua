EnemyDeathEffect = GameObject:extend()

function EnemyDeathEffect:new(area, x, y, opts)
    EnemyDeathEffect.super.new(self, area, x, y, opts)
    self.depth = 80 

    self.current_color = default_color
    self.timer:after(0.1, function() 
        self.current_color = self.color 
        self.timer:after(0.15, function()
            self.dead = true
        end)
    end)
end

function EnemyDeathEffect:update(dt)
    EnemyDeathEffect.super.update(self, dt)
end

function EnemyDeathEffect:draw()
    love.graphics.setColor(self.current_color)
    love.graphics.rectangle('fill', self.x - self.width/2, self.y - self.width/2, self.width, self.width)
    love.graphics.setColor(default_color)
end

function EnemyDeathEffect:destroy()
    EnemyDeathEffect.super.destroy(self)
end
