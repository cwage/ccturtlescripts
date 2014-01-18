local bEnd = false;

print( "press <SPACE> to stop attacking." )

parallel.waitForAny(
function()
  while not bEnd do
   local event, key = os.pullEvent("key");
   if key ~= 1 then
        bEnd = true;
        print("Aborting...");
   end
  end
end,
function()
  while not bEnd do
   turtle.attack()
   turtle.suck()
   sleep(0.25)
   turtle.select(1)
  end
end
)