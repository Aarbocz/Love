require "collision"

function love.load()

    -- RANDOM --
    math.randomseed(os.time())

    -- PLAYER --
    player = {}
    player.w = 65
    player.h = 80
    player.x = 50
    player.y = 300
    player.direction = "down"

    -- COINS --
    coins = {}

    -- SCORE --
    score = 0

    -- SOUND EFFECTS --
    sounds = {}
    sounds.coin = love.audio.newSource("assets/sounds/coin.wav", "static")

    -- FONTS --
    fonts = {}
    fonts.large = love.graphics.newFont("assets/fonts/Gamer.ttf", 36)

    -- IMAGES --
    images = {}
    images.background = love.graphics.newImage("assets/images/ground.png")
    images.coin = love.graphics.newImage("assets/images/coin.png")
    images.player_down = love.graphics.newImage("assets/images/player_down.png")
    images.player_up = love.graphics.newImage("assets/images/player_up.png")
    images.player_left = love.graphics.newImage("assets/images/player_left.png")
    images.player_right = love.graphics.newImage("assets/images/player_right.png")
end

function love.update(dt)
    
    -- MOVE -- 
    if love.keyboard.isDown("right") then 
        player.x = player.x + 10
        player.direction = "right"
    elseif love.keyboard.isDown("left") then 
        player.x = player.x - 10
        player.direction = "left"
    end
    if love.keyboard.isDown("down") then 
        player.y = player.y + 10
        player.direction = "down"
    elseif love.keyboard.isDown("up") then 
        player.y = player.y - 10
        player.direction = "up"
    end

    -- COLLISION --
    for i=#coins,1, -1 do
        local coin = coins[i]
        if AABB(player.x, player.y, player.w, player.h, coin.x, coin.y, coin.w, coin.h) then
            table.remove(coins, i)
            score = score + 1
            sounds.coin:seek(0, "seconds")
            sounds.coin:play()
        end
    end

    -- ADD COINS --
    if math.random() < 0.02 then
        local coin = {}
        coin.w = 56
        coin.h = 56
        coin.x = math.random(0, 800 - coin.w)
        coin.y = math.random(0, 600 - coin.h)
        table.insert(coins, coin)
    end
end

function love.draw()
    -- BACKGROUND --
    for x=0, love.graphics.getWidth(), images.background:getWidth() do
        for y=0, love.graphics.getHeight(), images.background:getHeight() do 
            love.graphics.draw(images.background, x, y)
        end
    end

    -- PLAYER --
    local img = images.player_down
    if player.direction == "right" then
        img = images.player_right
    elseif player.direction == "left" then
        img = images.player_left
    elseif player.direction == "up" then
        img = images.player_up
    elseif player.direction == "down" then
        img = images.player_down
    end
    love.graphics.draw(img, player.x, player.y, nil, 0.8, 0.8, -30, -30)
  

    -- COIN --
    for i=1, #coins, 1 do
        local coin = coins[i]
        love.graphics.draw(images.coin, coin.x, coin.y)
    end 

    -- SCORE --
    love.graphics.setFont(fonts.large)
    love.graphics.print("Score: " .. score, 10, 10)
end