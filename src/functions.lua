require("constants")

levelencours = nil


-- background
background = {}
background.img = nil           -- pour les levels
background.width = nil
background.height = nil
background.sx = nil
background.sy = nil


-- levels --------------------------------------------------

 -- les chiffres nuls sont des "trous" de RATIO_BRICK_STD_LG_BRICK_INTERVAL * BRICK_INTERVAL en largeur  
 -- 0, -1, -2 .. etc est la même chose et signifie "un" trou  
levels = {} 
levels = {
                -- level 1
               { 0, 2, 2, 0, 2, 2, 2, 0, 2, 2, 0, 2, 2, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 1, 0, 1, 1, 0, 1, 1, 0 
                
                 
               },
               -- level 2
               {1, 2, 2, 3, 0, 0, 3, 2, 2, 1, 
                1, 2, 2, 0, 0, 0, 0, 2, 2, 1,
                2, 2, 2, 0, 0, 0, 0, 2, 2, 1,
                2, 2, 2, 2, 0, 3, 0, 2, 2, 1,
                2, 2, 2, 2, 5, 0, 5, 0, 5, 1, 2, 2, 1,
                2, 2, 2, 1, 1, 1, 1, 2, 2, 2,
                1, 1, 1, 1, 0, 2, 0, 1, 1, 1,
                1, 1, 1, 1, 0, 2, 0, 1, 1, 1,
                1, 1, 1, 1, 0, 1, 0, 1, 1, 1,
                1, 1, 1, 1, 1, 1, 1, 1, 5, 5
               },
               -- level 3
                {0, 3, 3, 3, 3, 3, 0, 0, 3, 3, 3, 2, 2, 0, 
                 0, 1, 1, 3, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 
                 2, 1, 1, 0, 1, 2, 0, 0, 3, 1, 0, 1, 1, 2, 
                 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0, 
                 0, 1, 1, 0, 1, 1, 0, 0, 1, 1, 0, 1, 1, 0,
                 0, 0, 0, 0, 0, 2, 2, 3, 2, 2, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 2, 2, 2, 2, 2, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 1, 1, 1, 1, 1, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 1, 1, 1, 0, 0, 0, 0, 0,
                 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0
                 
               }
           
           }


--  param : 1 nom de fichier
--  retourn une texture / les dimensions de l'image
function getImageParams(filename)
  local img=love.graphics.newImage(filename)
  return img, img:getDimensions()
end

-- obtenir une echelle
function getImageScale(img, wscreen, hscreen)
   local w, h = img:getDimensions()
   return wscreen / w, hscreen / h
end

-- fonction utilitaire retournant une table de width .. height trié
function getFSModes()
  local modes = love.window.getFullscreenModes()
  table.sort(modes, function(a, b) return a.width * a.height < b.width * b.height end) 
  return modes
end

-- permet de basculer d'une resolution a une autre et d'un mode fenetré à fullscreen
function setMode(resx, resy, switch)
  return love.window.setMode(resx, resy, {fullscreen = switch, vsync=true, fullscreentype= "exclusive" })
end

function drawfps(txt, x, y, font)
  if font ~= nil then
      love.graphics.setFont(font)
  end
  love.graphics.print(txt..tostring(love.timer.getFPS()), x, y)
end

function drawtxt(txt, x, y)
  love.graphics.print(tostring(txt), x, y)
end

--- permet de convertir un booleen à 0 ou 1,
-- autre type sera la valeur entrée
function boolToNumber(value)
  if type(value) == "boolean" then
      return value and 1 or 0
  else
      return value
  end
end

function drawElementsLevel(refpad, refstars, refbricks, refball, font)
  refpad.draw()
  refstars.draw(refpad, "alternate")
  refball.draw(nil)
  refbricks.draw(refbricks)
  love.graphics.setColor(0.27, 0.48, 0.6, 1)
  -- show fps 
  drawfps("FPS : ", 0, 0, font)
end
  
function drawStartLevel(txt, font)
  local w, h
  love.graphics.setFont(font)
  w = font:getWidth(txt) 
  h = font:getHeight(txt)  
  love.graphics.setColor(0.27, 0.48, 0.55,1)
  love.graphics.print(txt,largeur / 2 - w / 2 , hauteur / 2 - h /2)
  love.graphics.setColor(1,1,1,1)
end

-- convertit un angle donné en degrés en sa valeur > 0
function NormalizeAngle(angle)
   return (angle + 360) % 360
end

-- convertit un angle de degrés en radians
-- param  : un angle en degres
-- retour : un angle en radians
--
function DegresToRadians(angle)
  --local tmpangle = (angle + 360) % 360  -- pour avoir un nombre positif
  local tmpangle = NormalizeAngle(angle)
  return tmpangle * math.pi / 180  
end

function getAngle(vx, vy)
     return math.atan2(vy, vx)
end

