function love.load()
    -- WINDFIELD LIBRARY --
    wf = require 'libraries/windfield/windfield'

    -- ANIM8 LIBRARY --
    anim8 = require 'libraries/anim8/anim8'

    -- SIMPLE TILED IMPLEMENTATION LIBRARY --
    sti = require 'libraries/Simple-Tiled-Implementation/sti'

    -- HUMP LIBRARY --
    hump = require 'libraries/hump/camera'

    -- SHOW LIBRARY --
    require('libraries/show')

    -- CAMERA --
    cam = hump()

    -- WINDOW --
    love.window.setMode(1000, 768)

    -- WORLD --
    world = wf.newWorld(0,800, false)

    -- WORLD DEBUG --
    world:setQueryDebugDrawing(true)

    -- COLLISION --
    world:addCollisionClass('Platform')
    world:addCollisionClass('Player')
    world:addCollisionClass('Danger')

    -- SPRITES --
    sprites = {}
    sprites.playerSheet = love.graphics.newImage('assets/sprites/playerSheet.png')
    sprites.enemySheet = love.graphics.newImage('assets/sprites/enemySheet.png')
    sprites.background = love.graphics.newImage('assets/sprites/background.png')

    -- SOUNDS --
    sounds = {}
    sounds.jump = love.audio.newSource('assets/audio/jump.wav', 'static')
    sounds.die = love.audio.newSource('assets/audio/die.mp3', 'static')
    sounds.win = love.audio.newSource('assets/audio/win.wav', 'static')
    sounds.music = love.audio.newSource('assets/audio/music.mp3', 'stream')
    
    sounds.jump:setVolume(0.3)
    sounds.die:setVolume(0.3)
    sounds.win:setVolume(0.3)
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.1)
    sounds.music:play()

    -- ANIMATIONS --
    local grid = anim8.newGrid(614, 564, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())
    animations = {}
    animations.idle = anim8.newAnimation(grid('1-15', 1), 0.05)
    animations.jump = anim8.newAnimation(grid('1-7', 2), 0.05)
    animations.run = anim8.newAnimation(grid('1-15', 3), 0.05)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2', 1), 0.03)

    -- PLAYER --
    require('player') --player.lua--

    -- ENEMY --
    require('enemy') --enemy.lua--

    -- DANGER ZONE --
    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    -- PLATFORMS --
    platforms = {}

    -- FLAG --
    flagX = 0
    flagY = 0

    -- SAVE --
    saveData = {}
    saveData.firstLevel = 1
    saveData.lastLevel = 2
    saveData.currentLevel = 1
    if love.filesystem.getInfo("data.lua") then
        local data = love.filesystem.load("data.lua")
        data()
    end

    -- MAP --
    loadMap("level" .. saveData.currentLevel)
end

function love.update(dt)
    -- WORLD --
    world:update(dt)

    -- MAP --
    gameMap:update(dt)

    -- PLAYER --
    playerUpdate(dt) --player.lua--

    -- ENEMY --
    updateEnemies(dt) --enemy.lua--

    -- CAMERA --
    local px, py = player:getPosition()
    cam:lookAt(px, love.graphics.getHeight()/2)

    -- FLAG --
    local colliders = world:queryCircleArea(flagX, flagY, 10, {'Player'})
    if #colliders > 0 then
        if saveData.currentLevel < saveData.lastLevel then
            saveData.currentLevel = saveData.currentLevel + 1
        else
            saveData.currentLevel = saveData.firstLevel
        end
        sounds.win:play()
        loadMap('level' .. saveData.currentLevel)
    end
end

function love.draw()
    -- BACKGROUND --
    love.graphics.draw(sprites.background, 0, 0)

    -- CAMERA --
    cam:attach()

        -- MAP --
        gameMap:drawLayer(gameMap.layers["Tile Layer 1"])

        -- WORLD DEBUG --
        --world:draw()

        -- PLAYER --
        drawPlayer() --player.lua--

        -- ENEMIES --
        drawEnemies() --enemy.lua--

    cam:detach()
end


----------------------------------------------

function love.keypressed(key)
    --JUMP--
    if key == 'up' then
        if player.grounded == true then
            player:applyLinearImpulse(0, -4000)
            sounds.jump:play()
        end
    end
end

--[[DESTROY PLATFORM & DANGER
function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end--]]

--LOAD MAP--
function loadMap(mapName)
    --Save data--
    love.filesystem.write('data.lua', table.show(saveData, "saveData"))
    --Destroy all objects--
    destroyAll()
    --Load Map--
    gameMap = sti("assets/maps/" .. mapName .. ".lua")
    --Reset player position--
    for i, obj in pairs(gameMap.layers["Start"].objects) do
        playerStartX = obj.x 
        playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)
    --Load Objects--
    for i, obj in pairs(gameMap.layers["Platforms"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
    for i, obj in pairs(gameMap.layers["Flag"].objects) do
        flagX = obj.x
        flagY = obj.y
    end
end

--SPAWN PLATFORMS--
function spawnPlatform(x, y, width ,height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType('static')
        table.insert(platforms, platform)
    end
end

--DESTROY PLATFORMS and ENEMIES--
function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i - 1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i - 1
    end
end