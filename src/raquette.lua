require("constants")
local frameRounded

-- raquette
local raquette = {}
raquette.nbframes = 3
raquette.img = nil
raquette.frames = {}
raquette.x = 0            -- coordonnées x et y de la raquette
raquette.y = 0
raquette.oldx = 0         -- ancienne coordonnée du pad (sert pour l'affichage ou non des etoiles)
raquette.width = nil
raquette.height = nil
raquette.frame = 1 -- frame en cours
raquette.framespeed = PAD_FSPEED -- vitesse anim raquette
raquette.zoomlg = ZOOM_FACTOR_PAD  -- zoom x de la raquette au départ
raquette.growing = 0               -- vaut -1 , 0 ou 1   permet de dire si la raquette rétrécit, est normale,  ou grandit 


-- charge les images de la raquette
function raquette.load(racketFile, nbframes)
  local img=love.graphics.newImage(racketFile)
  local frame = {}
  for i=1, nbframes do
    frame[i]=love.graphics.newQuad((i-1) * img:getWidth() / nbframes, 0, img:getWidth() / nbframes, img:getHeight(), img:getWidth(), img:getHeight())
  end
  return img, frame
  
end


-- update animation de la raquette et position
function raquette.update(frame, speed, dt)
   ---  update pos raquette
   raquette.oldx = raquette.x 
   raquette.x = love.mouse.getX()
   local tmpx = (raquette.width / 2) * raquette.zoomlg
  
  -- v 0.46 ---------------------------------------
   if raquette.x >  largeur - tmpx then
       raquette.x = largeur - tmpx
       love.mouse.setX(raquette.x)
   elseif raquette.x < tmpx then
      raquette.x = tmpx
      love.mouse.setX(raquette.x)
   end
   ---------  anim raquette 
   frameRounded=math.floor(raquette.frame)
   frame=frame + speed * dt
   if frame >= #raquette.frames then
     frame = 1
   end
   return frame
end

-- dessine la raquette
function raquette.draw()
  -- debug
  --print("frameRounded : "..tostring(frameRounded))
  --print("raquette.frames[frameRounded] : "..tostring(raquette.frames[frameRounded]))
  -- fin debug
    love.graphics.draw(raquette.img, raquette.frames[frameRounded],raquette.x,raquette.y,0, ZOOM_FACTOR * raquette.zoomlg, ZOOM_FACTOR, raquette.width / 2, raquette.height / 2)
end



---    le 12/11/18  fonction non encore testée
--  appelée en cas de bonus ou malus qui tombe 
--
--  permet de diminuer ou d'augmenter la taille de la raquette progressivement
--  retourne un booleen permettant de dire si l'operation d'augmentation
--  ou de diminution est finie ou non
--  param1 : plus, minus ou normal
--  param2 : une vitesse d'augmentation ou de diminution mettre une valeur enttre 0.5 et 3 3=plus rapide
--  param3 : le delta time
--  param4 : le parmetre raquette   a transmette
--  retour :  indique si l'augmentation ou la diminution est terminée

function raquette.AlterWidth(meaning, speed, dt)
  -- augmente progressivement la taille de la raquette
   local alterfinished = false
   if meaning == "plus" then
     raquette.growing = 1 
     raquette.zoomlg = raquette.zoomlg + (dt * speed * raquette.growing)
     if raquette.zoomlg > ZOOM_FACTOR_MAX_X_PAD then
       raquette.zoomlg = ZOOM_FACTOR_MAX_X_PAD
       alterfinished = true
     end
  -- diminue progressivement la taille de la raquette   
  elseif meaning == "minus" then
     raquette.growing = -1
     raquette.zoomlg = raquette.zoomlg + (dt * speed * raquette.growing)
     if raquette.zoomlg < ZOOM_FACTOR_MIN_X_PAD then
       raquette.zoomlg = ZOOM_FACTOR_MIN_X_PAD
       alterfinished = true
     end
  -- permet de retourner a la taille normale de la raquette progressivement
  -- 
  elseif meaning == "normal" then
     raquette.zoomlg = raquette.zoomlg - (dt * speed * raquette.growing)
     if raquette.growing == 1 then
        if raquette.zoomlg <= ZOOM_FACTOR_PAD then
          raquette.zoomlg = ZOOM_FACTOR_PAD
          alterfinished = true
          raquette.growing = 0
        end
     elseif raquette.growing == -1 then
        if raquette.zoomlg >= ZOOM_FACTOR_PAD then
          raquette.zoomlg = ZOOM_FACTOR_PAD
          alterfinished = true
          raquette.growing = 0
        end
     else --refpad.growing = 0 
         alterfinished=true
     end
     
       
  end
  return alterfinished

end

-- v0.46
function raquette.init()
   love.mouse.setX(largeur / 2 - raquette.width / 2)
   raquette.x = love.mouse.getX()
   raquette.y = hauteur - raquette.height 
   raquette.zoomlg = ZOOM_FACTOR_PAD
   raquette.growing = 0 
end



-- retourne la raquette
--return raquette, stars
return raquette

