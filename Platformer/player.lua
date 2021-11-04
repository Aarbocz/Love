playerStartX = 360
playerStartY = 100

player = world:newRectangleCollider(playerStartX, playerStartY, 40, 100, {collision_class = "Player"})
player:setFixedRotation(true)
player.speed = 500
player.animation = animations.idle
player.isMoving = false
player.direction = 1
player.grounded = true

function playerUpdate(dt)
    if player.body then
        --Grounded--
        local colliders = world:queryRectangleArea(player:getX() - 15, player:getY() + 50, 30, 2, {'Platform'})
        if #colliders > 0 then
            player.grounded = true
        else
            player.grounded = false
        end
        --Position--
        local px, py = player:getPosition()
        --Movement--
        player.isMoving = false
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed * dt)
            player.isMoving = true
            player.direction = 1
        elseif love.keyboard.isDown('left') then
            player:setX(px - player.speed * dt)
            player.isMoving = true
            player.direction = -1
        end
        --Collision with Danger--
        if player:enter('Danger') then
            player:setPosition(playerStartX, playerStartY)
            sounds.die:play()
        end
        --Animation--
        if player.grounded then
            if player.isMoving == true then
                player.animation = animations.run
            else
                player.animation = animations.idle
            end
        else
            player.animation = animations.jump
        end
        player.animation:update(dt)
    end
end

function drawPlayer()
    local py, px = player:getPosition()
    player.animation:draw(sprites.playerSheet, py, px, nil, 0.25 * player.direction, 0.25, 130, 300)
end