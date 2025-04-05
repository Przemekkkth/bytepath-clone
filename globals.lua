default_color = {222/255, 222/255, 222/255}
background_color = {16/255, 16/255, 16/255}
ammo_color = {123/255, 200/255, 164/255}
boost_color = {76/255, 195/255, 217/255}
hp_color = {241/255, 103/255, 69/255}
skill_point_color = {255/255, 198/255, 93/255}

default_colors = {default_color, hp_color, ammo_color, boost_color, skill_point_color}
negative_colors = {
    {(255-default_color[1]) / 255, (255-default_color[2]) / 255, (255-default_color[3]) / 255}, 
    {(255-hp_color[1]) / 255, (255-hp_color[2]) /255, (255-hp_color[3]) / 255}, 
    {(255-ammo_color[1]) / 255, (255-ammo_color[2]) / 255, (255-ammo_color[3]) / 255}, 
    {(255-boost_color[1]) / 255, (255-boost_color[2]) /255, (255-boost_color[3]) / 255}, 
    {(255-skill_point_color[1]) / 255, (255-skill_point_color[2]) / 255, (255-skill_point_color[3]) / 255}
}
all_colors = fn.append(default_colors, negative_colors)

attacks = {
    ['Neutral'] = {cooldown = 0.24, ammo = 0, abbreviation = 'N', color = default_color},
    ['Double'] = {cooldown = 0.32, ammo = 2, abbreviation = '2', color = ammo_color},
}

