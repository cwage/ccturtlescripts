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
local replantSaplings = false
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

local function saveProgress()
    if not doBackup then return end
    local file = fs.open(saveFile, "w")
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

local function forward()
    print("Moving forward from " .. xPos .. "," .. zPos .. " facing " .. facing)
    while not turtle.forward() do
        if turtle.detect() then
            print("Obstacle detected, digging...")
            turtle.dig()
        else
            print("Attacking entity...")
            turtle.attack()
        end
        sleep(0.1)
    end
    
    if facing == 0 then zPos = zPos + 1
    elseif facing == 1 then xPos = xPos + 1
    elseif facing == 2 then zPos = zPos - 1
    elseif facing == 3 then xPos = xPos - 1
    end
    print("Moved to " .. xPos .. "," .. zPos)
    saveProgress()
end

local function up()
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

local function down()
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
    targetY = targetY or yPos
    
    -- Move to target Y first
    while yPos < targetY do up() end
    while yPos > targetY do down() end
    
    -- Move to target X
    if xPos < targetX then
        turnTo(1) -- Face East
        while xPos < targetX do forward() end
    elseif xPos > targetX then
        turnTo(3) -- Face West
        while xPos > targetX do forward() end
    end
    
    -- Move to target Z
    if zPos < targetZ then
        turnTo(0) -- Face North
        while zPos < targetZ do forward() end
    elseif zPos > targetZ then
        turnTo(2) -- Face South
        while zPos > targetZ do forward() end
    end
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
            if chestSide == "top" then
                turtle.dropUp()
            elseif chestSide == "bottom" then
                turtle.dropDown()
            else
                turtle.drop()
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

local function chopTree(startX, startZ)
    print("Chopping tree at " .. startX .. "," .. startZ)
    local originalY = yPos
    local woodFound = true
    local maxHeight = 0
    
    -- Chop upward following the tree
    while woodFound do
        woodFound = false
        local success, blockData = turtle.inspectUp()
        
        if success and isWood(blockData) then
            turtle.digUp()
            up()
            maxHeight = maxHeight + 1
            woodFound = true
            blocksChopped = blocksChopped + 1
            
            -- Check surrounding blocks for more wood
            for dir = 0, 3 do
                turnTo(dir)
                local success2, blockData2 = turtle.inspect()
                if success2 and isWood(blockData2) then
                    turtle.dig()
                    forward()
                    chopTree(xPos, zPos) -- Recursive call for connected wood
                    -- Return to previous position
                    turnTo((dir + 2) % 4)
                    forward()
                    turnTo(dir)
                end
            end
        end
        
        if maxHeight > 50 then break end -- Safety limit
    end
    
    -- Return to ground level
    goTo(startX, startZ, originalY)
    
    -- Plant sapling if enabled and we have one
    if replantSaplings then
        turtle.select(saplingSlot)
        if turtle.getItemCount(saplingSlot) > 0 then
            local success, blockData = turtle.inspectDown()
            if success and (blockData.name == "minecraft:dirt" or 
                           blockData.name == "minecraft:grass_block" or
                           blockData.name == "minecraft:podzol") then
                turtle.placeDown()
                print("Planted sapling")
            end
        end
    end
    
    turtle.select(1)
end

local function scanAndChop()
    -- Check current position for wood
    local success, blockData = turtle.inspect()
    if success and isWood(blockData) then
        turtle.dig()
        forward()
        chopTree(xPos, zPos)
        -- Move back
        turnTo((facing + 2) % 4)
        forward()
        turnTo((facing + 2) % 4)
        blocksChopped = blocksChopped + 1
    end
    
    -- Check above for hanging wood
    success, blockData = turtle.inspectUp()
    if success and isWood(blockData) then
        chopTree(xPos, zPos)
    end
end

local function traverseChunk(chunkX, chunkZ)
    print("Traversing chunk " .. currentChunk .. " at chunk coords " .. chunkX .. "," .. chunkZ)
    
    local startX = chunkX * 16
    local startZ = chunkZ * 16
    
    -- Traverse the 16x16 chunk in a snake pattern
    for z = 0, 15 do
        local actualZ = startZ + z
        
        if z % 2 == 0 then
            -- Left to right
            for x = 0, 15 do
                local actualX = startX + x
                goTo(actualX, actualZ)
                scanAndChop()
                
                if needsDropOff() then
                    dropItems()
                    goTo(actualX, actualZ) -- Return to position
                end
            end
        else
            -- Right to left
            for x = 15, 0, -1 do
                local actualX = startX + x
                goTo(actualX, actualZ)
                scanAndChop()
                
                if needsDropOff() then
                    dropItems()
                    goTo(actualX, actualZ) -- Return to position
                end
            end
        end
    end
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
            replantSaplings = true
            i = i + 1
        elseif args[i] == "-chest" and args[i+1] then
            chestSide = args[i+1]
            i = i + 2
        elseif args[i] == "-restore" then
            if fs.exists(saveFile) then
                dofile(saveFile)
                print("Restored from save file")
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
    print("Replant saplings: " .. tostring(replantSaplings))
    print("Chest side: " .. chestSide)
    print("")
    
    -- Check fuel before starting
    if not ensureFuel() then
        print("Aborting due to insufficient fuel!")
        return
    end
    
    print("Starting position: " .. xPos .. "," .. yPos .. "," .. zPos .. " facing " .. facing)
    
    -- Store home position
    homeX, homeY, homeZ, homeFacing = xPos, yPos, zPos, facing
    print("Home position set to: " .. homeX .. "," .. homeY .. "," .. homeZ .. " facing " .. homeFacing)
    
    -- Test movement first
    print("Testing movement...")
    print("Current fuel: " .. turtle.getFuelLevel())
    
    -- Simple test - move forward and back
    print("Moving forward 1 block...")
    forward()
    print("Moving back...")
    turnTo((facing + 2) % 4)
    forward()
    turnTo((facing + 2) % 4)
    print("Movement test complete!")
    
    -- Traverse chunks in a spiral pattern
    local chunkX, chunkZ = 0, 0
    
    for chunk = currentChunk, chunks do
        currentChunk = chunk
        print("Starting chunk " .. chunk .. " of " .. chunks)
        traverseChunk(chunkX, chunkZ)
        
        -- Move to next chunk in spiral pattern
        if chunk < chunks then
            if chunk == 1 then
                chunkX = chunkX + 1 -- Move east
            elseif chunk == 2 then
                chunkZ = chunkZ + 1 -- Move north
            elseif chunk == 3 then
                chunkX = chunkX - 1 -- Move west
                chunkZ = chunkZ + 1 -- Move north
            else
                -- Continue spiral pattern
                local layer = math.floor(math.sqrt(chunk - 1))
                -- Complex spiral math here - simplified for now
                chunkX = chunkX + 1
            end
        end
    end
    
    -- Final return home and drop off
    dropItems()
    
    print("=== Tree Chopping Complete ===")
    print("Total blocks chopped: " .. blocksChopped)
    print("Chunks traversed: " .. chunks)
    print("Final fuel level: " .. turtle.getFuelLevel())
    
    -- Clean up save file
    if fs.exists(saveFile) then
        fs.delete(saveFile)
    end
end

-- Run the program
main() 