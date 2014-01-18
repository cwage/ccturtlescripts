--MENU
--VARIABLES

local version = "ULTIMATE WOOD CHOPPER BETA 0.9.0"
local w,h = term.getSize()
local select, distance, turtleslot = 1, 7, 1
local running, chopping, usebonemeal = true, true, true
local a, b, c, d, e, f, z = 6,7,8,9,10,11,h-2
turtle.select(turtleslot)

--VARIABLES
cancelTimer = 2
bonemealTimer = 120
bonemealFirstDelay = 0
amountMaxWoodSlotBonemeal = 14
amountMaxWoodSlotNoBonemeal = 7
amountMinBonemeal = 8
amountMinSaplings = 17
amountMinFuelLevel = 1200
amountFurnaceWoodBonemeal = 16
amountFurnaceWoodNoBonemeal = 8
debugMaxHeight = 55


function loadVariables()
 local file = fs.open("uwcvariables","r")
 cancelTimer = tonumber(file.readLine())
 bonemealTimer = tonumber(file.readLine())
 bonemealFirstDelay = tonumber(file.readLine())
 amountMaxWoodSlotBonemeal = tonumber(file.readLine())
 amountMaxWoodSlotNoBonemeal = tonumber(file.readLine())
 amountMinBonemeal = tonumber(file.readLine())
 amountMinSaplings = tonumber(file.readLine())
 amountMinFuelLevel = tonumber(file.readLine())
 amountFurnaceWoodBonemeal = tonumber(file.readLine())
 amountFurnaceWoodNoBonemeal = tonumber(file.readLine())
 debugMaxHeight = tonumber(file.readLine())
 file.close()
end

function saveVariables()
 if fs.exists("uwcvariables") then
  fs.delete("uwcvariables")
 end
 sleep(0.5)
 local file = fs.open("uwcvariables","w")
 file.writeLine(cancelTimer)
 file.writeLine(bonemealTimer)
 file.writeLine(bonemealFirstDelay)
 file.writeLine(amountMaxWoodSlotBonemeal)
 file.writeLine(amountMaxWoodSlotNoBonemeal)
 file.writeLine(amountMinBonemeal)
 file.writeLine(amountMinSaplings)
 file.writeLine(amountMinFuelLevel)
 file.writeLine(amountFurnaceWoodBonemeal)
 file.writeLine(amountFurnaceWoodNoBonemeal)
 file.writeLine(debugMaxHeight)
 file.close()
end

if fs.exists("uwcvariables") then
 loadVariables()
else
 saveVariables()
end


--PRINT

