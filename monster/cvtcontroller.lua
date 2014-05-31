-- Control the CVTs that drive the extractor input
-- CVT #3 (left) at 32xSpeed with signal, 16xSpeed w/o
-- CVT #2 (back) at 16xSpeed with signal, 1xSpeed w/o
-- CVT #1 (right) at 16xSpeed with signal, 1xSpeed w/o

while true do
  -- Configure for first stage
  redstone.setOutput("left", false)
  redstone.setOutput("right", false)
  redstone.setOutput("back", false)
  sleep(2)

  -- Configure for second and third stages
  redstone.setOutput("left", true)
  redstone.setOutput("right", true)
  redstone.setOutput("back", true)
  sleep(2)

  -- Configure for fourth stage
  redstone.setOutput("left", true)
  redstone.setOutput("right", false)
  redstone.setOutput("back", false)
  sleep(2)
end
