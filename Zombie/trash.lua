--Code I did not use from the tutorial due to improvements made by me--

-- Eliminate zombie and bullet when they collide --
z.dead = true
b.dead = true

for i=#zombies, 1, -1 do
    local z = zombies[i]
    if z.dead == true then
        table.remove(zombies, i)
    end
end
for i=#bullets, 1, -1 do
    local b = bullets[i]
    if b.dead == true then
        table.remove(bullets, i)
    end
end

-- Trigger spawn bullet --
function love.mousepressed(x, y, button)
    if button == 1 and gameState == 2 then
        spawnBullet()
    end
end