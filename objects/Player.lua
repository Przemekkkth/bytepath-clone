Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)
    self.x, self.y = x, y

    self:init()
    self:init_boost()
    self:init_hp()
    self:init_ammo()
    self:init_attacks()
    self:init_visual_ship()

    self.timer:every(0.24, function()
        self:shoot()
    end)
    self:init_boost_trial()
end

function Player:init()
    self.width, self.height = 12, 12
    self.collider = self.area.world:newCircleCollider(self.x, self.y, self.width)
    self.collider:setObject(self)

    self.radians = -math.pi / 2
    self.radians_velocity = 1.66 * math.pi
    self.velocity = 0
    self.base_max_velocity = 100
    self.max_velocity = 100
    self.acceleration = 100

    self.timer:every(5, function()
        self:tick()
    end)
end

function Player:init_boost()
    self.max_boost = 100
    self.boost = self.max_boost
    self.boosting = false
    self.can_boost = true
    self.boost_timer = 0
    self.boost_cooldown = 2
end

function Player:init_hp()
    self.max_hp = 100
    self.hp = self.max_hp
end

function Player:init_ammo()
    self.max_ammo = 100
    self.ammo = self.max_ammo
end

function Player:init_attacks()
    self.shoot_timer = 0
    self.shoot_cooldown = 0.24
    self:setAttack('Double')
end

function Player:init_visual_ship()
    self.ship = 'Fighter'
    self.polygons = {}
    if self.ship == 'Fighter' then
        self.polygons[1] = {self.width, 0, self.width / 2, -self.width / 2, -self.width / 2, -self.width / 2,
                            -self.width, 0, -self.width / 2, self.width / 2, self.width / 2, self.width / 2}

        self.polygons[2] = {self.width / 2, -self.width / 2, 0, -self.width, -self.width - self.width / 2, -self.width,
                            -3 * self.width / 4, -self.width / 4, -self.width / 2, -self.width / 2}

        self.polygons[3] = {self.width / 2, self.width / 2, -self.width / 2, self.width / 2, -3 * self.width / 4,
                            self.width / 4, -self.width - self.width / 2, self.width, 0, self.width}

    elseif self.ship == 'Striker' then
        self.polygons[1] = {self.width, 0, self.width / 2, -self.width / 2, -self.width / 2, -self.width / 2,
                            -self.width, 0, -self.width / 2, self.width / 2, self.width / 2, self.width / 2}

        self.polygons[2] = {0, self.width / 2, -self.width / 4, self.width, 0, self.width + self.width / 2, self.width,
                            self.width, 0, 2 * self.width, -self.width / 2, self.width + self.width / 2, -self.width, 0,
                            -self.width / 2, self.width / 2}

        self.polygons[3] = {0, -self.width / 2, -self.width / 4, -self.width, 0, -self.width - self.width / 2, self.w,
                            -self.width, 0, -2 * self.width, -self.width / 2, -self.width - self.width / 2, -self.width,
                            0, -self.width / 2, -self.width / 2}
    end
end

function Player:init_boost_trial()
    self.trail_color = skill_point_color
    self.timer:every(0.01, function()
        if self.ship == 'Fighter' then
            self.area:addGameObject('TrailParticle', self.x - 0.9 * self.width * math.cos(self.radians) + 0.2 *
                self.width * math.cos(self.radians - math.pi / 2), self.y - 0.9 * self.width * math.sin(self.radians) +
                0.2 * self.width * math.sin(self.radians - math.pi / 2), {
                parent = self,
                radius = random(2, 4),
                duration = random(0.15, 0.25),
                color = self.trail_color
            })

            self.area:addGameObject('TrailParticle', self.x - 0.9 * self.width * math.cos(self.radians) + 0.2 *
                self.width * math.cos(self.radians + math.pi / 2), self.y - 0.9 * self.width * math.sin(self.radians) +
                0.2 * self.width * math.sin(self.radians + math.pi / 2), {
                parent = self,
                radius = random(2, 4),
                duration = random(0.15, 0.25),
                color = self.trail_color
            })

        elseif self.ship == 'Striker' then
            self.area:addGameObject('TrailParticle', self.x - 1.0 * self.width * math.cos(self.radians) + 0.2 *
                self.width * math.cos(self.radians - math.pi / 2), self.y - 1.0 * self.width * math.sin(self.radians) +
                0.2 * self.width * math.sin(self.radians - math.pi / 2), {
                parent = self,
                radius = random(2, 4),
                duration = random(0.15, 0.25),
                color = self.trail_color
            })

            self.area:addGameObject('TrailParticle', self.x - 1.0 * self.width * math.cos(self.radians) + 0.2 *
                self.width * math.cos(self.radians + math.pi / 2), self.y - 1.0 * self.width * math.sin(self.radians) +
                0.2 * self.width * math.sin(self.radians + math.pi / 2), {
                parent = self,
                radius = random(2, 4),
                duration = random(0.15, 0.25),
                color = self.trail_color
            })
        end
    end)
