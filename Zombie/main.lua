function love.load()

    -- RAMDOM --
    math.randomseed(os.time())

    -- GAMESTATE -
    gameState = 1

    -- TIMER--
    maxTime = 2
    timer = maxTime
    maxTimeBullet = math.random(0, 1)
    bulletTimer = maxTimeBullet

    -- IMAGES --
    sprites = {}
    sprites.background = love.graphics.newImage('assets/sprites/background.png')
    sprites.bullet = love.graphics.newImage('assets/sprites/bullet.png')
    sprites.player = love.graphics.newImage('assets/sprites/player.png')
    sprites.zombie = love.graphics.newImage('assets/sprites/zombie.png')
    sprites.blood = love.graphics.newImage('assets/sprites/blood.png')

    -- PLAYER --
    player = {}
    player.x = love.graphics.getWidth() / 2
    player.y = love.graphics.getHeight() / 2
    player.speed = 400

    -- ZOMBIES --
    zombies = {}

    -- BLOOD --
    bloods = {}

    -- BULLETS --
    bullets = {}

    -- FONT --
    myFont = love.graphics.newFont(30)

    -- SCORE --
    score = 0

    -- LIVES --
    lives = 1

    -- Music -- 
    music = {}
    music.background = love.audio.newSource("assets/music/background.wav", "stream")
    music.background:setLooping(true)
    music.background:setVolume(0.5)
    music.background:play()

    -- Sounds --
    sounds = {}
    sounds.gun = love.audio.newSource("assets/sounds/gun.wav", "static")
    sounds.gun:setVolume(0.3)
    sounds.impact = love.audio.newSource("assets/sounds/impact.wav", "static")
    sounds.impact:setVolume(0.2)
    sounds.hurt = love.audio.newSource("assets/sounds/hurt.wav", "static")
    sounds.dying = love.audio.newSource("assets/sounds/dying.wav", "static")
    sounds.dying:setVolume(0.3)
end

function love.update(dt)
-- PLAYER --
    --Movement--
    if lives == 0 then
        player.speed = 600
    end
    
    if gameState == 2 then
        if love.keyboard.isDown("d") and player.x < love.graphics.getWidth() then
            player.x = player.x + player.speed * dt
        elseif love.keyboard.isDown("a") and player.x > 0 then
            player.x = player.x - player.speed * dt
        end
        if love.keyboard.isDown("w") and player.y > 0 then
            player.y = player.y - player.speed * dt
        elseif love.keyboard.isDown("s") and player.y < love.graphics.getHeight() then
            player.y = player.y + player.speed * dt
        end
    end

-- BULLET --
    --Spawn--
    bulletTimer = bulletTimer - dt
    if love.mouse.isDown(1) and bulletTimer < 0 then
        spawnBullet()
        sounds.gun:seek(0, "seconds")
        sounds.gun:play()
        bulletTimer = maxTimeBullet
        if maxTimeBullet > 0.1 then
            maxTimeBullet = maxTimeBullet * 0.97
        end
    end
    --Movement--
    for i,b in ipairs(bullets) do
        b.x = b.x + (math.cos(b.direction) * b.speed * dt)
        b.y = b.y + (math.sin(b.direction) * b.speed * dt)
    end
    --Delete--
    for i=#bullets, 1, -1 do
        local b = bullets[i]
        if b.x < 0 or b.y < 0 or b.x > love.graphics.getWidth() or b.y > love.graphics.getHeight() then
            table.remove(bullets, i)
        end
    end

-- ZOMBIE --
    --Spawn--
    if gameState == 2 then
        timer = timer - dt
        if timer <= 0 then
            spawnZombie()
            timer = maxTime
            if maxTime > 0.3 then
                maxTime = 0.95 * maxTime
            end
        end
    end
    --Movement--
    for i,z in ipairs(zombies) do
        z.x = z.x + (math.cos(zombiePlayerAngle(z)) * z.speed * dt)
        z.y = z.y + (math.sin(zombiePlayerAngle(z)) * z.speed * dt)
        --Collision with player--
        if distanceBetween(z.x, z.y, player.x, player.y) < 30 then
            if lives == 1 then
                lives = 0
                table.remove(zombies, i)
                sounds.hurt:play()
            elseif lives == 0 then
                for i,z in ipairs(zombies) do
                    zombies[i] = nil
                end
                for i,b in ipairs(bloods) do
                    bloods[i] = nil
                end
                gameState = 1
                lives = 1
                player.x = love.graphics.getWidth()/2
                player.y = love.graphics.getHeight()/2
                player.speed = 400
                sounds.dying:play()
            end
        end
        --Collision with bullet--
        for j,b in ipairs(bullets) do  
            if distanceBetween(z.x, z.y, b.x, b.y) < 20 then
                spawnBlood(z.x, z.y)
                table.remove(zombies, i)
                table.remove(bullets, j)
                score = score + 1
                sounds.impact:seek(0, "seconds")
                sounds.impact:play()
            end
        end
    end
