--[[
Tree Chopper v1.0
A turtle script to traverse N chunks and chop down all trees encountered

Usage: treechopper -chunks <N> [-replant] [-chest <side>] [-restore]

Features:
- Traverses N chunks in a systematic pattern
- Detects and chops down trees automatically
- Optional sapling replanting
- Returns to base for inventory management
- Session persistence
]]

-- Configuration defaults
local chunks = 1
local replant = false
local chestSide = "bottom"
local saveFile = "treechopper_save"
local doBackup = true
local minFuelLevel = 1000 -- Minimum fuel to start

-- Position and state tracking
local xPos, yPos, zPos = 0, 0, 0
local facing = 0 -- 0=North(+Z), 1=East(+X), 2=South(-Z), 3=West(-X)
local homeX, homeY, homeZ, homeFacing = 0, 0, 0, 0
local currentChunk = 1
local blocksChopped = 0
local saplingSlot = 16 -- Reserve slot 16 for saplings

-- Wood types to detect (CC:Tweaked block names)
local woodTypes = {
    "minecraft:oak_log",
    "minecraft:birch_log", 
    "minecraft:spruce_log",
    "minecraft:jungle_log",
    "minecraft:acacia_log",
    "minecraft:dark_oak_log",
    "minecraft:mangrove_log",
    "minecraft:cherry_log"
}

-- Sapling types corresponding to wood types
local saplingTypes = {
    "minecraft:oak_sapling",
    "minecraft:birch_sapling",
    "minecraft:spruce_sapling", 
    "minecraft:jungle_sapling",
    "minecraft:acacia_sapling",
    "minecraft:dark_oak_sapling",
    "minecraft:mangrove_propagule",
    "minecraft:cherry_sapling"
}

-- Fuel management
local function checkFuel()
    local fuel = turtle.getFuelLevel()
    if fuel == "unlimited" then
        return true
    end
    return fuel >= minFuelLevel
end

local function refuelFromInventory()
    local originalSlot = turtle.getSelectedSlot()
    for slot = 1, 16 do
        turtle.select(slot)
        if turtle.refuel(0) then -- Check if item can be used as fuel
            local count = turtle.getItemCount(slot)
            if count > 0 then
                print("Refueling with " .. count .. " items from slot " .. slot)
                turtle.refuel(count)
                break
            end
        end
    end
    turtle.select(originalSlot)
end

local function ensureFuel()
    if turtle.getFuelLevel() == "unlimited" then
        return true
    end
    
    local fuel = turtle.getFuelLevel()
    print("Current fuel level: " .. fuel)
    
    if fuel < minFuelLevel then
        print("Low fuel! Attempting to refuel from inventory...")
        refuelFromInventory()
        fuel = turtle.getFuelLevel()
        
        if fuel < minFuelLevel then
            print("ERROR: Not enough fuel! Need at least " .. minFuelLevel)
            print("Current fuel: " .. fuel)
            print("Please add fuel items to inventory and restart.")
            return false
        end
    end
    
    print("Fuel OK: " .. fuel .. " units")
    return true
end

-- Utility functions
local function isWood(blockData)
    if not blockData then return false end
    for _, woodType in ipairs(woodTypes) do
        if blockData.name == woodType then
            return true
        end
    end
    return false
end

local function isSapling(itemName)
    for _, saplingType in ipairs(saplingTypes) do
        if itemName == saplingType then
            return true
        end
    end
    return false
end

local function isLeaves(blockData)
    if not blockData then return false end
    local leafTypes = {
        "minecraft:oak_leaves",
        "minecraft:birch_leaves",
        "minecraft:spruce_leaves",
        "minecraft:jungle_leaves",
        "minecraft:acacia_leaves",
        "minecraft:dark_oak_leaves",
        "minecraft:mangrove_leaves",
        "minecraft:cherry_leaves"
    }
    for _, leafType in ipairs(leafTypes) do
        if blockData.name == leafType then
            return true
        end
    end
    return false
end

local function saveProgress()
    if not doBackup then return end
    local file = fs.open(saveFile, "w")
    if not file then
        print("Warning: Could not save progress to file")
        return
    end
    file.write("xPos = " .. xPos .. "\n")
    file.write("yPos = " .. yPos .. "\n") 
    file.write("zPos = " .. zPos .. "\n")
    file.write("facing = " .. facing .. "\n")
    file.write("currentChunk = " .. currentChunk .. "\n")
    file.write("blocksChopped = " .. blocksChopped .. "\n")
    file.close()
end

