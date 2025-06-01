--[[
Version 3.1.1
Recent Changes:
1. Now has session persistence! Just type "quarry -restore"
   and your turtle will pick up where it left off
2. New Argument: startY to help stop it from getting stuck on those nasty sheep!
3. Most directional functions take care of invert. Exception is turtle.detect
]]
--[[ToDo:
1. Actually get the rednet send back and forth to work
3. Send basic commands from receiver program e.g. Stop
6. Add in rednet stuff
7. Massive update for rednet program
]]
--Defining things
_G.civilTable = {}; civilTable = nil; setmetatable(civilTable, {__index = _G}); setfenv(1,civilTable)
-------Defaults for Arguments----------
--Arguments assignable by text
x,y,z = 3,3,3 --These are just in case tonumber fails
inverted = false --False goes from top down, true goes from bottom up [Default false] 
rednetEnabled = false --Default rednet on or off  [Default false]
--Arguments assignable by tArgs
dropSide = "front" --Side it will eject to when full or done [Default "front"]
careAboutResources = true --Will not stop mining once inventory full if false [Default true]
doCheckFuel = true --Perform fuel check [Default true]
doRefuel = true --Whenever it comes to start location will attempt to refuel from inventory [Default false]
invCheckFreq = 10 --Will check for inventory full every <-- moved spaces [Default 10]
keepOpen = 1 --How many inventory slots it will attempt to keep open at all times [Default 1]
fuelSafety = "safe" --How much fuel it will ask for: safe, moderate, and loose [Default moderate]
saveFile = "Civil_Quarry_Restore" --Where it saves restore data [Default "Civil_Quarry_Restore"]
doBackup = true --If it will keep backups for session persistence [Default true]
--Standard number slots for fuel (you shouldn't care)
fuelTable = { --Will add in this amount of fuel to requirement.
safe = 1000,
moderate = 200,
loose = 0 } --Default 1000, 200, 0
--Standard rednet channels
channels = {
send = os.getComputerID()  ,
receive = os.getComputerID() + 100 ,
confirm = "Confirm"
}

local help_paragraph = [[
-DEFAULT: This will ignore all arguments and prompts and use defaults
-vanilla: This will ignore all arguments except for dimensions
-dim: [num] [num] [num] This sets the dimensions of the quarry
-invert: [t/f] This sets whether invert is true or false
-rednet: [t/f] This sets whether it will attempt to make a rednet connection
-sendChannel: [num] This sets the channel the turtle will attempt to send on
-receiveChannel: [num] This sets the channel the turtle will attempt to receive on
-doRefuel: Changes whether or not the turtle will refuel itself with coal when fuel is low (opposite of written config)
-doCheckFuel: Changes whether or not the turtle will check its fuel level before running (opposite of written config)
-chest: [chest side] Changes what side turtle will output to
-startY: [num] Tells the turtle what y coordinate it starts at, to make bedrock checking more accurate (hopefully)
-keepOpen: [num] How many slots of the inventory turtle will try to keep open (Will then auto-empty)
-invCheckFreq: [num] How many blocks before full inventory checks
-saveFile: [word] Changes where the turtle saves its backup to.
-doBackup: [t/f] Whether or not the turtle will backup its current position to a file.
-restore: Turtle will check for a save file. If found will ignore all other arguments.
-fuelSafety: [safe/moderate/loose] How much extra fuel the turtle will request at startup
Examples [1]:
 The minimum amount necessary to start a turtle automatically would be one of these two
 ---------
 quarry -dim 3 3 3 -invert false -rednet false
 ---------
 quarry -dim 3 3 3 -vanilla
 ---------
 or, if you actually wanted a 3x3x3 then
 ---------
 quarry -DEFAULT
Examples [2]: 
 If you wanted start a quarry that has 
 rednet on channels 500 and 501, outputs 
 to a chest below itself, is inverted,
 and has the dimensions 5x5x21, then here
 is what you would type: (Remember that
 order does not matter)
 ----------
 quarry -receiveChannel 501 -sendChannel 500 -invert true -dim 5 5 21 -chest bottom -rednet true
Examples [2] (cont.):
 Now, this may be very long, but it is meant for people who want to make automated quarries with
 the same settings every time (or with variable setting)
Examples [3]:
 If you are playing softcore then you
 can do
 ---------
 quarry -doCheckFuel false
 ---------
 Followed by any other arguments
Tips:
 You don't actually have to type out "false" or "true" if you don't want. It actually just checks if the first
 letter is "t", so you (usually) don't have to put anything at all. Putting the whole word just helps with clarity
Internal Config: 
 At the top of the program, right below the changelog is a written config. Anything not specified by arguments
 will be taken from here. If you have a quarry setup you use a lot, you could just edit the config and then
 type in the following:
 ----------
 quarry -DEFAULT
]]

--Parsing help for display
--[[The way the help table works:
All help indexes are numbered. There is a help[i].title that contains the title,
and the other lines are in help[i][1] - help[i][#help[i] ]
Different lines (e.g. other than first) start with a space.
As of now, the words are not wrapped, fix that later]]
local help = {}
local i = 0
local titlePattern = ".-%:" --Find the beginning of the line, then characters, then a ":"
local textPattern = "%:.+" --Find a ":", then characters until the end of the line
for a in help_paragraph:gmatch("\n?.-\n") do --Matches in between newlines
local current = string.sub(a,1,-2).."" --Concatenate Trick
if string.sub(current,1,1) ~= " " then
i = i + 1
help[i] = {}
help[i].title = string.sub(string.match(current, titlePattern),1,-2)..""
help[i][1] = string.sub(string.match(current,textPattern) or " ",3,-1)
elseif string.sub(current,1,1) == " " then
table.insert(help[i], string.sub(current,2, -1).."")
end
end


local supportsRednet = (peripheral.wrap("right") ~= nil)

local tArgs = {...}
--You don't care about these
      xPos,yPos,zPos,facing,percent,mined,moved,relxPos, rowCheck, connected, isInPath, layersDone, attacked, endRow, startY
    = 0,   1,   1,   0,     0,      0,    0,    1,       "right",  false,     true,     1,          0,        0,      0

local totals = {cobble = 0, fuel = 0, other = 0} -- Total for display (cannot go inside function)
local function count() --Done any time inventory dropped and at end
slot = {}        --1: Cobble 2: Fuel 3:Other
for i=1, 16 do   --[1] is type, [2] is number
slot[i] = {}
slot[i][2] = turtle.getItemCount(i)
end
slot[1][1] = 1   -- = Assumes Cobble/Main
for i=1, 16 do   --Cobble Check
turtle.select(i)
if turtle.compareTo(1)  then
slot[i][1] = 1
totals.cobble = totals.cobble + slot[i][2]
elseif turtle.refuel(0) then
slot[i][1] = 2
totals.fuel = totals.fuel + slot[i][2]
else
slot[i][1] = 3
totals.other = totals.other + slot[i][2]
end
end
turtle.select(1)
end
local function checkFuel()
return turtle.getFuelLevel()
end

 -----------------------------------------------------------------
--Input Phase
local function screen(xPos,yPos)
xPos, yPos = xPos or 1, yPos or 1
term.setCursorPos(xPos,yPos); term.clear(); end
local function screenLine(xPos,yPos)
term.setCursorPos(xPos,yPos); term.clearLine(); end

screen(1,1)
print("----- Welcome to Quarry! -----")
print("")

local sides = {top = "top", right = "right", left = "left", bottom = "bottom", front = "front"} --Used to whitelist sides
local errorT = {num = "Numbers not recognized", zero = "Variable is out of range", word = "String failed assertion" }
local changedT = {}
changedT.new = function(key, value) changedT[#changedT+1] = {[key] = value} end
changedT.getPair = function(i) for a, b in pairs(changedT[i]) do return a, b end end
local function capitalize(text) return (string.upper(string.sub(text,1,1))..string.sub(text,2,-1)) end
local function assert(condition, message, section) section = section or "[Blank]"; if condition then return condition else error("Error: "..message.."\nin section "..section, 0) end end
local function checkNum(number, section) return assert(tonumber(number),errorT.num, section) end
tArgs.checkStart = function(num) tArgs[tArgs[num]] = num end
for i=1, #tArgs do tArgs.checkStart(i) end

--Check if it is a turtle
if not turtle then
  print("This is not a turtle, you must be looking for the \"Companion Rednet Program\" \nCheck My forum thread for that")
  print("Press 'q' to quit, or any other key to start help ")
  local _, key = os.pullEvent("char")
  if key ~= "q" then tArgs.help = true else error("",0) end
end


if tArgs["help"] or tArgs["-help"] or tArgs["-?"] then
print("You have selected help, press any key to continue"); print("Use arrow keys to naviate, q to quit"); os.pullEvent("key")
local pos = 1
local key = 0
while pos <= #help and key ~= keys.q do
if pos < 1 then pos = 1 end
screen(1,1) 
print(help[pos].title)
for a=1, #help[pos] do print(help[pos][a]) end
repeat
_, key = os.pullEvent("key")
until key == 200 or key == 208 or key == keys.q
if key == 200 then pos = pos - 1 end
if key == 208 then pos = pos + 1 end
end
error("",0)
end


--Saving
if tArgs["doBackup"] then doBackup = (string.lower(string.sub(tArgs[tArgs["doBackup"]+1],1,1)) ~= "f") end
if tArgs["saveFile"] then saveFile = tArgs[tArgs["saveFile"]+1] or saveFile end

local restoreFound = false
if tArgs["-restore"] then
restoreFound = fs.exists(saveFile)
if restoreFound then
os.run(getfenv(1),saveFile)
print("Restore File read successfully. Starting in 3"); sleep(3)
end
end

if not (tArgs["-DEFAULT"] or restoreFound) then
local section = "Dimensions"
--Dimensions
if tArgs["-dim"] then local num = tArgs["-dim"];
x = checkNum(tArgs[num + 1],section); z = checkNum(tArgs[num + 2],section); y = checkNum(tArgs[num + 3],section)
else
print("What dimensions?")
print("")
--This will protect from negatives, letters, and decimals
term.write("Length: ")
x = math.floor(math.abs(tonumber(io.read()) or x))
term.write("Width: ")
z = math.floor(math.abs(tonumber(io.read()) or z))
term.write("Height: ")
y = math.floor(math.abs(tonumber(io.read()) or y))
end
changedT.new("x",x); changedT.new("z",z); changedT.new("y",y)
assert(x~=0, errorT.zero, section); assert(z~=0, errorT.zero, section); assert(y~=0, errorT.zero, section)
assert(not(x == 1 and y == 1 and z == 1) ,"1, 1, 1 doesn't work well at all, try again", section)
if not tArgs["-vanilla"] then
--Invert
if tArgs["-invert"] then
inverted = (string.lower(string.sub(tArgs[tArgs["-invert"]+1] or "",1,1)) == "t") else
term.write("Inverted? ")
inverted = (string.lower(string.sub(io.read(),1,1)) == "y")
end
changedT.new("Inverted", inverted)
--Rednet
if supportsRednet then
if tArgs["-rednet"] then 
rednetEnabled = (string.lower(string.sub(tArgs[tArgs["-rednet"]+1] or "",1,1)) == "t")
else term.write("Rednet? "); rednetEnabled = (string.lower(string.sub(io.read(),1,1)) == "y")
end
changedT.new("Rednet Enabled", rednetEnabled)
if tArgs["-sendChannel"] then
channels.send = assert(tonumber(tArgs[tArgs["-sendChannel"]+1]), errorT.num)
assert(channels.send > 0 and channels.send < 65535, errorT.zero)
changedT.new("Send Channel",channels.send) end
if tArgs["-receiveChannel"] then
channels.receive = assert(tonumber(tArgs[tArgs["-receiveChannel"]+1]), errorT.num)
assert(channels.receive > 0 and channels.receive < 65535 and channels.receive ~= channels.send, errorT.zero)
changedT.new("Receive Channel",channels.receive) end
end
--Fuel
if tArgs["-doRefuel"] then doRefuel = not doRefuel; changedT.new("Do Refuel",doRefuel) end
if turtle.getFuelLevel() == "unlimited" then
  doCheckFuel = false
else
  if tArgs["-doCheckFuel"] then
  doCheckFuel = (string.lower(string.sub(tArgs[tArgs["-doCheckFuel"]+1] or "",1,1)) == "t"); changedT.new("Do Check Fuel", doCheckFuel) end
end
if tArgs["-chest"] then
dropSide = sides[tArgs[tArgs["-chest"]+1]] or dropSide; changedT.new("Chest Side",dropSide) end
if tArgs["-fuelSafety"] then local loc = tArgs[tArgs["-fuelSafety"]+1]
  if fuelTable[loc] then
    fuelSafety = loc; changedT.new("Fuel Check Safety", fuelSafety)
  end
end
--Misc
if tArgs["-startY"] then
startY = math.abs(math.floor(checkNum(tArgs[tArgs["-startY"]+1],"Start Y")))
changedT.new("Start Y Position",startY) end
assert(startY >= 0, errorT.zero, "StartY")
if tArgs["-invCheckFreq"] then
invCheckFreq = math.abs(math.floor(checkNum(tArgs[tArgs["-invCheckFreq"]+1],"Inventory Check Frequency")))
changedT.new("Inventory Check Frequency",invCheckFreq) end
assert(invCheckFreq ~= 0, errorT.zero, "Inventory Check Frequency")
if tArgs["-keepOpen"] then
keepOpen = math.abs(math.floor(checkNum(tArgs[tArgs["-keepOpen"]+1],"Open Slots")))
changedT.new("Slots to keep open", keepOpen) end
assert(keepOpen ~= 0 and keepOpen < 16, errorT.zero, "Open Slots")
if tArgs["-ignoreResources"] then careAboutResources = false; changedT.new("Ignore Resources?", not careAboutResources) end
if tArgs["-saveFile"] then saveFile = tArgs[tArgs["-saveFile"]+1] changedT.new("Save File", saveFile) end
assert(#saveFile >= 2,errorT.word, "Save File")
end; end --First end is for vanilla, second is for DEFAULT

local function saveProgress(extras) --Session persistence
local file = fs.open(saveFile,"w")
for a,b in pairs(getfenv(1)) do
if type(b) == "string" then b = "\""..b.."\"" end
if type(b) == "table" and a~="modem" then b = textutils.serialize(b) end
if type(b) ~= "function" then
file.write(a.." = "..tostring(b).."\n")
end
end
file.write("doCheckFuel = false\n") --It has already used fuel, so calculation unnecessary
if type(extras) == "table" then
  for a, b in pairs(extras) do
    file.write(a.." = "..tostring(b))
  end
end
file.close()
end

local area = x*z
local volume = x*y*z
local lastHeight = y%3
local dispY = y
y = math.floor(y/3)*3
local yMult = y/3 + math.ceil(lastHeight/2)
local moveVolumeCalc = ((area+x+z)*yMult) + (2 * dispY)
local moveVolume = (area * yMult)

--Getting Fuel
if doCheckFuel then --Calculating Needed Fuel
local neededFuel = moveVolume + (math.floor(volume / (64 * 8)) * (x+dispY+z)) --Standard move plus dropping off supplies
                             --How many times come back to start| * If it were at the very far side
neededFuel = neededFuel + fuelTable[fuelSafety]
if neededFuel < 100 then neededFuel = 100; end
if checkFuel() < neededFuel then
screen(1,1)
print("More Fuel Needed")
print("Current Fuel: ",checkFuel()," Needed: ",neededFuel)
print("Place fuel in Bottom Right")
while turtle.getItemCount(16) == 0 do
  sleep(1)
end
turtle.select(16)
while checkFuel() < neededFuel do
if not turtle.refuel(1) then
term.clearLine()
print("Still too little fuel")
term.clearLine()
print("Insert more fuel to resume")
while turtle.getItemCount(16) == 0 do
  sleep(1)
end
end
local x,y = term.getCursorPos()
print(checkFuel().." Fuel")
term.setCursorPos(x,y)
end
print(checkFuel().." Units of Fuel")
sleep(3)
turtle.select(1)
end
end
--Initial Rednet Handshake
if rednetEnabled then
screen(1,1)
print("Rednet is Enabled")
print("The Channel to open is "..channels.send)
modem = peripheral.wrap("right")
modem.open(channels.receive)
local i = 0
repeat
local id = os.startTimer(3)
i=i+1
print("Sending Initial Message "..i)
modem.transmit(channels.send, channels.receive, "{ 'Initial' }")
local message
repeat
local event, idCheck, channel,_,locMessage, distance = os.pullEvent()
message = locMessage
until (event == "timer" and idCheck == id) or (event == "modem_message" and channel == channels.receive and message == channels.confirm)
until message == channels.confirm
connected = true
print("Connection Confirmed!")
sleep(1.5)
end
local function biometrics(sendChannel)
local commands = { Confirm = "Confirm" }
local toSend = { ["x"] = x, ["y"] = (y/3 + math.ceil(lastHeight/2)),
     ["z"] = z,                     --The y calc is weird...
    ["xPos"] = xPos, ["yPos"] = yPos, ["zPos"] = zPos, 
    ["percent"] = percent, ["mined" ]= mined, 
    ["fuel"] = checkFuel(), ["moved"] = moved, 
    ["remainingBlocks"] = (volume-mined), ["ID"] = os.getComputerID(),
    ["isInPath"] = isInPath, --Whether it is going back to start
    ["volume"] = volume, ["area"] = area}
modem.transmit(channels.send, channels.receive, textutils.serialize(toSend))
id = os.startTimer(0.1)
local event, message
repeat
local locEvent, idCheck, confirm, _, locMessage, distance = os.pullEvent()
event, message = locEvent, locMessage
until (event == "timer" and idCheck == id) or (event == "modem_message" and confirm == channels.receive)
if event == "modem_message" then connected = true else connected = false end
--Stuff to do for different commands
end
--Showing changes to settings
screen(1,1)
print("Your selected settings:")
if #changedT == 0 then
print("Completely Default")
else
for i=1, #changedT do
local title, value = changedT.getPair(i)
print(capitalize(title)..": ",value)
end
end
print("\nStarting in 3"); sleep(1); print("2"); sleep(1); print("1"); sleep(1.5)



----------------------------------------------------------------
--Define ALL THE FUNCTIONS
function display() --This is just the last screen that displays at the end
screen(1,1)
print("Total Blocks Mined: "..mined)
print("Current Fuel Level: "..turtle.getFuelLevel())
print("Cobble: "..totals.cobble)
print("Usable Fuel: "..totals.fuel)
print("Other: "..totals.other)
if rednetEnabled then
print("")
print("Sent Stop Message")
finalTable = {{["Mined: "] = mined}, {["Cobble: "] = totals.cobble}, {["Fuel: "] = totals.fuel},
    {["Other: "] = totals.other}, {["Fuel: "] = checkFuel()} }
modem.transmit(channels.send,channels.receive,"stop")
modem.transmit(channels.send,channels.receive,textutils.serialize(finalTable))
modem.close(channels.receive)
end
if doBackup then fs.delete(saveFile) end
end
function updateDisplay() --Runs in Mine(), display information to the screen in a certain place
screen(1,1)
print("Blocks Mined")
print(mined)
print("Percent Complete")
print(percent.."%")
print("Fuel")
print(checkFuel())
if rednetEnabled then
screenLine(1,7)
print("Connected: "..tostring(connected))
end
end
function isFull(slots)
  slots = slots or 16
  local numUsed = 0
  sleep(0)
  for i=1, slots do
    if turtle.getItemCount(i) > 0 then numUsed = numUsed + 1 end
  end
  if numUsed >= slots then
    return true 
  end
  return false
end
function dig(doAdd, func)
  doAdd = doAdd or true
  func = func or turtle.dig
  if func() then
    if doAdd then
      mined = mined + 1
    end
    return true
  end
  return false
end
function digUp(doAdd)
    return dig(doAdd,turtle.digUp)
end
function digDown(doAdd)
    return dig(doAdd,turtle.digDown)
end
function relativeXCalc()
  if rowCheck == "right" then relxPos = xPos else relxPos = (x-xPos)+1 end
end
function forward(doAdd)
  if doAdd == nil then doAdd = true end
  if turtle.forward() then
    if doAdd then
      moved = moved + 1
    end
   if facing == 0 then
      xPos = xPos + 1
    elseif facing == 1 then
      zPos = zPos + 1
    elseif facing == 2 then
      xPos = xPos - 1
    elseif facing == 3 then
      zPos = zPos - 1
    else
      error("Function forward, facing should be 0 - 3, got "..tostring(facing),2)
    end
    relativeXCalc()
    return true
  end
  return false
end
function up(sneak)
  sneak = sneak or 1
  if inverted and sneak == 1 then
    down(-1)
  else
    while not turtle.up() do
      while not digUp() do
        attackUp()
        sleep(0.5)
      end
    end
    yPos = yPos - sneak --Oh! I feel so clever
  end                   --This works because inverted :)
end
function down(sneak)
  sneak = sneak or 1
  local count = 0
  if inverted and sneak == 1 then
    up(-1)
  else
    while not turtle.down() do
      count = count + 1
      if not digDown() then
        attackDown()
        sleep(0.2)
      end
      if count > 20 then bedrock() end
    end
    yPos = yPos + sneak
  end
end
function right(num)
  num = num or 1
  for i=1, num do turtle.turnRight(); facingF(1); end
  saveProgress()
end
function left(num)
  num = num or 1
  for i=1, num do turtle.turnLeft(); facingF(-1) end
  saveProgress()
end
function attack(doAdd, func)
  doAdd = doAdd or true
  func = func or turtle.attack
  local didAttack
  if func() then
    if doAdd then 
      attacked = attacked + 1
    end
    return true
  end
  return false
end
function attackUp(doAdd)
  if inverted then
    return attack(doAdd, turtle.attackDown)
  else
    return attack(doAdd, turtle.attackUp)
  end
end
function attackDown(doAdd)
  if inverted then
    return attack(doAdd, turtle.attackUp)
  else
    return attack(doAdd, turtle.attackDown)
  end
end


function mine(doDigDown, doDigUp, outOfPath,doCheckInv) -- Basic Move Forward
if doCheckInv == nil then doCheckInv = true end
if doDigDown == nil then doDigDown = true end
if doDigUp == nil then doDigUp = true end
if outOfPath == nil then outOfPath = false end
if inverted then
  doDigUp, doDigDown = doDigDown, doDigUp --Just switch the two if inverted
end
if doRefuel and checkFuel() < 100 then
  for i=1, 16 do
  if turtle.getItemCount(i) > 0 then
    turtle.select(i)
    if checkFuel() < 200 + fuelTable[fuelSafety] then
      turtle.refuel()
    end
  end
  end
end
local count = 0
while not forward(not outOfPath) do
  sleep(0) --Calls coroutine.yield to prevent errors
  count = count + 1
  if not dig() then
    attack()
  end
  if count > 10 then
    attack()
    sleep(0.2)
  end
  if count > 50 then 
    ran, bool = pcall(function() return turtle.getFuelLevel() > 0 end) --This is done to avoid errors
    if ran and bool == true then                                       --When fuel is infinite
      if yPos > (startY-7) then --If it is near bedrock
        bedrock()
      else --Otherwise just sleep for a bit
        sleep(1)
      end
    else
      error("No Fuel",0)
    end
  end
end
if doDigUp then
while turtle.detectUp() do 
  sleep(0) --Calls coroutine.yield
  if not digUp() then
    attackUp()
    count = count + 1
  end
  if count > 50 and yPos > (startY-7) then --Same deal with bedrock as above
    bedrock()
  end
  end
end
if doDigDown then
 digDown()
end
percent = math.ceil(moved/moveVolume*100)
updateDisplay()
local tab = {} --This registers a change in the saveProgress file
if facing == 0 then --I do this because when it restores, it always
  tab.xPos = xPos + 1-- Thinks it is one position back, for some reason
elseif facing == 1 then-- This overwrites that.
  tab.zPos = zPos + 1
elseif facing == 2 then
  tab.xPos = xPos - 1
elseif facing == 3 then
  tab.zPos = zPos - 1
end
saveProgress(tab)
isInPath = (not outOfPath)
if doCheckInv and careAboutResources then
if moved%invCheckFreq == 0 then
 if isFull(16-keepOpen) then dropOff() end
end; end
if rednetEnabled then biometrics() end
end
--Direction: Front = 0, Right = 1, Back = 2, Left = 3
function facingF(num)
facing = facing + num
if facing > 3 then facing = 0 end
if facing < 0 then facing = 3 end
end

function turnTo(num, dir)
  num = num or facing
  dir = dir or "left"
  while facing ~= num do
    if dir == "left" then
      left()
    elseif dir == "right" then
      right()
    else
      error("TurnTo: Left or Right expected, got "..tostring(dir))
    end
  end
end
function goto(x,z,y, toFace)
--Will first go to desired z pos, then x pos, y pos varies
x = x or 1; y = y or 1; z = z or 1; toFace = toFace or facing
gotoX,gotoY,gotoZ,gotoFacing = xPos,yPos,zPos,facing --For use in session persistence
if yPos > y then --Will go up first if below position
  while yPos~=y do up() end
end
if zPos > z then
  turnTo(3)
elseif zPos < z then 
  turnTo(1)
end
while zPos ~= z do mine(false,false,true,false) end
if xPos > x then
  turnTo(2)
elseif xPos < x then
  turnTo(0)
end
while xPos ~= x do mine(false,false,true,false) end
if yPos < y then --Will go down after if above position
  while yPos~=y do down() end
end
turnTo(toFace,"right")
saveProgress()
gotoX,gotoY,gotoZ,gotoFacing = nil
end
function drop(side, final, allowSkip)
side = sides[side] or "front"    --The final number means that it will
if final then final = 0 else final = 1 end --drop a whole stack at the end
local allowSkip = allowSkip or (final == 0) --This will allow drop(side,t/f, rednetConnected)
count()
if doRefuel then
  for i=1, 16 do
    if slot[i][1] == 2 then
      turtle.select(i); turtle.refuel()
    end
  end
  turtle.select(1)
end
if side == "right" then turnTo(1) end
if side == "left" then turnTo(3) end
local whereDetect, whereDrop1, whereDropAll
local _1 = slot[1][2] - final --All but one if final, all if not final
if side == "top" then
whereDetect = turtle.detectUp ; whereDrop = turtle.dropUp
elseif side == "bottom" then
whereDetect = turtle.detectDown ; whereDrop = turtle.dropDown
else
whereDetect = turtle.detect; whereDrop = turtle.drop
end
local function waitDrop(val) --This will just drop, but wait if it can't
  val = val or 64
  local try = 1
  while not whereDrop(val) do
    print("Chest Full, Try "..try)
    try = try + 1
    sleep(2)
  end
end
repeat
local detected = whereDetect()
if detected then
  waitDrop(_1)
  for i=2, 16 do
    if turtle.getItemCount(i) > 0 then
      turtle.select(i)
      waitDrop()
    end
  end
elseif not allowSkip then
  print("Waiting for chest placement place a chest to continue")
  while not whereDetect() do
    sleep(1)
  end
end
until detected or allowSkip
if not allowSkip then totals.cobble = totals.cobble - 1 end
turtle.select(1)
turnTo(0)
end
function dropOff() --Not local because called in mine()
local currX,currZ,currY,currFacing = xPos, zPos, yPos, facing
goto(0,1,1,2)
drop(dropSide,false)
mine(false,false,true, false)
goto(1,1,1, 0)
goto(currX,currZ,currY,currFacing)
end
function bedrock()
local origin = {x = xPos, y = yPos, z = zPos}
print("Bedrock Detected")
if turtle.detectUp() then
print("Block Above")
local var
if facing == 0 then var = 2 elseif facing == 2 then var = 0 else error("Was facing left or right on bedrock") end
goto(xPos,zPos,yPos,var)
for i=1, relxPos do mine(true,true); end
end
goto(0,1,1,2)
drop(dropSide, true)
display()
print("\nFound bedrock at these coordinates: ")
print(origin.x," Was position in row\n",origin.z," Was row in layer\n",origin.y," Blocks down from start")
error("",0)
end
-------------------------------------------------------------------------------------
--Pre-Mining Stuff dealing with session persistence
local doDigDown, doDigUp = (lastHeight ~= 1), false --Used in lastHeight
if not restoreFound then mine(false,false, true) else digUp(); digDown() end --Get it into the quarry
if restoreFound then
  if gotoX then
    goto(gotoX,gotoZ,gotoY,gotoFacing)
  end
  local func
  if rowCheck == "left" then func = right else func = left end
  if endRow == 1 then
    mine()
    func()
  elseif endRow == 2 then
    func()
  end
end
if y ~= 0 and not restoreFound then down() end
--Mining Loops
turtle.select(1)
while layersDone <= y do -------------Height---------
moved = moved + 1 --To account for the first position in row as "moved"
if not restoreFound then rowCheck = "right" end
relativeXCalc()
while zPos <= z do -------------Width----------
while relxPos < x do ------------Length---------
mine()
end ---------------Length End-------
if zPos ~= z then
local func
if rowCheck == "right" and zPos ~= z then --Swithcing to next row
  func = right; rowCheck = "left"; else func = left; rowCheck = "right" end --Which way to turn
  func()
  endRow = 1
  mine()
  endRow = 2
  func()
  endRow = 0
else break
end
end ---------------Width End--------
goto(1,1,yPos,0)
if yPos+1 ~= y then 
  for i=1, 3 do down() end
end
layersDone = layersDone + 3
restoreFound = false --This is done so that rowCheck works properly upon restore
end ---------------Height End-------
if lastHeight ~= 0 then ---------LAST ROW--------- (copied from above)
moved = moved + 1 --To account for the first position in row as "moved"
if y ~= 0 then --If the basic y == 2 or 1
  for i=1, 2 do down() end
end 
if not restoreFound then rowCheck = "right" end
relativeXCalc()
while zPos <= z do -------------Width----------
while relxPos < x do ------------Length---------
mine(doDigDown,doDigUp)
end ---------------Length End-------
if zPos ~= z then
local func
if rowCheck == "right" and zPos ~= z then --Swithcing to next row
  func = right; rowCheck = "left"; else func = left; rowCheck = "right" end --Which way to turn
  func()
  endRow = 1
  mine(doDigDown,doDigUp)
  endRow = 2
  func()
  endRow = 0
else break
end
end ---------------Width End--------
goto(1,1,yPos,0)
end
if doDigDown then
  if inverted then
    digUp()
  else
    digDown()
  end
end
goto(0,1,1,2)

--Output to a chest or sit there
drop(dropSide, true)
--Display was moved above to be used in bedrock function
display()