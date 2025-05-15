
require "vector"

CardClass = {}

CARD_STATE = {
  IDLE = 0,
  HOVER = 1,
  HELD = 2
}

CARD_LOCATION = {
  DECK = 0,
  TABLAEU = 1,
  SOLVED = 2
}


function CardClass:new(xPos, yPos, value, suit, shown)
  local card = {}
  local metadata = {__index = CardClass}
  setmetatable(card, metadata)
  
  card.position = Vector(xPos, yPos)
  card.originalPosition = Vector(xPos, yPos)
  card.size = Vector(100, 140)
  card.state = CARD_STATE.IDLE
  card.location = CARD_LOCATION.DECK
  
  card.value = value
  card.suit = suit
  card.shown = shown
  
  return card
end

grabby = false
function CardClass:update()
  
  --grab a card when clicked
  if self.state == CARD_STATE.HOVER and love.mouse.isDown(1) and grabby == false and self.location ~= CARD_LOCATION.SOLVED and self.shown then
    self.state = CARD_STATE.GRABBED
    grabby = true
    self.originalPosition = Vector(self.position.x, self.position.y)
  end
  
  --when grabbed move card with mouse
  if self.state == CARD_STATE.GRABBED and love.mouse.isDown(1) then
    local mousePos = grabber.currMousePos
    self.position.x = mousePos.x-50
    self.position.y = mousePos.y-70
  end
  
  --when mouse is released drop card
  if self.state == CARD_STATE.GRABBED and not love.mouse.isDown(1) then
    local dropSuccess = false

    --loop through all cards to see if we dropped onto a valid target
    for _, other in ipairs(cardTable) do
      if other ~= self then
        local mousePos = grabber.currMousePos
        --the bounds of another card
        local isOver =
  self.position.x + self.size.x > other.position.x and
  self.position.x < other.position.x + other.size.x and
  self.position.y + self.size.y > other.position.y and
  self.position.y < other.position.y + other.size.y

        if isOver and self:allowDrop(other) then
          --snap below the card
          self.position.x = other.position.x
          if other.location == CARD_LOCATION.SOLVED then
            self.position.y = other.position.y  --no offset if in foundation
          else
            self.position.y = other.position.y + 45 --vertical offset if in tableau
          end
          self.location = other.location
          dropSuccess = true
          break
        end
      end
    end

    --kings can go in empty space at top of tablaeu
    if not dropSuccess and self.value == 13 then
      local mousePos = grabber.currMousePos
      for _, spot in ipairs(tablaeuCoords) do
        if mousePos.x > spot.x and mousePos.x < spot.x + self.size.x and
           mousePos.y > spot.y and mousePos.y < spot.y + self.size.y then
          self.position.x = spot.x
          self.position.y = spot.y
          self.location = CARD_LOCATION.TABLAEU
          dropSuccess = true
          break
        end
      end
    end

    --aces can go in empty space in foundation
    if not dropSuccess and self.value == 1 then
      local mousePos = grabber.currMousePos
      for i, spot in ipairs(foundationCoords) do
        if mousePos.x > spot.x and mousePos.x < spot.x + self.size.x and
           mousePos.y > spot.y and mousePos.y < spot.y + self.size.y and 
           self.suit==i then
          self.position.x = spot.x
          self.position.y = spot.y
          self.location = CARD_LOCATION.SOLVED
          dropSuccess = true
          break
        end
      end
    end
    
    --when a card moves reveal the card above it
    if dropSuccess then
      local oldX = self.originalPosition.x
      local oldY = self.originalPosition.y

      local highestCard = nil
      local highestY = 0

      --if a higher card is found it becomes the highest card and its y becomes highest y
      for _, card in ipairs(cardTable) do
        if card.position.x == oldX and card.position.y < oldY then
          if card.position.y > highestY then
            highestY = card.position.y
            highestCard = card
          end
        end
      end

      --reveal highest card
      if highestCard then
        highestCard.shown = true
      end
    end

    if not dropSuccess then
      --return to original position
      self.position = Vector(self.originalPosition.x, self.originalPosition.y)
    else
      if self.location ~= CARD_LOCATION.DECK then
        for i, card in ipairs(deck) do
          if card == self then
            table.remove(deck, i)
            break
          end
        end
      end
    end

    self.state = CARD_STATE.HOVER
    grabby = false
  end
  
end

local values = {'A','2','3','4','5','6','7','8','9','10','J','Q','K',}
suits = {} --this is filled in love.load()
cardFont = love.graphics.newFont(30)

function CardClass:draw()
  if self.shown then
    local white = {1,1,1,1}
    local red = {1,0,0,1}
    local black = {0,0,0,1}

    --print card background
    love.graphics.setColor(white)
    love.graphics.rectangle("fill", self.position.x, self.position.y, self.size.x, self.size.y, 6, 6)
  
    --print card value
    love.graphics.setColor(self.suit < 3 and black or red)
    love.graphics.setFont(cardFont)
    love.graphics.printf(values[self.value], self.position.x, self.position.y+5, 50, "center")
    
    --print card suit
    love.graphics.setColor(white)
    love.graphics.draw(suits[self.suit], self.position.x+10, self.position.y+50)
    love.graphics.draw(suits[self.suit], self.position.x+55, self.position.y+8, 0, 0.4, 0.4)
    
  else
    --draw the back of a card
    love.graphics.draw(backImage, self.position.x, self.position.y)
  end
end

function CardClass:checkHover(grabber)
  if self.state == CARD_STATE.GRABBED then
    return
  end
  
  local mousePos = grabber.currMousePos
  local isMouseOver = 
    mousePos.x > self.position.x and mousePos.x < self.position.x+self.size.x and
    mousePos.y > self.position.y and mousePos.y < self.position.y+self.size.y
    
  self.state = isMouseOver and CARD_STATE.HOVER or CARD_STATE.IDLE

end

--basic helper function to avoid confusion
function CardClass:getColor()
    if self.suit < 3 then
    return "black"
  else
    return "red"
  end
end

function CardClass:allowDrop(target)
  --do not proceed if the card doesnt exist or is flipped
  if not target or not target.shown then return false end

  --in the tablaeu, return true if colors are opposite and values are descending
  if target.location == CARD_LOCATION.TABLAEU then
    return self:getColor() ~= target:getColor() and self.value == target.value - 1
  end

  --in the foundation, return suits match and values are ascending
  if target.location == CARD_LOCATION.SOLVED then
    return self.suit == target.suit and self.value == target.value + 1
  end

  --else return false
  return false
end