end

function love.draw()
    -- BACKGROUND --
    love.graphics.draw(sprites.background, 0, 0)

    -- MENU --
    if gameState == 1 then
        local blink = math.abs(math.cos(love.timer.getTime() * 1.2 % 2 * math.pi))
        love.graphics.setColor(1, 1, 1, blink)
        love.graphics.setFont(myFont)
        love.graphics.printf("START", 0, 80, love.graphics.getWidth(), "center")
    end
    love.graphics.setColor(1, 1, 1)

    -- BLOOD --
    love.graphics.setColor(0.3, 1, 1)
    for i,b in ipairs(bloods) do
        love.graphics.draw(sprites.blood, b.x, b.y, b.direction, 0.7, 0.7, sprites.blood:getWidth()/2, sprites.bullet:getHeight()/2)
    end
    love.graphics.setColor(1, 1, 1)

    -- SCORE --
    love.graphics.printf("Score: " .. score, 0, love.graphics.getHeight() - 100, love.graphics.getWidth(), "center")

    --PLAYER --
    if lives == 0 then
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.draw(sprites.player, player.x, player.y, playerMouseAngle(), nil, nil, sprites.player:getWidth()/2, sprites.player:getHeight()/2)
    love.graphics.setColor(1, 1, 1)

    -- ZOMBIES --
    for i,z in ipairs(zombies) do
        love.graphics.draw(sprites.zombie, z.x, z.y, zombiePlayerAngle(z), nil, nil, sprites.zombie:getWidth()/2, sprites.zombie:getHeight()/2)
    end

    -- BULLETS --
    for i,b in ipairs(bullets) do
        love.graphics.draw(sprites.bullet, b.x, b.y, nil, 0.5, 0.5, sprites.bullet:getWidth()/2, sprites.bullet:getHeight()/2)
    end
end

--------------------------------------------------------------------------------------------------------------
--Start--
function love.keypressed(key)
    if gameState == 1 and key == "space" then
        gameState = 2
        maxTime = 2
        timer = maxTime
        score = 0
        maxTimeBullet = 1
    end
end

--Player follows mouse--
function playerMouseAngle()
    return math.atan2(player.y - love.mouse.getY(), player.x - love.mouse.getX()) + math.pi
end

--Zombie follows player--
function zombiePlayerAngle(zombie)
    return math.atan2(player.y - zombie.y, player.x - zombie.x)
end

--Spawn zombie--
function spawnZombie()
    local zombie = {}
    zombie.x = 0
    zombie.y = 0
    zombie.speed = 140

    --Zombie spawn location -
    local side = math.random(1,4)
    if side == 1 then 
        zombie.x = -30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 2 then 
        zombie.x = love.graphics.getWidth() + 30
        zombie.y = math.random(0, love.graphics.getHeight())
    elseif side == 3 then 
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = -30
    elseif side == 4 then 
        zombie.x = math.random(0, love.graphics.getWidth())
        zombie.y = love.graphics.getHeight() + 30
    end
    table.insert(zombies, zombie)
end

--Spawn blood--
function spawnBlood(x, y)
    local blood = {}
    blood.x = x
    blood.y = y
    blood.direction = playerMouseAngle()
    table.insert(bloods, blood)
end

--Spawn bullet--
function spawnBullet()
    local bullet = {}
    bullet.x = player.x
    bullet.y = player.y
    bullet.speed = 500
    bullet.direction = playerMouseAngle()
    table.insert(bullets, bullet)
end

--Calculate distance between two objects--
function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2-y1)^2 )
end