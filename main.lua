-- Parker Lanum
-- CMPM 121 - Solitaire, but better
-- 5/7/25

io.stdout:setvbuf("no")

require "card"
require "grabber"

math.randomseed(os.time())

function love.load()
  love.window.setMode(1280,720)
  love.graphics.setBackgroundColor(0, 0.7, 0.2, 1)
  
  deckImage = love.graphics.newImage("Sprites/deck.png")
  backImage = love.graphics.newImage("Sprites/back.png")
  
  spadeImage = love.graphics.newImage("Sprites/spade.png")
  clubImage = love.graphics.newImage("Sprites/club.png")
  heartImage = love.graphics.newImage("Sprites/heart.png")
  diamondImage = love.graphics.newImage("Sprites/diamond.png")
  
  spadeFrame = love.graphics.newImage("Sprites/spadeframe.png")
  clubFrame = love.graphics.newImage("Sprites/clubframe.png")
  heartFrame = love.graphics.newImage("Sprites/heartframe.png")
  diamondFrame = love.graphics.newImage("Sprites/diamondframe.png")  
  suits = {spadeImage, clubImage, heartImage, diamondImage}
  
  resetImage = love.graphics.newImage("Sprites/reset.png") 
        
  cardTable = {}
  grabber = GrabberClass:new()
  
  tablaeuCoords = { 
    Vector(240, 100),
    Vector(360, 100),
    Vector(480, 100),
    Vector(600, 100),
    Vector(720, 100),
    Vector(840, 100),
    Vector(960, 100)
  }
  
  foundationCoords = {
    Vector(1120, 100),
    Vector(1120, 250),
    Vector(1120, 400),
    Vector(1120, 550)
  }
  
  --Create Deck
  for val=1,13 do
    for suit=1,4 do
      table.insert(cardTable, CardClass:new(-260, 100, val, suit, true))
    end
  end
  
  --Fisher-Yates shuffle from lecture notes
  local cardCount = 52
	for i = 1, cardCount do
		local randIndex = math.random(cardCount)
    local temp = cardTable[randIndex]
    cardTable[randIndex] = cardTable[cardCount]
    cardTable[cardCount] = temp
    cardCount = cardCount - 1
	end
  
  --move first cards to tablaeu
  tempIndex = 0
  for i=0,6 do
    for j=0,i do
      tempIndex = tempIndex +1
      cardTable[tempIndex].position.x = 240+(i*120)
      cardTable[tempIndex].position.y = 100+(j*45)
      cardTable[tempIndex].location = CARD_LOCATION.TABLAEU
      if i~=j then cardTable[tempIndex].shown=false end
    end
  end
  tempIndex=1

  --Move the rest of the cards to drawing deck
  deck = {}
  for i = 29, 52 do
    deck[#deck + 1] = cardTable[i]
  end

end

function love.update()
  grabber:update()
  
  checkForMouseMoving()

    
  --update backwards to give topmost cards priority
  for i = #cardTable, 1, -1 do
    local card = cardTable[i]
    card:update()
  end
  
  --check if the player has won
  won = true
  for i = 1, #cardTable do
    if cardTable[i].location ~= CARD_LOCATION.SOLVED then
     won = false
      break
    end
  end

  
  for index, card in ipairs(cardTable) do
    --grabbing a card brings it to top via draw order
    if card.state == CARD_STATE.GRABBED then
      table.remove(cardTable, index)
      table.insert(cardTable, card)
    end
  end
end

--when the player clicks the deck or reset button
function love.mousepressed(x, y, button, istouch, presses)
  if button == 1 then
    if x > 30 and x < 190 and y > 530 and y < 690 then
      love.load()
    end
    if x > 60 and x < 160 and y > 100 and y < 240 then
      for _, card in ipairs(deck) do
        card.position.x = -200
      end
      local lap = 2
      --use a max to simplify
      if #deck - tempIndex < 0 then
        tempIndex = 1
      end
      
      if tempIndex+3 > #deck then
        lap = #deck - tempIndex
      end
      
      for i=0,lap do
        deck[tempIndex].position.x = 60
        deck[tempIndex].position.y = 300+(40*i)
        deck[tempIndex].shown = true
        tempIndex=tempIndex+1
      end
    end
  end
end

function checkForMouseMoving()
  if grabber.currMousePos == nil then
    return
  end
  
  for _, card in ipairs(cardTable) do
    card:checkHover(grabber)
  end
end


rulesFont = love.graphics.newFont(20)
winFont = love.graphics.newFont(160)

function love.draw()
  love.graphics.setFont(rulesFont)
  love.graphics.printf("Click and drag cards from the tableau to the four rightmost piles in ascending order in suit from Ace to King. Cards in the tableau can be moved to each other if they are one rank lower and of the opposite color.  New cards can be drawn from the deck on the left, but only take topmost cards that can be used.", 10,10, 1260, "center")
  
  love.graphics.setColor(1,1,1,1)
  love.graphics.draw(deckImage, 60, 95)
  
  --faint suit frames on right
  love.graphics.setColor(1,1,1,0.4)
  love.graphics.draw(spadeFrame, foundationCoords[1].x, foundationCoords[1].y)
  love.graphics.draw(clubFrame, foundationCoords[2].x, foundationCoords[2].y)
  love.graphics.draw(heartFrame, foundationCoords[3].x, foundationCoords[3].y)
  love.graphics.draw(diamondFrame, foundationCoords[4].x, foundationCoords[4].y)
  
  love.graphics.setColor(1,1,1,0.8)
  love.graphics.draw(resetImage, 30, 530, 0, 0.8, 0.8)
  
  love.graphics.setColor(1,1,1,1)
  for _, card in ipairs(cardTable) do
    card:draw()
  end
  
  if won then
    love.graphics.setFont(winFont)
    love.graphics.setColor(0,0,0,1)
    love.graphics.printf("You Win!", 40, 300, 1260, "center")
  end
end