end

function Player:update(dt)
    Player.super.update(self, dt)

    self:check_collisions()
    self:handle_boost(dt)
    self:move(dt)
end

function Player:check_collisions()
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

    if self.collider:enter('Collectable') then
        local collision_data = self.collider:getEnterCollisionData('Collectable')
        local object = collision_data.collider:getObject()

        if object:is(Ammo) then
            object:die()
            self:addAmmo(5)

        elseif object:is(Boost) then
            object:die()
        end
    end
end

function Player:handle_boost(dt)
    self.boost = math.min(self.boost + 10 * dt, self.max_boost)
    self.boost_timer = self.boost_timer + dt
    if self.boost_timer > self.boost_cooldown then
        self.can_boost = true
    end
    self.max_velocity = self.base_max_velocity
    self.boosting = false
    if input:down('up') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.max_velocity = 1.5 * self.base_max_velocity
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
    end
    if input:down('down') and self.boost > 1 and self.can_boost then
        self.boosting = true
        self.max_velocity = 0.5 * self.base_max_velocity
        self.boost = self.boost - 50 * dt
        if self.boost <= 1 then
            self.boosting = false
            self.can_boost = false
            self.boost_timer = 0
        end
    end
    self.trail_color = skill_point_color
    if self.boosting then
        self.trail_color = boost_color
    end

end

function Player:move(dt)
    if input:down('left') then
        self.radians = self.radians - self.radians_velocity * dt
    end
    if input:down('right') then
        self.radians = self.radians + self.radians_velocity * dt
    end

    self.velocity = math.min(self.velocity + self.acceleration * dt, self.max_velocity)
    self.collider:setLinearVelocity(self.velocity * math.cos(self.radians), self.velocity * math.sin(self.radians))
end

function Player:draw()

    -- love.graphics.circle('line', self.x, self.y, self.width)
    -- love.graphics.line(self.x, self.y, self.x + 2*self.width*math.cos(self.radians), self.y + 2*self.width*math.sin(self.radians))

    pushRotate(self.x, self.y, self.radians)
    love.graphics.setColor(default_color)
    for _, vertice_group in ipairs(self.polygons) do
        local points = fn.map(vertice_group, function(v, k)
            -- print('k ', k)
            -- print('v ', v)
            if (k % 2) == 1 then
                -- print("k%2 ", v)
                return self.x + v + random(-1, 1)
            else
                -- print(" ", v)
                return self.y + v + random(-1, 1)
            end
        end)
        love.graphics.polygon('line', points)
    end
    love.graphics.pop()
end

function Player:destroy()
    Player.super.destroy(self)
end

function Player:shoot()
    -- To Do
    local d = 1.2 * self.width
    self.area:addGameObject('ShootEffect', self.x + d * math.cos(self.radians), self.y + d * math.sin(self.radians), {
        player = self,
        diameter = d
    })

    if self.attack == 'Neutral' then
        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.radians),
            self.y + 1.5 * d * math.sin(self.radians), {
                radians = self.radians,
                attack = self.attack
            })
    elseif self.attack == 'Double' then
        self.ammo = self.ammo - attacks[self.attack].ammo
        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.radians + math.pi / 12),
            self.y + 1.5 * d * math.sin(self.radians + math.pi / 12), {
                radians = self.radians + math.pi / 12,
                attack = self.attack
            })

        self.area:addGameObject('Projectile', self.x + 1.5 * d * math.cos(self.radians - math.pi / 12),
            self.y + 1.5 * d * math.sin(self.radians - math.pi / 12), {
                radians = self.radians - math.pi / 12,
                attack = self.attack
            })

    end

    if self.ammo <= 0 then
        self:setAttack('Neutral')
        self.ammo = self.max_ammo
    end
end

function Player:tick()
    self.area:addGameObject('TickEffect', self.x, self.y, {
        parent = self
    })
end

function Player:die()
    self.dead = true
    flash(12)
    -- camera:shake(6, 60, 0.4)
    slow(0.15, 1)
    for i = 1, love.math.random(8, 12) do
        self.area:addGameObject('ExplodeParticle', self.x, self.y)
    end
end

function Player:setAttack(attack)
    self.attack = attack
    self.shoot_cooldown = attacks[attack].cooldown
    self.ammo = self.max_ammo
end

function Player:addAmmo(amount)
    self.ammo = math.min(self.ammo + amount, self.max_ammo)
end