local function turnRight()
    turtle.turnRight()
    facing = (facing + 1) % 4
    saveProgress()
end

local function turnLeft()
    turtle.turnLeft()
    facing = (facing - 1) % 4
    saveProgress()
end

local function turnTo(targetFacing)
    while facing ~= targetFacing do
        if (targetFacing - facing) % 4 == 1 then
            turnRight()
        else
            turnLeft()
        end
    end
end

-- Terrain-aware movement functions
local function isGround(blockData)
    if not blockData then return false end
    local groundBlocks = {
        "minecraft:dirt", "minecraft:grass_block", "minecraft:stone", 
        "minecraft:cobblestone", "minecraft:sand", "minecraft:gravel",
        "minecraft:podzol", "minecraft:coarse_dirt", "minecraft:mycelium",
        "minecraft:snow_block", "minecraft:clay", "minecraft:terracotta"
    }
    for _, groundType in ipairs(groundBlocks) do
        if blockData.name == groundType then
            return true
        end
    end
    return false
end

local function findGroundLevel()
    -- Look down to find ground level, but don't be too aggressive
    local groundY = yPos
    local maxDown = 2 -- Further reduced - only go down 2 blocks max
    
    -- First check if we're already at a good level
    local success, blockData = turtle.inspectDown()
    if success and isGround(blockData) then
        -- We're already at ground level
        return groundY
    end
    
    -- Only go down if there's air below us, and be very conservative
    for i = 1, maxDown do
        local success, blockData = turtle.inspectDown()
        if success then
            -- There's a block below, stop here
            break
        else
            -- Air below, go down to check
            if turtle.down() then
                yPos = yPos - 1
                groundY = yPos
                saveProgress()
                
                -- Check if we found ground now
                local newSuccess, newBlockData = turtle.inspectDown()
                if newSuccess and isGround(newBlockData) then
                    print("Found ground at level " .. groundY)
                    return groundY
                elseif not newSuccess then
                    -- Still air below after going down - this is likely a cave/hole
                    print("Detected cave/hole, climbing back up to avoid going too deep")
                    turtle.up()
                    yPos = yPos + 1
                    saveProgress()
                    return yPos
                end
            else
                break
            end
        end
    end
    
    return groundY
end

local function smartForward()
    print("Smart moving forward from " .. xPos .. "," .. zPos .. " facing " .. facing)
    
    -- First, try normal forward movement
    if turtle.forward() then
        -- Update position
        if facing == 0 then zPos = zPos + 1
        elseif facing == 1 then xPos = xPos + 1
        elseif facing == 2 then zPos = zPos - 1
        elseif facing == 3 then xPos = xPos - 1
        end
        print("Moved to " .. xPos .. "," .. zPos)
        saveProgress()
        
        -- Check if we need to adjust height for terrain following
        local success, blockData = turtle.inspectDown()
        if not success then
            -- Air below - we might have walked off a cliff or into a hole
            print("Air detected below, checking for safe ground level...")
            
            -- Try going down one block to see if there's ground
            if turtle.down() then
                yPos = yPos - 1
                saveProgress()
                
                local newSuccess, newBlockData = turtle.inspectDown()
                if newSuccess and isGround(newBlockData) then
                    -- Found ground one block down, this is fine
                    print("Found ground one level down")
                    return true
                else
                    -- Still air below or non-ground block - this might be a cave/hole
                    print("Detected deep hole or cave, returning to surface level")
                    turtle.up()
                    yPos = yPos + 1
                    saveProgress()
                    return true
                end
            end
        end
        
        return true
    end
    
    -- Can't move forward, check what's blocking
    local success, blockData = turtle.inspect()
    if success then
        if isWood(blockData) then
            print("Wood block ahead - will be handled by tree chopping")
            turtle.dig()
        elseif isGround(blockData) then
            print("Ground/hill ahead - attempting to climb")
            -- Try to climb over the obstacle
            if turtle.up() then
                yPos = yPos + 1
                saveProgress()
                if turtle.forward() then
                    -- Successfully climbed over
                    if facing == 0 then zPos = zPos + 1
                    elseif facing == 1 then xPos = xPos + 1
                    elseif facing == 2 then zPos = zPos - 1
                    elseif facing == 3 then xPos = xPos - 1
                    end
                    print("Climbed over obstacle to " .. xPos .. "," .. zPos)
                    saveProgress()
                    return true
                else
                    -- Still can't move, go back down and dig
                    turtle.down()
                    yPos = yPos - 1
                    turtle.dig()
                end
            else
                -- Can't go up, just dig through
                turtle.dig()
            end
        elseif isLeaves(blockData) then
            print("Leaves ahead - trying to move through")
            turtle.dig() -- Leaves do block movement, so we need to dig them
        else
            print("Unknown obstacle ahead (" .. (blockData.name or "unknown") .. ") - digging...")
            turtle.dig()
        end
        
        -- Try moving again after clearing obstacle
        if turtle.forward() then
            if facing == 0 then zPos = zPos + 1
            elseif facing == 1 then xPos = xPos + 1
            elseif facing == 2 then zPos = zPos - 1
            elseif facing == 3 then xPos = xPos - 1
            end
            print("Moved to " .. xPos .. "," .. zPos .. " after clearing obstacle")
            saveProgress()
            return true
        end
    else
        -- No block detected but can't move - probably an entity
        print("Entity blocking path, attacking...")
        turtle.attack()
        sleep(0.1)
        return smartForward() -- Retry
    end
    
    return false
