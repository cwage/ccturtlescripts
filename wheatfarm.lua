local fullstacks = true
local bmcDirection = 4 --bone meal chest direction
local scDirection = 3 -- seed chest direction
local depositDirection = 2 -- output direction

local facing = 1
local chestslot = 14
local seedslot = 15
local bonemealslot = 16

local function TurnRight()
        facing = facing + 1
        if facing > 4 then
                facing = 1
        end
        turtle.turnRight()
end

function FindDirt()
        local facingchest = true
        turtle.select(chestslot)
        facingchest = turtle.compare()
        while facingchest do
                turtle.turnRight()
                turtle.select(chestslot)
                facingchest = turtle.compare()
        end
        facing = 1
end

function SelectEmptySlot()
        for n = 1, 13 do
                if turtle.getItemCount(n) == 0 then
                        turtle.select(n)
                        break;
                end
        end
end

function SelectSeedSlot()
        turtle.select(seedslot)
end

function CheckEmptySlots()
        local emptySlots = false
        for n = 1, 13 do
                if turtle.getItemCount(n) == 0 then
                        emptySlots = true
                        break;
                end
        end

        if not emptySlots then
                Deposit()
        end
end

function P(text)
        term.clear()
        term.setCursorPos(1, 1)
        print(text)
end


function GetMoreSeeds()
        P("Stocking seeds")
        while facing ~= scDirection do
                TurnRight()
        end
        turtle.select(seedslot)
        turtle.suck()
end

function GetMoreBM()
        P("Stocking bone meal")
        while facing ~= bmcDirection do
                TurnRight()
        end
        turtle.select(bonemealslot)
        if turtle.suck() then
                return true
        else
                return false
        end
end

function Deposit()
        P("Depositing yield")
        while facing ~= depositDirection do
                TurnRight()
        end

        for n=1,13 do
                turtle.select(seedslot)
                if not turtle.compareTo(n) then
                        turtle.select(n)
                        turtle.drop()
                end
        end

        while facing ~= scDirection do
                TurnRight()
        end

        for n=1,13 do
                turtle.select(n)
                turtle.drop()
        end
end

function CheckSupplies()
        local supplies = true
        if turtle.getItemCount(seedslot) == 0 then
                GetMoreSeeds()
        end
        if turtle.getItemCount(bonemealslot) == 0 then
                supplies = GetMoreBM()
                if not supplies then
                        waitforBM()
                end
        end
end

function waitforBM()
        P("Waiting on more bone meal")
        local continue = true

        while facing ~= bmcDirection do
                TurnRight()
        end

        while continue do
                turtle.select(bonemealslot)
                if turtle.suck() then
                        continue = false
                else
                        sleep(30)
                end
        end
end


function Farm()
        local continue = true
        while continue do
                FindDirt()
                CheckSupplies()
                P("Starting farm")
                FindDirt()
                CheckEmptySlots()
                FindDirt()
                if fullstacks then
                        SelectSeedSlot()
                else
                        SelectEmptySlot()
                end
                turtle.dig()
                turtle.dig()
                turtle.select(seedslot)
                turtle.place()
                turtle.select(bonemealslot)
                turtle.place()
        end
end

Farm()

