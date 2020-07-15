
Board = Class{}

local map = {}

-- local tile_gap = 5 >
-- local tile_size = 20 >

-- local board_w = 5
-- local board_h = 5


function Board:init(tile_gapIn, tile_sizeIn, cx, cy)
    --TODO: Update values from params
    self.tile_gap = tile_gapIn
    self.tile_size = tile_sizeIn
    self.corner_x = cx
    self.corner_y = cy

    for i=1,5 do
        map[i] = {}
        for j=1,5 do
            map[i][j] = Tile(self.tile_size, "safe", self.corner_x + (self.tile_gap+self.tile_size)*i, self.corner_y + (self.tile_gap+self.tile_size)*j)
        end
    end
end

function Board:update(dt)
    for i=1,5 do
        for j=1,5 do
            -- print(self.tile_gap)
            map[i][j]:update(dt)
        end
    end
end

function Board:addDanger(dangerLevel)
    for i=1,5 do
        for j=1,5 do
            -- print(self.tile_gap)
            if (math.random()*(100/dangerLevel)) <= 1 then
                map[i][j]:setState("danger")
            end
        end
    end
end

function Board:move(dir)
    local shiftDist = self.tile_gap + self.tile_size

    if dir == "up" then
        self.corner_y = self.corner_y - shiftDist
    elseif dir == "down" then
        self.corner_y = self.corner_y + shiftDist
    elseif dir == "left" then
        self.corner_x = self.corner_x - shiftDist
    elseif dir == "right" then
        self.corner_x = self.corner_x + shiftDist
    end
end

function Board:setCorner(cx, cy)
    self.corner_y = cx
    self.corner_x = cy
end

function Board:updateTargets()
    for i=1,5 do
        for j=1,5 do
            -- print(self.tile_gap)
            map[i][j]:setTarget(self.corner_x + (self.tile_gap+self.tile_size)*i, self.corner_y + (self.tile_gap+self.tile_size)*j)
        end
    end
end

function Board:render()
    for i=1,5 do
        for j=1,5 do
            map[i][j]:render()
        end
    end
end