end

local function smartUp()
    print("Moving up from y=" .. yPos)
    while not turtle.up() do
        if turtle.detectUp() then
            print("Obstacle above, digging...")
            turtle.digUp()
        else
            print("Attacking entity above...")
            turtle.attackUp()
        end
        sleep(0.1)
    end
    yPos = yPos + 1
    print("Moved to y=" .. yPos)
    saveProgress()
end

local function smartDown()
    print("Moving down from y=" .. yPos)
    while not turtle.down() do
        if turtle.detectDown() then
            print("Obstacle below, digging...")
            turtle.digDown()
        else
            print("Attacking entity below...")
            turtle.attackDown()
        end
        sleep(0.1)
    end
    yPos = yPos - 1
    print("Moved to y=" .. yPos)
    saveProgress()
end

local function goTo(targetX, targetZ, targetY)
    print("Going to " .. targetX .. "," .. targetZ .. "," .. (targetY or "ground level"))
    
    -- If no target Y specified, we'll follow terrain
    local followTerrain = (targetY == nil)
    
    -- Move to target X
    while xPos ~= targetX do
        if xPos < targetX then
            turnTo(1) -- Face East
        else
            turnTo(3) -- Face West
        end
        smartForward()
        
        -- Check fuel periodically during long moves
        if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < 100 then
            print("Low fuel during movement, attempting to refuel...")
            refuelFromInventory()
        end
    end
    
    -- Move to target Z
    while zPos ~= targetZ do
        if zPos < targetZ then
            turnTo(0) -- Face North
        else
            turnTo(2) -- Face South
        end
        smartForward()
        
        -- Check fuel periodically during long moves
        if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < 100 then
            print("Low fuel during movement, attempting to refuel...")
            refuelFromInventory()
        end
    end
    
    -- Move to target Y if specified, otherwise stay at ground level
    if not followTerrain and targetY then
        while yPos < targetY do smartUp() end
        while yPos > targetY do smartDown() end
    else
        -- Make sure we're at ground level
        findGroundLevel()
    end
    
    print("Arrived at " .. xPos .. "," .. yPos .. "," .. zPos)
end

local function returnHome()
    print("Returning to base...")
    goTo(homeX, homeZ, homeY)
    turnTo(homeFacing)
end

local function dropItems()
    print("Dropping off items...")
    returnHome()
    
    -- Drop everything except saplings
    for slot = 1, 15 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and not isSapling(item.name) then
            local success = false
            if chestSide == "top" then
                success = turtle.dropUp()
            elseif chestSide == "bottom" then
                success = turtle.dropDown()
            elseif chestSide == "front" then
                success = turtle.drop()
            elseif chestSide == "left" then
                turnTo((homeFacing + 3) % 4) -- Turn left
                success = turtle.drop()
                turnTo(homeFacing) -- Turn back
            elseif chestSide == "right" then
                turnTo((homeFacing + 1) % 4) -- Turn right
                success = turtle.drop()
                turnTo(homeFacing) -- Turn back
            end
            
            if not success then
                print("Warning: Could not drop items from slot " .. slot)
            end
        end
    end
    
    -- Consolidate saplings to slot 16
    turtle.select(saplingSlot)
    for slot = 1, 15 do
        turtle.select(slot)
        local item = turtle.getItemDetail()
        if item and isSapling(item.name) then
            turtle.transferTo(saplingSlot)
        end
    end
    
    turtle.select(1)
end

