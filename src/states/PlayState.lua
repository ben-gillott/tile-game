--[[
Comment
]]


PlayState = Class{__includes = BaseState}

-- local board
-- local player
--Check the offset of the board and if it is out of bounds
--TODO: In prog - use offsets to get death

--Coordinates that are at the center of the screen rn
-- local i = 3
-- local j = 3
-- local offsetLimit = 2
-- local offsetX = 0
-- local offsetY = 0

--TODO:
TileGap = 1
TileSize = 20
InitBoardX = 120
InitBoardY = 30

EnemySpawnDelay = 6


function PlayState:init()
    self.timer = 0
    self.spawntimer = 0
    self.i = 3
    self.j = 3
    self.board = Board(TileGap, TileSize, InitBoardX, InitBoardY)
    self.player = Player("normal", InitBoardX+3*TileGap+3.5*TileSize, InitBoardY+3*TileGap+3.5*TileSize)
    self.enemies = {}
    
    --TODO: remove, Manual danger testing
    -- self:addEnemy(5, 3, "left")
    
    -- self.board:manualDanger(1,5)
    -- self.board:manualFalling(2,5)
    self:addRandomEnemy()
end

function PlayState:render()
    self.board:render()
    self.player:render()
    for k,enemy in pairs(self.enemies) do
        enemy:render()
    end
end

function PlayState:update(dt)    
    self.board:updateTargets()
    self.board:update(dt)

    self.timer = self.timer + dt
    
    self.spawntimer = self.spawntimer + dt
    if self.spawntimer >= EnemySpawnDelay then
        self.spawntimer = 0
        self:addRandomEnemy()
    end


    --#Get keyboard movement
    if love.keyboard.wasPressed('w') then
        self:moveBoard("up")
    elseif love.keyboard.wasPressed('s') then
        self:moveBoard("down")
    elseif love.keyboard.wasPressed('a') then
        self:moveBoard("left")
    elseif love.keyboard.wasPressed('d') then
        self:moveBoard("right")
    end


    --check OOB or danger tile for character
    if self.board:isOOB() or self.board:onDanger() then --is off the board, fall off
        PlayState:gameOver()
    end

    --Tron falling tiles
    if (not self.board:onFalling()) and (not self.board:onDanger()) then
        self.board:manualFalling(self.board:getI(), self.board:getJ())
    end

    --Check for each enemy
    for k,enemy in pairs(self.enemies) do

        --Enemy died
        if enemy:getState() == "dead" then
            --Remove from db
            table.remove(self.enemies, k)
        end
        --Enemy fell
        if self.board:enemyIsOOB(enemy:getI(), enemy:getJ()) or self.board:enemyOnDanger(enemy:getI(), enemy:getJ()) then
            enemy:setState("falling")
        end
        --Enemy kills player
        if enemy:getI() == self.board:getI() and enemy:getJ() == self.board:getJ() and (enemy:getState() == "normal") then
            PlayState:gameOver()
        end
        --Update each enemy
        
        if enemy:isMoveTime() then
            enemy:autoMove(self.board:getCornerX(), self.board:getCornerY())
        end

        enemy:update(dt)
    end
end




function PlayState:gameOver()
    -- self.player:setState("dead")
    gSounds['player_death']:play()
    gStateMachine:change('score', {})
end
--===========--===========--===========

--Move the board in a direction
function PlayState:moveBoard(dir)
    gSounds['player_move']:play()
    local oppositeDir = "temp"
    if dir == "up" then
        self.board:move("up")
        --TODO apply to array of enemies
        oppositeDir = "down"
    elseif dir == "down" then
        self.board:move("down")
        oppositeDir = "up"
    elseif dir == "left" then
        self.board:move("left")
        oppositeDir = "right"
    elseif dir == "right" then
        self.board:move("right")
        oppositeDir = "left"
    end

    for k, enemy in pairs(self.enemies) do
        enemy:move(oppositeDir, self.board:getCornerX(), self.board:getCornerY())
    end
end




function PlayState:addRandomEnemy()
    --Random left right
    local ix = math.random(2)
    local dir = "left"
    local i = 5
    if ix == 2 then
        dir = "right"
        i = 1
    end
    
    local ij = math.random(5)

    self:addEnemy(i, ij ,dir)
end

function PlayState:addEnemy(i, j, direction)
    self.enemies[#self.enemies+1] = Enemy(i, j, direction, TileGap, TileSize, InitBoardX, InitBoardY)
end