local function printCentered(str, ypos)
 term.setCursorPos(w/2 - #str/2, ypos)
 term.write(str)
end

local function printRight(str, ypos)
 term.setCursorPos(w-#str, ypos)
 term.write(str)
end

function clearScreen()
 term.clear()
 term.setCursorPos(1,1)
 term.clear()
end

function drawHeader(title, line)
 printCentered(title, line)
 printCentered(string.rep("-", w), line+1)
end

function drawCopyright()
 printRight("by UNOBTANIUM", h)
end

--MENUS

function drawMenuMain()
 drawCopyright()
 drawHeader(version, 1)
 if select == 1 then
  printCentered(">> Chop <<", a)
 else
  printCentered("Chop", a)
 end
 if select == 2 then
  printCentered(">> Turtle Interactions <<", b)
 else
  printCentered("Turtle Interactions", b)
 end
 if select == 3 then
  printCentered(">> Build and Expand <<", c)
 else
  printCentered("Build and Expand", c)
 end
 if select == 4 then
  printCentered(">> Help <<", d)
 else
  printCentered("Help", d)
 end
 if select == 5 then
  printCentered("> Credits <", e)
 else
  printCentered("Credits", e)
 end
 if select == 6 then
  printCentered("> Quit <", 11)
 else
  printCentered("Quit", 11)
 end
end

function drawMenuFarm()
 drawHeader(version, 1)
 
 if select == 1 then
  printCentered(">> Farm <<", a)
 else
  printCentered("Farm", a)
 end
 if select == 2 then
  printCentered(">> Single Tree <<", b)
 else
  printCentered("Single Tree",b)
 end
 if select == 3 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end 
end

function drawMenuChop()
 drawHeader(version, 1)
 drawHeader("FARM", 3)

 if select == 1 then
  printCentered("> Standard Farm <", a)
 else
  printCentered("Standard Farm", a)
 end
 if select == 2 then
  printCentered("> Expanded Farm <", b)
 else
  printCentered("Expanded Farm", b)
 end
 if select == 3 then
  printCentered("> Standard Farm without bonemeal <", c)
 else
  printCentered("Standard Farm without bonemeal", c)
 end
 if select == 4 then
  printCentered("> Expanded Farm without bonemeal <", d)
 else
  printCentered("Expanded Farm without bonemeal", d)
 end
 if select == 5 then
  printCentered("> Variables <", e)
 else
  printCentered("Variables", e)
 end
 
 if select == 6 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuBuild()
 drawHeader(version, 1)
 drawHeader("BUILD AND EXPAND", 3)
 printCentered("Does the Turtle has all materials?",10)

 if select == 1 then
  printCentered("> Set up a farm <", a)
 else
  printCentered("Set up a farm", a)
 end
 if select == 2 then
  printCentered("> Expand the farm <", b)
 else
  printCentered("Expand the farm", b)
 end
 if select == 3 then
  printCentered("> Add more chests <", c)
 else
  printCentered("Add more chests", c)
 end
 if select == 4 then
  printCentered("> Back <", 12)
 else
  printCentered("Back", 12)
 end
end

function drawMenuHelpDebug()
 drawHeader(version, 1)
 drawHeader("DEBUG", 3)

 if select == 1 then
  printCentered("> Standard Farm <", a)
 else
  printCentered("Standard Farm", a)
 end
 if select == 2 then
  printCentered("> Expanded Farm <", b)
 else
  printCentered("Expanded Farm", b)
 end
 if select == 3 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuHelpPrograms()
 drawHeader(version, 1)
 drawHeader("HELP PROGRAMS", 3) 


 if select == 1 then
  printCentered("> Position <", a)
 else
  printCentered("Position", a)
 end
 if select == 2 then
  printCentered("> Dig needed space <", b)
 else
  printCentered("Dig needed space", b)
 end
 if select == 3 then
  printCentered(">> Debug <<", c)
 else
  printCentered("Debug", c)
 end
 if select == 4 then
  printCentered("> Move Down <", d)
 else
  printCentered("Move Down", d)
 end
 
 if select == 5 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuHelp()
 drawHeader(version, 1)
 drawHeader("HELP", 3)

 if select == 1 then
  printCentered(">> Help Programs <<", a)
 else
  printCentered("Help Programs", a)
 end
 if select == 2 then
  printCentered(">> Help Interface <<", b)
 else
  printCentered("Help Interface", b)
 end
 if select == 3 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuSingleTreeChop()
 drawHeader(version, 1)
 drawHeader("SINGLE TREE CHOP", 3)

 if select == 1 then
  printCentered("> General 1x1 Tree <", a)
 else
  printCentered("General 1x1 Tree", a)
 end
 if select == 2 then
  printCentered("> General 2x2 Tree <", b)
 else
  printCentered("General 2x2 Tree", b)
 end
 if select == 3 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuTurtleInteractions()
 drawHeader(version, 1)
 drawHeader("TURTLE INTERACTIONS", 3)

 if select == 1 then
  printCentered(">> Movement <<", a)
 else
  printCentered("Movement", a)
 end
 if select == 2 then
  printCentered(">> Actions <<", b)
 else
  printCentered("Actions", b)
 end
 if select == 3 then
  printCentered("> Control <", c)
 else
  printCentered("Control", c)
 end
 if select == 4 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuTurtleMovement()
 drawHeader(version, 1)
 drawHeader("TURTLE MOVEMENT", 3)

 if select == 1 then
  printCentered("> Forward <", a)
 else
  printCentered("Forward", a)
 end
 if select == 2 then
  printCentered("> Back <", b)
 else
  printCentered("Back", b)
 end
 if select == 3 then
  printCentered("> Up <", c)
 else
  printCentered("Up", c)
 end
 if select == 4 then
  printCentered("> Down <", d)
 else
  printCentered("Down", d)
 end
 if select == 5 then
  printCentered("> Turn Left <", e)
 else
  printCentered("Turn Left", e)
 end
 if select == 6 then
  printCentered("> Turn Right <", f)
 else
  printCentered("Turn Right", f)
 end
 if select == 7 then
  printCentered("> Back <", 12)
 else
  printCentered("Back", 12)
 end
end

function drawMenuTurtleActions()
 drawHeader(version, 1)
 drawHeader("TURTLE ACTIONS", 3)

 if select == 1 then
  printCentered("> Refuel <", a)
 else
  printCentered("Refuel", a)
 end
 if select == 2 then
  printCentered(">> Dig <<", b)
 else
  printCentered("Dig", b)
 end
 if select == 3 then
  printCentered("> Select <", c)
 else
  printCentered("Select", c)
 end
 if select == 4 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuTurtleDig()
 drawHeader(version, 1)
 drawHeader("TURTLE DIG", 3)

 if select == 1 then
  printCentered("> Up <", a)
 else
  printCentered("Up", a)
 end
 if select == 2 then
  printCentered("> Front <", b)
 else
  printCentered("Front", b)
 end
 if select == 3 then
  printCentered("> Down <", c)
 else
  printCentered("Down", c)
 end
 if select == 4 then
  printCentered("> Back <", z)
 else
  printCentered("Back", z)
 end
end

function drawMenuCredits()
 drawHeader(version,1)
 printCentered("all nicknames from the CC forums!!",3)
 printCentered("- IDEA, CODEING & PUBLISHER -",5)
 printCentered("unobtanium",6)
 printCentered("- HELPING WITH CODING -",8)
 printCentered("theoriginalbit, Mtdj2, NitrogenFingers", 9)
 printCentered("- SPECIAL THANKS GOES TO -",11)
 printCentered("Hoppingmad9, xInDiGo, Seleck",12)
 printCentered("Permutation, PhilHibbs, DavEdward ",13)
 read()
 clearScreen()
 drawHeader(version,1)
 printCentered("- MENTIONABLES -",3)
 printCentered("HotGirlEAN, snoxx, steel_toed_boot,",4)
 printCentered("Zagi, Kylun, Kravyn, PhaxeNor, ughzug",5)
 printCentered("sjkeegs, atlas, Minithra, TheFan",6)
 printCentered("grumpysmurf, Quickslash78, lewanator1",7)
 printCentered("behedwin, TESTimonSHOOTER",8)
 printCentered("Kevironi, Fuzzlewhumper, Bigdavie",9)
 printCentered("Viproz, Bigjimmy12, bomanski, punchin",10)
 printCentered("oxgon, ahwtx, zilvar2k11",11)
 printCentered("The_Ianator, Coolkrieger3", 12)
 read()
 clearScreen()
 drawHeader(version,1)
 printCentered(version,1)
 printCentered("And last but not least",6)
 printCentered("You, the users and players :D",7)
 printCentered("Thank you everybody!!!", 10)
 read()
end

--MENUSTATE

local menustate = "main"

local mopt = {
 ["main"] = {
  options = {"mainchopprograms", "turtleinteractions" ,"buildprograms", "help", "credits","quit"},
  draw = drawMenuMain
 },

 ["mainchopprograms"] = {
  options = {"farmprograms", "singletreechopprograms", "main"},
  draw = drawMenuFarm
 },
 ["farmprograms"] = {
  options = {"standard", "expanded", "standardnobonemeal", "expandednobonemeal", "variables", "mainchopprograms"},
  draw = drawMenuChop
 },
 ["buildprograms"] = {
  options = {"build","expand", "expandchests", "main"},
  draw = drawMenuBuild
 },
 ["singletreechopprograms"] = {
  options = {"onebyone", "twobytwo", "mainchopprograms"},
  draw = drawMenuSingleTreeChop
 },
 ["help"] = {
  options = {"helpprograms", "helpinterface", "main"},
  draw = drawMenuHelp
 },
 ["helpprograms"] = {
  options = {"position", "digSpace", "helpdebugprograms", "godown", "help"},
  draw = drawMenuHelpPrograms
 },
 ["helpdebugprograms"] = {
  options = {"debugstandard", "debugexpanded","helpprograms"},
  draw = drawMenuHelpDebug
 },

 ["turtleinteractions"] = {
  options = {"turtlemovement", "turtleactions", "control", "main"},
  draw = drawMenuTurtleInteractions
 },
 ["turtlemovement"] = {
  options = {"forward", "back", "up", "down", "left", "right" , "turtleinteractions"},
  draw = drawMenuTurtleMovement
 },
 ["turtleactions"] = {
  options = {"refuel", "turtledig", "select", "turtleinteractions"},
  draw = drawMenuTurtleActions
 },
 ["turtledig"] = {
  options = {"digup", "digfront", "digdown", "turtleactions"},
  draw = drawMenuTurtleDig
 }
}


--RUN MENU

function runMenu()
 while true do
  clearScreen()
  mopt[menustate].draw()

  local id, key = os.pullEvent("key")
  if key == 200  or key == 17 then
   select = select-1
  end
  if key == 208 or key == 31 then
   select = select+1
  end
  if select == 0 then
   select = #mopt[menustate].options
  end
  if select > #mopt[menustate].options then
   select = 1
  end
  if key == 65 or key == 30 then
   if not menustate == "quit" then
    select = #mopt[menustate].options
    menustate = mopt[menustate].options[select]
    select = 1
   else
    clearScreen()
    running = false
    break
   end
  end
  clearScreen()
  if key == 28 or key == 32 then
   if mopt[menustate].options[select] == "quit" then
    running = false
    break
   elseif mopt[menustate].options[select] == "credits" then
    drawMenuCredits()
   elseif mopt[menustate].options[select] == "standard" then
    usebonemeal = true
    FWCchop()
   elseif mopt[menustate].options[select] == "expanded" then
    usebonemeal = true
    FWCchop2()
   elseif mopt[menustate].options[select] == "debugstandard" then
    FWCdebugstandard()
   elseif mopt[menustate].options[select] == "debugexpanded" then
    FWCdebugexpanded()
   elseif mopt[menustate].options[select] == "build" then
    FWCbuild()
   elseif mopt[menustate].options[select] == "expand" then
    FWCexpand()
   elseif mopt[menustate].options[select] == "helpinterface" then
    FWChelp()
   elseif mopt[menustate].options[select] == "position" then
    FWCposition()
   elseif mopt[menustate].options[select] == "expandchests" then
    FWCexpandchests()
   elseif mopt[menustate].options[select] == "onebyone" then
    FWConebyone()
   elseif mopt[menustate].options[select] == "twobytwo" then
    FWCtwobytwo()
   elseif mopt[menustate].options[select] == "standardnobonemeal" then
    usebonemeal = false
    FWCchop()
   elseif mopt[menustate].options[select] == "expandednobonemeal" then
    usebonemeal = false
    FWCchop2()
   elseif mopt[menustate].options[select] == "digSpace" then
    FWCdigSpace()
   elseif mopt[menustate].options[select] == "forward" then
    turtle.forward()
   elseif mopt[menustate].options[select] == "back" then
    turtle.back()
   elseif mopt[menustate].options[select] == "up" then
    turtle.up()
   elseif mopt[menustate].options[select] == "down" then
    turtle.down()
   elseif mopt[menustate].options[select] == "left" then
    turtle.turnLeft()
   elseif mopt[menustate].options[select] == "right" then
    turtle.turnRight()
   elseif mopt[menustate].options[select] == "refuel" then
    turtle.refuel(1)
   elseif mopt[menustate].options[select] == "select" then
    turtleslot = turtleslot + 1
    if turtleslot > 16 then turtleslot = 1 end
    turtle.select(turtleslot)
   elseif mopt[menustate].options[select] == "digup" then
    turtle.digUp()
   elseif mopt[menustate].options[select] == "digfront" then
    turtle.dig()
   elseif mopt[menustate].options[select] == "digdown" then
    turtle.digDown()
   elseif mopt[menustate].options[select] == "godown" then
    UWCgodown()
   elseif mopt[menustate].options[select] == "variables" then
    UWCvariables()
   elseif mopt[menustate].options[select] == "control" then
    control()
   elseif true then
    menustate = mopt[menustate].options[select]
    select = 1
   end
  end
 end
end





--ULTIMATE WOOD CHOPPER PROGRAMS
--VARIABLES
local dirtexpand, pipeexpand, obsidianpipeexpand, blockslot, coal, chest, furnace, dirt, pipe, ironpipe, goldpipe, obsidianpipe, woodenpipe, engine, lever, bonemeal, stone1, stone2, stone3, sapling, fuel = 2,3,4,5,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,3

--MOVE FUNCTIONS

function forward()
 while not turtle.forward() do end
end

function back()
 while not turtle.back() do end
end

function up()
 while not turtle.up() do end
end

function down()
 while not turtle.down() do end
end

--MAIN CHOP PROGRAM FUNCTIONS

local function refreshItemStack(i)
 turtle.select(3)
 turtle.suck()
 turtle.select(i)
 turtle.drop()
 turtle.select(3)
 turtle.drop()
 turtle.select(i)
 turtle.suck()
 if turtle.getItemCount(3) > 0 then
  print("!!!!!!!!!")
  print("The coal or sapling chest is full! Please take out some stacks, otherwise you lose items! The turtle will drop them!")
  print("!!!!!!!!!")
  turtle.select(3)
  turtle.dropDown()
 end
end

local function moveForward(j)
 for i = 1,j do
  forward()
 end
end

local function getCoal()
 local delay = os.startTimer(cancelTimer)
 print("Taking coal out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")
 
 while turtle.getFuelLevel() < amountMinFuelLevel do
  event = { os.pullEvent() }
  if event[1] == "timer" and event[2] == delay then
   turtle.select(3)
   turtle.suck()
   if turtle.getItemCount(3) > 0 then  
    turtle.refuel(math.ceil((amountMinFuelLevel - turtle.getFuelLevel())/80))
    turtle.drop()
    if turtle.getFuelLevel() < amountMinFuelLevel then
     delay = os.startTimer(2)
    end
   else 
    delay = os.startTimer(cancelTimer)
   end
  elseif event[1] == "key" and event[2] == 28 then
   print("Terminated by User!")
   clearScreen()
   os.shutdown()
  end
 end
 print("Succesful!")
end

local function getSaplings()
 local taking = true
 local delay = os.startTimer(cancelTimer)
 print("Taking saplings out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")

 while taking == true do
  event = { os.pullEvent() }
  if event[1] == "timer" and event[2] == delay then
   refreshItemStack(1)
   if turtle.getItemCount(1) < amountMinSaplings then
    delay = os.startTimer(cancelTimer)
   else
    taking = false
   end
  elseif event[1] == "key" and event[2] == 28 then
   print("Terminated by User!")
   turtle.turnRight()
   forward()
   turtle.turnRight()
   clearScreen()
   os.shutdown()
  end
 end
 print("Succesful!")
end

local function getBonemeal()
 local taking = true
 local delay = os.startTimer(cancelTimer)
 print("Taking bonemeal out of the chest!")
 print("If nothing happens the chest has too less materials!")
 print("Press Enter to terminate process!")

 while taking == true do
  event = { os.pullEvent() }
  if usebonemeal == true then
   if event[1] == "timer" and event[2] == delay then
    turtle.select(3)
    turtle.suckUp()
    turtle.select(2)
    turtle.dropUp()
    turtle.select(3)
    turtle.dropUp()
    turtle.select(2)
    turtle.suckUp()
    if turtle.getItemCount(3) > 0 then
     print("!!!!!!!!!")
     print("The bonemeal chest is full! Please take out some stacks, otherwise you lose items! The turtle will drop them!")
     print("!!!!!!!!!")
     turtle.select(3)
     turtle.dropDown()
    end
    if turtle.getItemCount(2) < amountMinBonemeal then
     delay = os.startTimer(cancelTimer)
    else
     taking = false
    end
   elseif event[1] == "key" and event[2] == 28 then
    print("Terminated by User!")
    turtle.turnRight()
    forward()
    turtle.turnRight()
    clearScreen()
    os.shutdown()
   end
  else
   turtle.select(2)
   turtle.dropUp()
   taking = false
  end
 end
 print("Successful!")
end

local function storeWood()
 print("Storing wood in the chests!")
 chestfull = true
 while chestfull == true do
  if usebonemeal == true then
   for i=3,16 do
    if turtle.getItemCount(i) > 0 then
     turtle.select(i)
     chestfull = turtle.drop()
    end
   end
  else
   for i=2,16 do
    if turtle.getItemCount(i) > 0 then
     turtle.select(i)
     chestfull = turtle.drop()
    end
   end
  end

  chestfull = not chestfull
   
  if chestfull == true and turtle.detectUp() == true then
   print("Wood! Wood everywhere!!!")
   print("Your wood chests are full!")
   print("Try to add more vertical chests or take wood out of them.")
   print("")
   chopping = false
   while turtle.detectDown() == false do
    down()
   end
   turtle.turnRight()
      
  end

  if chestfull == true and turtle.detectUp() == false then
   up()
   print("This Chest is full!")
  end

 end
 
 while turtle.detectDown() == false do
 down()
 end
 
 print("Successful stored the wood!")
 print("")
end

local function plantTree()
 print("Planting saplings!")
 moveForward(2)
 turtle.turnRight()
 turtle.select(1)
 turtle.place()
 turtle.turnLeft()
 back()
 turtle.place()
 turtle.turnRight()
 turtle.place()
 turtle.turnLeft()
 back()
 turtle.place()
 if usebonemeal == true then
  while turtle.compare() == true and turtle.getItemCount(2) > 2 do
   print("Fertilizing the tree with bonemeal!")
   turtle.select(2)
   turtle.place()
   turtle.select(1)
   sleep(bonemealFirstDelay)
   if turtle.compare() == true then
    print("Tree didnt grown with bonemeal!")
    print("Will try again in two minutes...")
    sleep(bonemealTimer)
   end
  end
 else
  print("Waiting for the tree to grow!")
  print("Get some coffee this may take a while ;D")
  while turtle.compare() == true do
   os.sleep(5)
  end
 end
 print("Successful planted new tree!")
 print("")
end

local function getMaterials()
 turtle.turnRight()
 turtle.turnRight()
 moveForward(distance)
 
 turtle.select(3)
 if usebonemeal then
  turtle.dropDown(amountFurnaceWoodBonemeal)
 else
  turtle.dropDown(amountFurnaceWoodNoBonemeal)
 end
 storeWood()

 turtle.turnRight()
    
 if redstone.getInput("back") == false then
  print("Shutdown by redstone signal!")
  chopping = false
 else
  getCoal()
  turtle.turnRight()
  turtle.forward()
  turtle.turnRight()  
  getSaplings()
  getBonemeal()
  turtle.turnLeft()
  moveForward(distance-1)
 end
end

local function cutWood()
 print("Chopping down the tree!")
 local height = 0
 turtle.select(1)
 turtle.dig()
 forward()
 turtle.dig()
 while turtle.detectUp() do
  turtle.digUp()
  up()
  turtle.dig()
  height = height + 1
 end
 print("Reached the top of the tree!")
 turtle.turnRight()
 turtle.dig()
 forward()
 turtle.turnLeft()
 turtle.dig()
 while height > 0 do
  turtle.digDown()
  down()
  turtle.dig()
  height = height - 1
 end
 print("Successful chopped the tree!")
 print("")
 back()
 turtle.turnLeft()
 forward()
 turtle.turnRight()
end

function chop()
 if redstone.getInput("back") == true then
  print("Starting the Fir Wood Chooper program!")
  getCoal()
  if turtle.getItemCount(3) > 0 or turtle.getItemCount(16) > 0 then
   turtle.turnLeft()
   storeWood()
   turtle.turnRight()
  end
  turtle.turnRight()
  forward()
  turtle.turnRight()
  if turtle.getItemCount(1) < amountMinSaplings then
   getSaplings()
  end
  if turtle.getItemCount(2) < amountMinBonemeal and usebonemeal == true then
   getBonemeal()
  end
  if turtle.getItemCount(2) > 0 and usebonemeal == false then
   turtle.select(2)
   turtle.dropUp()
  end
  turtle.turnRight()
  forward()
  turtle.turnRight()
  turtle.turnRight()
  moveForward(distance)
  
  while chopping == true do
   local needMaterials = false
   if turtle.getFuelLevel() < 200 then
    needMaterials = true
    print("Have to refuel!")
   end
   if turtle.getItemCount(1) < amountMinSaplings then
    needMaterials = true
    print("Need more Saplings!")
   end
   if turtle.getItemCount(2) < amountMinBonemeal and usebonemeal then
    needMaterials = true
    print("Need more bonemeal!")
   end
   if usebonemeal and turtle.getItemCount(amountMaxWoodSlotBonemeal) > 0 then
    needMaterials = true
    print("Inventory almost full with wood!")
   end
   if usebonemeal == false and turtle.getItemCount(amountMaxWoodSlotNoBonemeal) > 0 then
    needMaterials = true
    print("Enough wood harvested!")
   end
   if needMaterials == true then
    getMaterials()
   end
   if chopping == true then
    plantTree()
    cutWood()
   end
  end
 else
  print("No redstone signal, no wood!")
  print("Be sure the Turtle is facing the coal chest and stays above the furnace!")
  print("The redstone signal has to be in the back of the Turtle!")
 end
 print("Press Enter to get back into the menu!")
 read()
 chopping = true
end

--FWCchop 11111111111111111111111

function FWCchop()
 distance = 7
 chop()
end


--FWCchop2 2222222222222222222222

function FWCchop2()
 distance = 9
 chop()
end

--MAIN DEBUG FUNCTIONS

local function debugTree()
 local height = 0
 turtle.select(1)
 turtle.dig()
 forward()
 turtle.dig()
 while not turtle.detectUp() and height < debugMaxHeight do
  turtle.up()
  height = height + 1
 end
 turtle.dig()
 while turtle.detectUp() do
  turtle.digUp()
  turtle.up()
  turtle.dig()
  height = height + 1
 end
 turtle.turnRight()
 turtle.dig()
 forward()
 turtle.turnLeft()
 turtle.dig()
 while height > 0 do
  turtle.digDown()
  down()
  turtle.dig()
  height = height - 1
 end
 back()
 turtle.turnLeft()
 forward()
 turtle.turnLeft()
end

--FWCdebugstandard 33333333333333333333333333

function FWCdebugstandard()
 turtle.turnRight()
 moveForward(7)
 debugTree()
 moveForward(7)
 turtle.turnRight()
 print("Debug for standard farm finished!")
 print("Press Enter to get back into the menu!")
 read()
end

--FWCdebugexpand 44444444444444444444444444444

function FWCdebugexpanded()
 turtle.turnRight()
 moveForward(9)
 debugTree()
 moveForward(9)
 turtle.turnRight()
 print("Debug for expanded farm finished!")
 print("Press Enter to get back into the menu!")
 read()
end

--MAIN BUILD FUNCTIONS

local function dbp(j)
 for i=1,j do
  turtle.placeDown()
  turtle.back()
  turtle.place()
 end
end

local function fd(j)
 for i=1,j do
  turtle.forward()
  turtle.placeDown()
 end
end

local function bp(j)
 for i=1,j do
  turtle.back()
  turtle.place()
 end
end

local function lb()
 turtle.turnLeft()
 turtle.back()
end

--FWCbuild 55555555555555555555555555555555555

function FWCbuild()
 if turtle.detectDown() then
  print("There is a block underneath the turtle.")
  print("Be sure you have free space under the turtle.")
  print("Press Enter to get back to the menu.")
  read()
  return false
 end
 turtle.select(coal)
 turtle.refuel(fuel)
 turtle.select(stone1)
 moveForward(2)
 turtle.turnRight()
 forward()
 turtle.placeUp()
 dbp(1)
 turtle.placeUp()
 turtle.placeDown()
 back()
 turtle.placeUp()
 dbp(1)
 down()
 down()
 turtle.turnLeft()
 turtle.turnLeft()
 forward() 

 dbp(4)
 turtle.select(stone1)
 bp(1)
 
 dbp(3)
 
 lb()
 dbp(2)
 bp(8)
 
 lb()
 bp(8)
 
 lb()
 bp(8)
 dbp(1)
 turtle.placeDown()
 turtle.turnLeft()
 bp(1) 
 
 turtle.turnRight()
 turtle.turnRight()
 down()
 turtle.placeDown()
 fd(7)
 turtle.turnLeft()
 fd(1)
 turtle.turnLeft()
 turtle.select(stone3)
 fd(7)
 
 turtle.select(stone2)
 turtle.turnRight()
 up()
 for i = 1,4 do
  fd(8)
  turtle.turnRight()
  fd(1)
  turtle.turnRight()
  fd(7)
  if i < 4 then
   turtle.turnLeft()
   fd(1)
   turtle.turnLeft()
  end
 end
 
 turtle.select(stone3)
 up()
 up()
 turtle.turnRight()
 moveForward(3)
 turtle.turnRight()
 moveForward(2)
 turtle.select(dirt)
 fd(2)
 turtle.turnLeft()
 fd(1)
 turtle.turnLeft()
 fd(1)
 moveForward(7)
 
 turtle.select(stone1)
 turtle.placeDown()
 turtle.turnLeft()
 turtle.select(chest)
 turtle.place()
 turtle.select(sapling)
 turtle.drop()
 turtle.turnRight()
 turtle.select(chest)
 turtle.placeUp()
 turtle.select(bonemeal)
 turtle.dropUp()
 forward()
 turtle.select(chest)
 turtle.place()
 up()
 turtle.place()
 up()
 turtle.place()
 turtle.select(stone3)
 turtle.placeUp()
 
 down()
 down()
 down()
 turtle.turnRight()
 turtle.select(woodenpipe)
 turtle.place()
 turtle.turnLeft()
 down()
 turtle.select(furnace)
 turtle.placeUp()
 turtle.select(coal)
 turtle.dropUp(1)
 turtle.select(ironpipe)
 turtle.place()
 lb()
 turtle.select(pipe)
 turtle.place()
 turtle.turnLeft()
 back()
 turtle.select(goldpipe)
 turtle.place()
 up()
 up()
 turtle.select(chest)
 turtle.place()
 turtle.select(coal)
 turtle.drop(1)
 turtle.select(engine)
 turtle.placeDown()
 back()
 turtle.select(stone3)
 turtle.placeDown()
 lb()
 turtle.select(lever)
 turtle.place()
 back()
 turtle.turnRight()
 moveForward(2)
 down()
 turtle.select(pipe)
 turtle.place()
 down()
 turtle.place()
 down()
 moveForward(2)
 turtle.select(obsidianpipe)
 turtle.place()
 back()
 turtle.select(pipe)
 turtle.place()
 back()
 turtle.place()
 
 turtle.turnLeft()
 up()
 up()
 up()
 turtle.select(stone3)
 turtle.placeDown()
 forward()
 turtle.turnRight()
 turtle.turnRight()
 turtle.select(lever)
 turtle.place()
 turtle.turnRight()
 turtle.turnRight() 
 
 print("Finally set up farm! Enjoy!")
 print("Flip the lever for the redstone engine.")
 print("")
 print("Press Enter to get back into the menu!")
 read()
end

--MAIN EXPAND FUNCTIONS

local function checkBlocks()
 if turtle.getItemCount(blockslot) == 0 and blockslot < 10 then
  blockslot = blockslot + 1
  turtle.select(blockslot)
 end
end

local function checkFuelexpand()
 print("The refueling needs around 8 coal!")
 while turtle.getFuelLevel() < 600 do
  print("Refueling!")
  turtle.select(coal)
  turtle.refuel(1)
 end
end


local function fde(j)
 for i=1,j do
  checkBlocks()
  forward()
  turtle.placeDown()
  checkBlocks()
 end
end

local function df(j)
 for i=1,j do
  turtle.dig()
  forward()
 end
end

local function dfd(j)
 for i=1,j do
  turtle.dig()
  forward()
  turtle.digDown()
 end
end

local function destroy()
 turtle.turnRight()
 moveForward(3)
 down()
 down()
 down()
 turtle.turnRight()
 turtle.select(obsidianpipeexpand)
 turtle.dig()
 forward()
 turtle.turnRight()
 turtle.select(pipeexpand)
 turtle.dig()
 turtle.select(blockslot)
 forward()
 turtle.turnLeft()
 df(4)
 turtle.turnLeft()
 up()
 dfd(2)
 df(9)
 turtle.turnLeft()
 df(9)
 turtle.turnLeft()
 df(8)
 dfd(2)
 down()
 down()
 turtle.turnLeft()
 df(8)
 turtle.turnLeft()
 df(1)
 turtle.turnLeft()
 df(7)
 turtle.turnRight()
 turtle.up()
 for i=1,4 do
  df(8)
  turtle.turnRight()
  df(1)
  turtle.turnRight()
  df(8)
  if i < 4 then
   turtle.turnLeft()
   forward()
   turtle.turnLeft()
  end
 end
end

local function layout()
 turtle.select(blockslot)
 forward()
 up()
 up()
 up()
 forward()
 turtle.turnLeft()
 back()
 back()
 turtle.placeDown()
 fde(7)
 for i=1,3 do
  turtle.turnLeft()
  fde(7)
  forward()
  down()
  turtle.placeDown()
  fde(1)
  up()
  back()
  turtle.placeDown()
  fde(9)
 end
 turtle.turnLeft()
 fde(6)
 turtle.turnLeft()
 forward()
 turtle.turnRight()
 moveForward(10)
 turtle.turnLeft()
 moveForward(8)
end

local function corners()
 turtle.down()
 for i=1,4 do
  fde(7)
  turtle.turnLeft()
  fde(6)
  turtle.turnLeft()
  forward()
  turtle.turnLeft()
  fde(5)
  turtle.turnRight()
  fde(4)
  turtle.turnRight()
  forward()
  turtle.turnRight()
  fde(3)
  turtle.turnLeft()
  fde(2)
  turtle.back()
  turtle.turnLeft()
  fde(1)
  turtle.turnRight()
  turtle.turnRight()
  moveForward(3)
  turtle.turnLeft()
  moveForward(5)
 end
end

local function lines(j)
 fde(j)
 back()
 turtle.turnLeft()
 fde(1)
 turtle.turnLeft()
 fde(j-2)
 if j > 4 then
  back()
  turtle.turnRight()
  fde(1)
  turtle.turnRight()
  lines(j-4)
 end
end

local function plateau()
 down()
 back()
 turtle.placeDown()
 turtle.turnLeft()
 lines(15)
 turtle.turnLeft()
 moveForward(8)
 turtle.turnLeft()
 moveForward(8)
 turtle.turnRight()
 turtle.turnRight()
 turtle.placeDown()
 lines(15)
end

local function pipeAndDirt()
 back()
 turtle.turnLeft()
 moveForward(9)
 turtle.select(dirtexpand)
 turtle.digUp()
 forward()
 turtle.digUp()
 turtle.turnRight()
 forward()
 turtle.digUp()
 turtle.turnRight()
 forward()
 turtle.digUp()
 forward()
 turtle.placeUp()
 forward()
 turtle.placeUp()
 turtle.turnRight()
 forward()
 turtle.placeUp()
 turtle.turnRight()
 forward()
 turtle.placeUp()
 turtle.digDown()
 down()
 turtle.digDown()
 down()
 df(9)
 turtle.select(pipeexpand)
 for i=1,9 do
  back()
  turtle.place()
 end
 up()
 turtle.placeDown()
 up()
 turtle.placeDown()
 back()
 turtle.select(obsidianpipeexpand)
 turtle.place()
 turtle.turnRight()
 forward()
 turtle.turnLeft()
 moveForward(8)
 up()
 up()
 moveForward(3)
 turtle.turnRight()
end

--FWCexpand 66666666666666666666666666
function FWCexpand()
 print("Expanding farm!")
 checkFuelexpand()
 blockslot = 5
 destroy()
 layout()
 corners()
 plateau()
 pipeAndDirt()
 print("Finished!")
 print("Press Enter to get back into the menu!")
 read()
end

--FWChelp 77777777777777777777777777777777777777777

function FWChelp()
 print("Welcome to the UWC Help Interface!")
 print("If you have any question, suggestions, bugs or feedback, let me know: Type")
 print("computercraft forum ultimate wood chopper")
 print("in Google and write a post or PM at me ;D")
 read()
end

--FWCposition 999999999999999999999999999999999999

function FWCposition()
 turtle.select(coal)
 turtle.refuel(1)
 up()
 up()
 up()
 up()
 turtle.turnRight()
 forward()
 forward()
 forward()
 forward()
 turtle.turnLeft()
 forward()
 forward()
 print(" ")
 print("Turtle in Base. Ready to set up farm.")
 print("Be sure the turtle has all the materials it needs.")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCexpandchests

function FWCexpandchests()
 print("Adding more chests!")
 local amount = turtle.getItemCount(2)
 turtle.turnLeft()
 while not turtle.detectUp() do 
  turtle.up()
 end
 turtle.select(3)
 turtle.digUp()
 turtle.select(2)
 while amount > 0 do
  up()
  turtle.place()
  amount = amount-1
 end
 turtle.select(3)
 turtle.placeUp()
 while turtle.down() do end
 turtle.turnRight()
 print("Finsihed!")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCtwobytwo

function FWCtwobytwo()
 print("Chopping down 2x2 tree.")
 while turtle.getFuelLevel() < 200 do
  sleep(2)
  turtle.select(1)
  turtle.refuel(1)
  print("Refueled!")
 end
 cutWood()
 print("Press Enter to get back into the menu.")
 read()
end

--FWConebyone

function FWConebyone()
 print("Chopping down 1x1 tree.")
 while turtle.getFuelLevel() < 200 do
  sleep(2)
  turtle.select(1)
  turtle.refuel(1)
  print("Refueled!")
 end
 turtle.select(2)
 turtle.dig()
 forward()
 while turtle.compareUp() do
  turtle.digUp()
  up()
 end
 while not turtle.detectDown() do
  turtle.down()
 end
 print("Finsihed!")
 print("Press Enter to get back into the menu.")
 read()
end

--FWCdigSpace

function FWCdigSpace()
 os.sleep(2)
 turtle.select(1)
 turtle.refuel(5)
 back()
 back()
 turtle.turnLeft()
 forward()
 turtle.turnRight()
 turtle.digDown()
 turtle.down()
 turtle.digDown()
 turtle.down()
 for i=1,3 do
  for j=1,4 do
   turtle.forward()
   turtle.digUp()
   turtle.dig()
  end
  if i<3 then
   for j=1,4 do
    turtle.back()
   end
   turtle.turnRight()
   turtle.dig()
   turtle.forward()
   turtle.turnLeft()
  end
 end
 turtle.digDown()
 turtle.back()
 turtle.digDown()
 turtle.forward()
 turtle.up()
 turtle.up()
 turtle.turnLeft()
 moveForward(5)
 turtle.turnRight()
 turtle.forward()
 turtle.digDown()
 turtle.down()
 turtle.digDown()
 turtle.down()
 turtle.digDown()
 for i=1,5 do
  for j=1,11 do
   turtle.dig()
   turtle.forward()
   turtle.digUp()
   turtle.digDown()
  end
  turtle.turnRight()
  turtle.dig()
  turtle.forward()
  turtle.turnRight()
  turtle.digUp()
  turtle.digDown()
  for j=1,11 do
   turtle.dig()
   turtle.forward()
   turtle.digUp()
   turtle.digDown()   
  end
  if i < 5 then
   turtle.turnLeft()
   turtle.dig()
   turtle.forward()
   turtle.turnLeft()
   turtle.digDown()
   turtle.digUp()
  end
 end
 turtle.back()
 turtle.turnRight()
 turtle.forward()
 turtle.down()
 turtle.digDown()
 turtle.down()
 for i=1,8 do
  turtle.turnRight()
  turtle.dig()
  turtle.turnLeft()
  turtle.dig()
  turtle.forward()
 end
 turtle.turnLeft()
 turtle.up()
 turtle.up()
 turtle.up()
 turtle.up()
 turtle.turnLeft()
 moveForward(4)
 turtle.turnRight()
 moveForward(3)
 turtle.turnLeft()
 turtle.turnLeft()
 print("Finished!")
 print("Press Enter to get back into the menu!")
 read()
end


function UWCvariables()
 print("Welcome in the variable change menu.")
 print("You have the choice to individualise your farming turtle.")
 print("These variables are just used for the farm and get saved.")
 print("If you want to skip a variable and leave it where it is, you just have to press Enter.")
 print("Press Enter to continue...")
 read()
 clearScreen()
 print("There are different values:")
 print("Timer - The amount of seconds until something happens.")
 print("Amount - The amount of items.")
 print("Slot - A slot in the turtles inventory")
 print("Level - The Fuel Level")
 print("Height - The amount of blocks.")
 print("")
 print("Press Enter to continue...")
 read()
 clearScreen()
 local input = 0



 print("Timer")
 print("Turtle fails to take enough materials out of a chest.")
 print("How long does he waits until it tries again?")
 print("In this time the turtle can be terminated by the user.")
 print("Standard: 2")
 print("Minimum: 1")
 print("Current: " .. cancelTimer)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 1 then cancelTimer = input end
 end
 clearScreen()

 print("Set to: " .. cancelTimer)
 print("")
 print("Timer")
 print("Turtle fails to fertilize the tree with bonemeal.")
 print("How long should it wait until it tries again?")
 print("Standard: 120")
 print("Current: " .. bonemealTimer)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 then bonemealTimer = input end
 end
 clearScreen()
 
 print("Set to: " .. bonemealTimer)
 print("")
 print("Timer")
 print("Turtle planted the saplings.")
 print("How long should the turtle wait before fertilizing the first time?")
 print("Standard: 0")
 print("Current: " .. bonemealFirstDelay)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 then bonemealFirstDelay = input end
 end
 clearScreen()

 print("Set to: " .. bonemealFirstDelay)
 print("")
 print("Slot")
 print("Turtle goes back to base if the inventory slot has items in it.")
 print("Which slot should it be if the turtle uses bonemeal?")
 print("Standard: 14")
 print("Minimum: 3  Maximum: 16")
 print("Current: " .. amountMaxWoodSlotBonemeal)
 turtle.select(tonumber(amountMaxWoodSlotBonemeal))
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 3 and input <= 16 then amountMaxWoodSlotBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMaxWoodSlotBonemeal)
 print("")
 print("Slot")
 print("Turtle goes back to base if inventory slot has items in it.")
 print("Which slot should it be if the turtle doesnt use bonemeal?")
 print("Standard: 7")
 print("Minimum: 2  Maximum: 16")
 print("Current: " .. amountMaxWoodSlotNoBonemeal)
 turtle.select(tonumber(amountMaxWoodSlotNoBonemeal))
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 2 and input <= 16 then amountMaxWoodSlotNoBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMaxWoodSlotNoBonemeal)
 print("")
 print("Amount")
 print("Turtle needs this amount or more bonemeal in slot 2 before keep going.")
 print("Standard: 8")
 print("Minimum: 3 Maximum: 64")
 print("Current: " .. amountMinBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 2 and input < 65 then amountMinBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountMinBonemeal)
 print("")
 print("Amount")
 print("Turtle needs this amount or more saplings in slot 1 before keep going.")
 print("Standard: 17")
 print("Minimum: 4 Maximum: 64")
 print("Current: " .. amountMinSaplings)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 3 and input < 65 then amountMinSaplings = input end
 end
 clearScreen()

 print("Set to: " .. amountMinSaplings)
 print("")
 print("Level")
 print("Turtle checks if it needs more fuel before planting and chopping down the next tree.")
 print("Standard: 200")
 print("Minimum: 150 Maximum: 1000")
 print("Current: " .. amountMinFuelLevel)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 149 and input < 1001 then amountMinFuelLevel = input end
 end
 clearScreen()

 print("Set to: " .. amountMinFuelLevel)
 print("")
 print("Amount")
 print("After chopping down trees, the turtle places some wood into the furnace.")
 print("How many wood should be put into the furnace if bonemeal is used?")
 print("Standard: 16")
 print("Minimum: 0  Maximum: 64")
 print("Current: " .. amountFurnaceWoodBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 and input < 65 then amountFurnaceWoodBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountFurnaceWoodBonemeal)
 print("")
 print("Amount")
 print("After chopping down trees, the turtle places some wood into the furnace.")
 print("How many wood should be put into the furnace if no bonemeal is used?")
 print("Standard: 8")
 print("Minimum: 0  Maximum: 64")
 print("Current: " .. amountFurnaceWoodNoBonemeal)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input >= 0 and input < 65 then amountFurnaceWoodNoBonemeal = input end
 end
 clearScreen()

 print("Set to: " .. amountFurnaceWoodNoBonemeal)
 print("")
 print("Height")
 print("If the turtle debugs the farm, it checks how height it is.")
 print("It turns back down if it didnt it anything.")
 print("At which height should it turn back down.")
 print("Standard: 55")
 print("Minimum: 1  Maximum: 200")
 print("Current: " .. debugMaxHeight)
 input = tonumber(read())
 if input then
  input = math.floor(input)
  if input > 0 and input < 201 then debugMaxHeight = input end
 end
 clearScreen()

 print("Set to: " ..debugMaxHeight)
 print("")
 print("Saving variables...")
 saveVariables()
 print("Saved variables!")
 sleep(0.5)