local function needsDropOff()
    local freeSlots = 0
    for slot = 1, 15 do -- Don't count sapling slot
        if turtle.getItemCount(slot) == 0 then
            freeSlots = freeSlots + 1
        end
    end
    return freeSlots < 3 -- Drop off when less than 3 free slots
end

local function chopTree(treeInfo)
    print("Chopping tree at " .. treeInfo.x .. "," .. treeInfo.y .. "," .. treeInfo.z)
    
    -- Store our current position before tree chopping
    local originalX, originalY, originalZ = xPos, yPos, zPos
    local originalFacing = facing
    
    -- Face the tree direction
    turnTo(treeInfo.direction)
    
    -- Verify there's still wood in front of us
    local success, blockData = turtle.inspect()
    if success and isWood(blockData) then
        print("Confirmed wood block ahead, starting to chop...")
        
        -- Dig the base block
        turtle.dig()
        blocksChopped = blocksChopped + 1
        
        -- Move into the tree position to chop upward
        turtle.forward()
        if treeInfo.direction == 0 then zPos = zPos + 1
        elseif treeInfo.direction == 1 then xPos = xPos + 1
        elseif treeInfo.direction == 2 then zPos = zPos - 1
        elseif treeInfo.direction == 3 then xPos = xPos - 1
        end
        saveProgress()
        
        local treeBase = yPos
        
        -- Check if we need to go down to find the real base
        while true do
            local downSuccess, downData = turtle.inspectDown()
            if downSuccess and isWood(downData) then
                turtle.digDown()
                blocksChopped = blocksChopped + 1
                smartDown()
                treeBase = yPos
            else
                break
            end
        end
        
        -- Now chop upward
        local woodChopped = 1 -- Already chopped the base
        local maxHeight = 30
        
        print("Starting upward chop from base level " .. treeBase)
        for height = 0, maxHeight do
            local upSuccess, upData = turtle.inspectUp()
            if upSuccess and isWood(upData) then
                print("Found wood above at height " .. (height + 1) .. ", chopping...")
                turtle.digUp()
                woodChopped = woodChopped + 1
                blocksChopped = blocksChopped + 1
                
                -- Simple up movement - absolutely no other function calls
                turtle.up()
                yPos = yPos + 1
                -- Don't save progress during tree chopping to avoid any side effects
                
            else
                if upSuccess then
                    print("Non-wood block above: " .. (upData.name or "unknown"))
                else
                    print("No block above, reached top of tree")
                end
                break
            end
        end
        print("Finished chopping upward, total wood: " .. woodChopped)
        
        -- Save progress only once after tree chopping is complete
        saveProgress()
        
        -- Return to the exact original position using simple movement
        print("Returning to original position: " .. originalX .. "," .. originalY .. "," .. originalZ)
        print("Current position before return: " .. xPos .. "," .. yPos .. "," .. zPos)
        
        -- Simple return movement - don't use goTo() which calls smartForward()
        -- Move to target Y first
        while yPos > originalY do
            turtle.down()
            yPos = yPos - 1
        end
        while yPos < originalY do
            turtle.up()
            yPos = yPos + 1
        end
        
        -- Move to target X
        while xPos ~= originalX do
            if xPos < originalX then
                turnTo(1) -- Face East
            else
                turnTo(3) -- Face West
            end
            -- Simple forward movement without obstacle detection
            if turtle.forward() then
                if facing == 0 then zPos = zPos + 1
                elseif facing == 1 then xPos = xPos + 1
                elseif facing == 2 then zPos = zPos - 1
                elseif facing == 3 then xPos = xPos - 1
                end
            else
                -- Only dig if we absolutely can't move
                turtle.dig()
                turtle.forward()
                if facing == 0 then zPos = zPos + 1
                elseif facing == 1 then xPos = xPos + 1
                elseif facing == 2 then zPos = zPos - 1
                elseif facing == 3 then xPos = xPos - 1
                end
            end
        end
        
        -- Move to target Z
        while zPos ~= originalZ do
            if zPos < originalZ then
                turnTo(0) -- Face North
            else
                turnTo(2) -- Face South
            end
            -- Simple forward movement without obstacle detection
            if turtle.forward() then
                if facing == 0 then zPos = zPos + 1
                elseif facing == 1 then xPos = xPos + 1
                elseif facing == 2 then zPos = zPos - 1
                elseif facing == 3 then xPos = xPos - 1
                end
            else
                -- Only dig if we absolutely can't move
                turtle.dig()
                turtle.forward()
                if facing == 0 then zPos = zPos + 1
                elseif facing == 1 then xPos = xPos + 1
                elseif facing == 2 then zPos = zPos - 1
                elseif facing == 3 then xPos = xPos - 1
                end
            end
        end
        
        turnTo(originalFacing)
        saveProgress()
        print("Successfully returned to original position and facing")
        
        -- Plant sapling if replanting is enabled
        if replant then
            turtle.select(saplingSlot)
            if turtle.getItemCount(saplingSlot) > 0 then
                turnTo(treeInfo.direction)
                turtle.place()
                print("Planted sapling")
                turnTo(originalFacing) -- Return to original facing
            else
                print("No saplings available for replanting")
            end
        end
        
        print("Chopped " .. woodChopped .. " wood blocks")
        return woodChopped
    else
        print("No wood found at expected location - tree may have been removed")
        return 0
    end
