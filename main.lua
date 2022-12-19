---@diagnostic disable: lowercase-global
function love.load()
    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 0)

    camera = require 'libraries/camera'
    cam = camera()

    anim8 = require 'libraries/anim8'
    love.graphics.setDefaultFilter("nearest", "nearest")

    sti = require 'libraries/sti'
    gameMap = sti('maps/testMap.lua')

    player = {}
    player.collider = world:newBSGRectangleCollider(400, 250, 50, 100, 10)
    player.collider:setFixedRotation(true)
    player.x = 400
    player.y = 200
    player.speed = 300
    player.spriteSheet = love.graphics.newImage('sprites/player-sheet.png')
    player.grid = anim8.newGrid(12, 18, player.spriteSheet:getWidth(), player.spriteSheet:getHeight())

    player.animations = {}
    player.animations.down = anim8.newAnimation(player.grid('1-4', 1), 0.2)
    player.animations.left = anim8.newAnimation(player.grid('1-4', 2), 0.2)
    player.animations.right = anim8.newAnimation(player.grid('1-4', 3), 0.2)
    player.animations.up = anim8.newAnimation(player.grid('1-4', 4), 0.2)

    player.anim = player.animations.left

    background = love.graphics.newImage('sprites/background.png')

    walls = {}
    if gameMap.layers["paredes"] then
        for i, obj in pairs(gameMap.layers["paredes"].objects) do
            local wall = world:newRectangleCollider(obj.x, obj.y, obj.width, obj.height)
            wall:setType('static')
            table.insert(walls, wall)
        end
    end

    sounds = {}
    sounds.blip = love.audio.newSource('sounds/blip.wav', "static")
    sounds.music = love.audio.newSource('sounds/music.mp3', "stream")
    sounds.walk = love.audio.newSource('sounds/walk.mp3', "static")
    sounds.music:setLooping(true)

    sounds.music:play()

end

function love.update(dt)
    local isMoving = false

    local vx = 0
    local vy = 0

    if love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        vx = player.speed
        player.anim = player.animations.right
        isMoving = true
    end

    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        vx = player.speed * -1
        player.anim = player.animations.left
        isMoving = true
    end

    if love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        vy = player.speed
        player.anim = player.animations.down
        isMoving = true
    end

    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        vy = player.speed * -1
        player.anim = player.animations.up
        isMoving = true
    end

    player.collider:setLinearVelocity(vx, vy)

    if isMoving == false then
        player.anim:gotoFrame(2)
    end
    if isMoving then
        sounds.walk:play()
    end

    world:update(dt)
    player.x = player.collider:getX()
    player.y = player.collider:getY()

    player.anim:update(dt)

    -- Update camera position
    cam:lookAt(player.x, player.y)

    -- This section prevents the camera from viewing outside the background
    -- First, get width/height of the game window
    local w = love.graphics.getWidth()
    local h = love.graphics.getHeight()

    -- Left border
    if cam.x < w / 2 then
        cam.x = w / 2
    end

    -- Right border
    if cam.y < h / 2 then
        cam.y = h / 2
    end

    -- Get width/height of background
    local mapW = gameMap.width * gameMap.tilewidth
    local mapH = gameMap.height * gameMap.tileheight

    -- Right border
    if cam.x > (mapW - w / 2) then
        cam.x = (mapW - w / 2)
    end
    -- Bottom border
    if cam.y > (mapH - h / 2) then
        cam.y = (mapH - h / 2)
    end
end

function love.draw()
    cam:attach()
    gameMap:drawLayer(gameMap.layers["chao"])
    gameMap:drawLayer(gameMap.layers["arvoresUnicas"])
    gameMap:drawLayer(gameMap.layers["variasArvores"])
    player.anim:draw(player.spriteSheet, player.x, player.y, nil, 6, nil, 6, 9)
    --world:draw()
    cam:detach()
end

function love.keypressed(key)
    if key == "space" then
        sounds.blip:play()
    end

    if key == "m" then
        sounds.music:stop()
    end
    if key == "n" then
        sounds.music:play()
    end

end
