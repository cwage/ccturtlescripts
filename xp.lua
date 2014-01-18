--  Direwolf20 Turtle Powered Book Enchanting

--  Chest with Books In front of Turtle

m = peripheral.wrap("left")
m.setAutoCollect(true)
local currLevel = 0

function enchantBook()
  turtle.select(1)
  turtle.suck()
  turtle.drop(turtle.getItemCount(1)-1)
  m.enchant(30)
  turtle.drop()
end

--  Main Program

while true do
  currLevel = m.getLevels()
  print("Currently Level: "..currLevel)
  if currLevel >=30 then
    enchantBook()
  else
    sleep(10)
  end
end