end

local function quickScanForWood()
    -- Quick scan in current direction only - no turning
    local success, blockData = turtle.inspect()
    return success and isWood(blockData)
end

local function fullScanForTrees()
    -- Full 360 scan only when we know there's wood nearby
    local treesFound = {}
    local originalFacing = facing
    
    print("Doing full tree scan...")
    
    -- Check in all 4 directions
    for dir = 0, 3 do
        turnTo(dir)
        local success, blockData = turtle.inspect()
        
        if success and isWood(blockData) then
            local treeX, treeZ = xPos, zPos
            if dir == 0 then treeZ = treeZ + 1
            elseif dir == 1 then treeX = treeX + 1
            elseif dir == 2 then treeZ = treeZ - 1
            elseif dir == 3 then treeX = treeX - 1
            end
            
            -- Check if we already found this tree
            local alreadyFound = false
            for _, existingTree in ipairs(treesFound) do
                if existingTree.x == treeX and existingTree.z == treeZ then
                    alreadyFound = true
                    break
                end
            end
            
            if not alreadyFound then
                table.insert(treesFound, {x = treeX, z = treeZ, y = yPos, direction = dir})
                print("Found tree at " .. treeX .. "," .. yPos .. "," .. treeZ)
            end
        end
    end
    
    -- Return to original facing
    turnTo(originalFacing)
    return treesFound
end

local function processPosition(x, z)
    print("Processing position " .. x .. "," .. z)
    
    -- Move to the position
    goTo(x, z)
    
    -- Quick check first - no turning required
    if quickScanForWood() then
        print("Wood detected, doing full scan...")
        local trees = fullScanForTrees()
        
        -- Chop any trees found
        for _, tree in ipairs(trees) do
            if needsDropOff() then
                dropItems()
                goTo(x, z) -- Return to current position
            end
            
            chopTree(tree)
        end
    else
        -- No wood detected in current direction, skip full scan
        print("No wood detected, skipping scan")
    end
    
    -- Check if we need to drop off items
    if needsDropOff() then
        dropItems()
    end
end

local function getChunkCoords(chunkNumber)
    -- Convert chunk number to spiral coordinates
    if chunkNumber == 1 then
        return 0, 0
    end
    
    -- Simple linear pattern for now - can be made spiral later
    local chunkX = (chunkNumber - 1) % 4
    local chunkZ = math.floor((chunkNumber - 1) / 4)
    return chunkX, chunkZ
end

local function traverseChunk(chunkNumber)
    local chunkX, chunkZ = getChunkCoords(chunkNumber)
    print("Traversing chunk " .. chunkNumber .. " at chunk coords " .. chunkX .. "," .. chunkZ)
    
    local startX = chunkX * 16
    local startZ = chunkZ * 16
    
    -- Traverse the 16x16 chunk in a snake pattern
    for z = 0, 15 do
        local actualZ = startZ + z
        
        if z % 2 == 0 then
            -- Left to right
            for x = 0, 15 do
                local actualX = startX + x
                processPosition(actualX, actualZ)
                
                if needsDropOff() then
                    dropItems()
                    processPosition(actualX, actualZ) -- Return to position
                end
            end
        else
            -- Right to left
            for x = 15, 0, -1 do
                local actualX = startX + x
                processPosition(actualX, actualZ)
                
                if needsDropOff() then
                    dropItems()
                    processPosition(actualX, actualZ) -- Return to position
                end
            end
        end
    end
end