end

function UWCgodown()
 while not turtle.detectDown() do
  turtle.down()
 end
end

function control()
 local blockslot = 1
 local mode = "move"
 local working = true
 turtle.select(blockslot)

 function info()
  clearScreen()
  print("Navigate your turtle with your keyboard.")
  print("W A S D --- Horizontal")
  print("Space SHIFT --- Vertical")
  print("E --- Switch between dig mode/ place mode/ move mode")
  print("Q --- Select next slot")
  print("Strg --- Leave the conrol interface.")
  print("")
  print("Turtle Mode: " .. mode)
 end

 while working do
  info()
  local id, key = os.pullEvent("key")
  if key == 29 then
   working = false
  elseif key == 16 then
   blockslot = blockslot + 1
   if blockslot == 17 then
    blockslot = 1
   end
   turtle.select(blockslot)
  elseif key == 30 then
   turtle.turnLeft()
  elseif key == 31 then
   turtle.back()
  elseif key == 32 then
   turtle.turnRight()

  elseif mode == "move" then
   if key == 17 then
    turtle.forward()
   elseif key == 57 then
    turtle.up()
   elseif key == 42 then
    turtle.down()
   elseif key == 18 then
    mode = "dig"
   end

  elseif mode == "dig" then
   if key == 17 then
    turtle.dig()
   elseif key == 57 then
    turtle.digUp()
   elseif key == 42 then
    turtle.digDown()
   elseif key == 18 then
    mode = "place"
   end

  elseif mode == "place" then
   if key == 17 then
    turtle.place()
   elseif key == 57 then
    turtle.placeUp()
   elseif key == 42 then
    turtle.placeDown()
   elseif key == 18 then
    mode = "move"
   end
  end
 end
end


--MAIN PROGRAM

while running == true do
 runMenu()
end