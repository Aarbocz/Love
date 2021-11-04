function love.load()

    -- RAMDOM --
    math.randomseed(os.time())

    -- GAMESTATE --
    gameState = 1

    -- TARGET --
    target = {}
    target.x = 200
    target.y = 300
    target.r = 50

    -- SCORE --
    score = 0

    -- TIMER --
    timer = {}
    timer.game = 11
    timer.menu = 0.5

    -- FONTS --
    gameFont = love.graphics.newFont(40)

    -- SPRITES --
    sprites = {}
    sprites.sky = love.graphics.newImage('assets/sprites/sky.png')
    sprites.target = love.graphics.newImage('assets/sprites/target.png')
    sprites.crosshairs = love.graphics.newImage('assets/sprites/crosshairs.png')

    -- SOUNDS --
    sounds = {}
    sounds.gunshot = love.audio.newSource("assets/sounds/gunshot.wav", "static")
    sounds.shotgun = love.audio.newSource("assets/sounds/shotgun.wav", "static")
    sounds.gunshot:setVolume(0.6)
    sounds.shotgun:setVolume(0.2)

    -- MUSIC --
    music = {}
    music.background = love.audio.newSource("assets/music/background.mp3", "stream")
    music.background:setLooping(true)
    music.background:setVolume(0.5)
    music.background:play()

    -- MOUSE --
    love.mouse.setVisible(false)

end

function love.update(db)
    if gameState == 2 then
        -- TIMER --
        if timer.game >= 1 then
            timer.game = timer.game - db
        -- GAMESTATE --
        else
            gameState = 3
            timer.game = 11
        end
    end

    if gameState == 3 then
        timer.menu = timer.menu -db
    end
end

function love.draw()
    love.graphics.setFont(gameFont)

    -- BACKGROUND --
    love.graphics.draw(sprites.sky, 0, 0)

    -- MENU --
    if gameState == 1 then
        local blink = math.abs(math.cos(love.timer.getTime() * 1.2 % 2 * math.pi))
        love.graphics.setColor(1, 1, 1, blink)
        love.graphics.printf("START", 0, 250, love.graphics.getWidth() , "center")
    end
    love.graphics.setColor(1, 1, 1)

    if gameState == 2 then
        -- SCORE --
        love.graphics.print("Score: " .. score, 10, 10)

        -- TIMER --
        love.graphics.print("Time: " .. math.floor(timer.game), 600, 10)

        -- TARGET --
        love.graphics.draw(sprites.target, target.x - target.r, target.y - target.r)
    end

    if gameState == 3 then
        -- SCORE --
        love.graphics.printf("Your score is: " .. score, 0, 325, love.graphics.getWidth(), "center")

        -- RESTART --
        local blink = math.abs(math.cos(love.timer.getTime() * 1.2 % 2 * math.pi))
        love.graphics.setColor(1, 1, 1, blink)
        love.graphics.printf("RESTART", 0, 250, love.graphics.getWidth() , "center")
    end
    love.graphics.setColor(1, 1, 1)

    -- CROSSHAIRS --
    love.graphics.draw(sprites.crosshairs, love.mouse.getX() - 20, love.mouse.getY() - 20 ) 
end

----------------------------------------------------------------------------------------------

function love.mousepressed(x, y, button, istouch, presses)
    if gameState == 2 then
        local mouseToTarget = distanceBetween(x, y, target.x, target.y)
        if mouseToTarget < target.r then
            target.x = math.random(target.r, love.graphics.getWidth() - target.r )
            target.y = math.random(target.r, love.graphics.getHeight() - target.r )
            if button == 1 then
                sounds.gunshot:seek(0, "seconds")
                sounds.gunshot:play()
                score = score + 1
            elseif button == 2 then
                sounds.shotgun:seek(0, "seconds")
                sounds.shotgun:play()
                score = score + 2
                timer.game = timer.game - 1
            end
        else
            if button == 1 and score > 0 then
                score = score - 1
            elseif button == 2 then 
                timer.game = timer.game - 1
                if score > 0 then
                    score = score - 1
                end
            end
        end
    end

    if gameState == 3 and button == 1 and timer.menu <= 0 then
        gameState = 2
        score = 0
        timer.menu = 0.5
    end

    if gameState == 1 and button == 1 then
        gameState = 2
        score = 0
    end
end

function distanceBetween(x1, y1, x2, y2)
    return math.sqrt( (x2 - x1)^2 + (y2 - y1)^2 )
end