local function loadProgress()
    if not fs.exists(saveFile) then
        return false
    end
    
    local file = fs.open(saveFile, "r")
    if not file then
        return false
    end
    
    local content = file.readAll()
    file.close()
    
    -- Parse the saved values
    for line in content:gmatch("[^\r\n]+") do
        local var, value = line:match("(%w+) = (%d+)")
        if var and value then
            if var == "xPos" then xPos = tonumber(value)
            elseif var == "yPos" then yPos = tonumber(value)
            elseif var == "zPos" then zPos = tonumber(value)
            elseif var == "facing" then facing = tonumber(value)
            elseif var == "currentChunk" then currentChunk = tonumber(value)
            elseif var == "blocksChopped" then blocksChopped = tonumber(value)
            end
        end
    end
    
    return true
end

-- Argument parsing
local args = {...}
local function parseArgs()
    local i = 1
    while i <= #args do
        if args[i] == "-chunks" and args[i+1] then
            chunks = tonumber(args[i+1]) or 1
            i = i + 2
        elseif args[i] == "-replant" then
            replant = true
            i = i + 1
        elseif args[i] == "-chest" and args[i+1] then
            local validSides = {top = true, bottom = true, front = true, left = true, right = true}
            if validSides[args[i+1]] then
                chestSide = args[i+1]
            else
                print("ERROR: Invalid chest side '" .. args[i+1] .. "'. Valid options: top, bottom, front, left, right")
                return false
            end
            i = i + 2
        elseif args[i] == "-restore" then
            if fs.exists(saveFile) then
                if loadProgress() then
                    print("Restored from save file")
                else
                    print("Failed to restore from save file")
                end
            else
                print("No save file found to restore from")
            end
            i = i + 1
        elseif args[i] == "-help" then
            print("Tree Chopper Usage:")
            print("treechopper -chunks <N> [-replant] [-chest <side>] [-restore]")
            print("")
            print("-chunks <N>: Number of chunks to traverse")
            print("-replant: Automatically replant saplings")
            print("-chest <side>: Chest location (top/bottom/front)")
            print("-restore: Restore from previous session")
            return false
        else
            i = i + 1
        end
    end
    return true
end

-- Main execution
local function main()
    if not turtle then
        print("This script requires a turtle!")
        return
    end
    
    if not parseArgs() then return end
    
    print("=== Tree Chopper v1.0 ===")
    print("Chunks to traverse: " .. chunks)
    print("Replant saplings: " .. tostring(replant))
    print("Chest side: " .. chestSide)
    print("")
    
    -- Check fuel
    if not checkFuel() then
        print("ERROR: Insufficient fuel!")
        return
    end
    
    -- Initialize position and establish ground level
    if not loadProgress() then
        print("Starting new session...")
        homeX, homeY, homeZ = 0, 0, 0
        xPos, yPos, zPos = 0, 0, 0
        facing = 0
        currentChunk = 1
        homeFacing = 0
        
        -- Find and establish ground level
        print("Establishing ground level...")
        findGroundLevel()
        
        -- Update home position to ground level
        homeY = yPos
        
        saveProgress()
    else
        print("Resuming from saved position: " .. xPos .. "," .. yPos .. "," .. zPos)
        print("Current chunk: " .. currentChunk .. "/" .. chunks)
        
        -- Re-establish ground level at current position
        findGroundLevel()
    end
    
    print("Home position: " .. homeX .. "," .. homeY .. "," .. homeZ)
    print("Current position: " .. xPos .. "," .. yPos .. "," .. zPos)
    print("Fuel level: " .. turtle.getFuelLevel())
    print("")
    
    -- Test movement
    print("Testing movement...")
    local testSuccess = smartForward()
    if testSuccess then
        print("Movement test successful")
        -- Move back to start
        turnTo((facing + 2) % 4)
        smartForward()
        turnTo((facing + 2) % 4)
    else
        print("ERROR: Movement test failed!")
        return
    end
    
    -- Process each chunk
    while currentChunk <= chunks do
        print("=== Processing Chunk " .. currentChunk .. "/" .. chunks .. " ===")
        traverseChunk(currentChunk)
        currentChunk = currentChunk + 1
        saveProgress()
        
        -- Check fuel between chunks
        if turtle.getFuelLevel() ~= "unlimited" and turtle.getFuelLevel() < 500 then
            print("Low fuel, attempting to refuel...")
            refuelFromInventory()
        end
    end
    
    -- Final return home and cleanup
    print("=== Job Complete ===")
    dropItems()
    returnHome()
    
    print("Tree chopping complete!")
    print("Total blocks chopped: " .. blocksChopped)
    
    -- Clean up save file
    if fs.exists(saveFile) then
        fs.delete(saveFile)
        print("Save file cleaned up")
    end
end

-- Run the program
main() 