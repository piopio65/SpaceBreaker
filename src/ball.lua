require("constants")

-- debug
-- speedball           = 0
---------------------------------
local balle         = {}
balle.colle         = true                       -- indique si la balle est collée à la raquette
balle.img           = nil    
balle.x             = nil                        -- coordonnées x et y de la balle
balle.y             = nil
balle.speed         = BALL_SPEED                 -- vitesse balle en pixels / s
balle.vx            = nil                        -- vitesse instantanée de la balle en x 
balle.vy            = nil                        -- vitesse instantanée de la balle en y
balle.angle         = BALL_START_ANGLE           -- angle de départ de la balle en degrés
balle.collidepad    = true                       -- indique si la balle vient de toucher le pad
balle.width         = nil                        -- largeur sprite balle
balle.height        = nil                        -- hauteur sprite balle  
balle.rayon         = nil                        -- rayon balle
balle.speedrotation = BALL_ROTATE_SPEED          -- vitesse de rotation de la balle
balle.anglerotation = nil                        -- angle de rotation de départ de la balle

-- pour debug, permet de figer la balle sur appui de w
balle.wait=false


function balle.load(fic)
  balle.img, balle.width, balle.height = getImageParams(fic)
  balle.rayon=balle.width / 2
end


function balle.update(dt, refbricks, refracket)
   local soundtoplay, ret = nil
   local init = false
      
   if balle.colle then
      balle.setStartXY(refracket) 
   else -- balle lancée
      soundtoplay, _ = TestCollide(refbricks, refracket)
      -- 
      if balle.collidepad then -- si la balle rebondit (lors du toucher du pad, on change 
                               -- l'orientation selon l'angle calculée dans balle.testcollide 
        --soundtoplay = PAD
        balle.collidepad = false
        ---- v0.44 on va detecter si la balle est plus bas que le pad (ok)
        if balle.y < refracket.y then 
            balle.vx = balle.speed * math.cos((balle.angle / 180) * math.pi) * dt
            balle.vy = balle.speed * math.sin((balle.angle / 180) * math.pi) * dt
        else
            -- on change de direction
            balle.vx = -balle.vx
            
        end
        
      end
      
      --- dans les 4 tests qui suivent , on considere qu'il n'y a pas de rebond --------
      if (balle.x + balle.rayon) > largeur  then
         balle.x = largeur - balle.rayon
         balle.vx = -balle.vx
      elseif (balle.x - balle.rayon) < 0 then
        balle.x = balle.rayon 
        balle.vx = -balle.vx
      end
      
      if (balle.y - balle.rayon) < 0 then
        balle.y = balle.rayon
        balle.vy = -balle.vy
      elseif (balle.y - 4 * balle.rayon) > hauteur then -- sortie par le bas de l'ecran
        soundtoplay = BALL_LOST
        init = true
      end
      ----------------------------------------------------------------------------------
      -- mise à jour de la rotation de la balle en fonction du sens de déplacement sur x
      local delta_angle = BALL_ROTATE_SPEED * dt * math.cos(getAngle(balle.vx, balle.vy))
      balle.anglerotation = NormalizeAngle(balle.anglerotation + delta_angle)    
      
      --  deplacement de la balle 
      balle.x = balle.x + balle.vx
      balle.y = balle.y + balle.vy
      --
      
      
     
   end -- fin balle lancée
   return soundtoplay, init   -- on retourne le son a jouer
   
end

-- permet d'afficher la balle
-- parametre 1 : sera utilisé dans une version > pour plusieurs balles à l'écran

function balle.draw(numball)
    love.graphics.draw(balle.img, balle.x, balle.y, DegresToRadians(balle.anglerotation), ZOOM_FACTOR, ZOOM_FACTOR, balle.rayon, balle.rayon)
end

-- init balle a chaque lancement
function balle.init(refpad)
  balle.colle = true
  balle.collidepad = true
  balle.vx = 0
  balle.vy = 0
  balle.setStartXY(refpad)
  balle.angle = BALL_START_ANGLE
  balle.anglerotation = BALL_START_ANGLE
  -- v0.46
  refpad.init()
  
end
--- permet de placer la balle aux coordonnées de la raquette
function balle.setStartXY(refpad)
      balle.x = refpad.x
      balle.y = refpad.y - refpad.height/ 2 - balle.height / 2
end

-- parametre : bricks, raquette
function TestCollide(refbricks, refracket)
  -- on va retourner le son a jouer
  --local retcol = nil
  local ret = nil
  local soundtoplay = nil
    ------- zone du pad ---------------------------- 
  if balle.y > (hauteur * RATIO_SEP_SCREEN) then  
     -- attention en test decommentez ici si ko
     -- if balle.vy > 0 then -- la direction de la balle doit se situer vers le bas
        --retcol, hypotenuse = IsBallCollideWith("pad", refracket) 
        -- ret vaudra ici true ou false
        ret, hypotenuse = IsBallCollideWith("pad", refracket) 
        if ret then
            --if retcol then
            balle.collidepad = true
            soundtoplay = PAD
            -- on calcule la distance x entre la balle et le pad
            -- ceci donne un resultat pas mal du tout
            balle.angle = BALL_VERTICAL_ANGLE +  (2 * (balle.x - refracket.x) / (refracket.width * refracket.zoomlg)) * BALL_MAX_DELTA_ANGLE
            if (balle.angle > (BALL_VERTICAL_ANGLE + BALL_MAX_DELTA_ANGLE)) then
              balle.angle = BALL_VERTICAL_ANGLE + BALL_MAX_DELTA_ANGLE
            elseif (balle.angle < (BALL_VERTICAL_ANGLE - BALL_MAX_DELTA_ANGLE)) then
              balle.angle = BALL_VERTICAL_ANGLE - BALL_MAX_DELTA_ANGLE
            end
            -- print ("angle apres correction : "..balle.angle) 
        end -- fin collision balle / pad
     -- fin test a decommenter si KO
     -- end 
    
    -- test collision avec les briques
  else  ------ collision avec 1 brique
          local ind=0
          local coll=false
          while ind < refbricks.total and not coll do
            ind=ind + 1
            if refbricks.visible[ind] then 
               --local ret, dstx, dsty = IsBallCollideWith("brick", refbricks, ind)
               local dstx, dsty
               ret, dstx, dsty = IsBallCollideWith("brick", refbricks, ind)
               if ret > 0 then -- collision
                    refbricks.resistance[ind] = refbricks.resistance[ind] - 1
                    -- ici il faudra ajouter l'ajout d'un score
                    -- son a jouer
                    soundtoplay = BRICK_NORMAL
                    ------------------------------------------------------------------
                    if refbricks.resistance[ind] <= refbricks.bresist[ind] then
                      soundtoplay = BRICK_BROKEN
                      refbricks.img[ind] = refbricks.imgbroken[ind]
                    end
                    if refbricks.resistance[ind] == 0 then
                       refbricks.visible[ind] = false
                       if math.random(1, 10) <= 5 then
                         soundtoplay = BRICK_DESTROYED 
                       else
                         soundtoplay = BRICK_DESTROYED_2 
                       end
                     
                    end
                    -----------------------------------------------------------------
                    if ret == 1 then
                       balle.vy = -balle.vy
                    elseif ret == 2 then
                      balle.vx = -balle.vx
                    else  --- retour dans 1 coin
                       -- v0.47
                        if math.random(1,10) <= 5 then                      
                               balle.vx = -balle.vx
                        else
                               balle.vy = -balle.vy
                        end
                        
                    end
                    coll = true  -- on sort de la boucle des qu'on a heurté une brique
               end -- fin ret > 0
            end  -- fin bricks.visible
          
          end  -- fin while
    
  end -- fin collision brique
 return soundtoplay, ret
end

--[[function getNewVxVy(startAngle, vx, vy, valueDecInDegrees, min, max)
  -- print("angle avant changement .: "..startAngle)
  local angle = startAngle + math.random(min,max) + valueDecInDegrees
  angle = (angle + 360) % 360   -- nombre toujours positif entre 0 et 359
  --local angle = startAngle + valueDecInDegrees
  -- print("angle apres changement  : "..angle)
  local vect=math.sqrt((vx ^ 2) + (vy ^ 2))
  -- print ("vector : "..vect.. " = sqrt("..balle.vx.."² + "..balle.vy.."²")
  angle = angle * math.pi / 180  -- convertit en radians
  -- print ("nouvel angle en radians : "..angle)
  -- print("vx = "..(math.cos(angle) * vect).."  vy = "..(math.sin(angle) * vect))
  return math.cos(angle) * vect, math.sin(angle) * vect
end 
]]--


-- en fonction de la ou on va toucher le pad ou une brique
-- on va : pour une brique ou le pad , lorsque la balle touche un angle de brique ou le bord arrondi du pad
-- il faut inverser les x et les y,  sinon inverser seulement y
-- sur les bords longs de brique ou pad, faire rebondir selon un angle qui varie : au centre , angle aigu, au bord, angle ouvert 
--
--  02/11 la fonction fonctionne dans le cas d'une brique ou du pad
--  apres il faut gerer le rebond de la balle
--
--  
--   test collision balle / brique
--   param 1 : le type de collision  , ici "brick" 
--   param 1 : la balle
--   param 2 : une brique (bricks)
--   param 3 : un id de bricks 

--  test collision balle / pad  
--   param 1 : le type de collision  , ici "pad"
--   param 2 : la raquette 
--   param 3 : l'indice d'une brique -> pour le pad ne pas remplir cette valeur

function IsBallCollideWith(collisionner, rect, idbrick)
   ---
   local hyp = 0
   -- dans la partie "pad" le test retourne true/false et la valeur de l'hypotenuse
   -- algo de collision entre 1 cercle et 1 raquette avec des cotés arrondis
   -- balle et raquette même taille : ok
   -- balle et très grande raquette : presque parfait , la balle rentre 1 peu sur les côtés
   -- mais globalement ca reste bien
  if collisionner == "pad" then  
      local ret
      local leftcircle, rightcircle
      leftcircle =  rect.x - (rect.width / 2 * rect.zoomlg) + balle.rayon 
      rightcircle = rect.x + (rect.width / 2 * rect.zoomlg) - balle.rayon
      
      -- test AABB, si ret = true collision avec le carre interieur de la brique
      ret = not (balle.x  <=  leftcircle                                    or
                 balle.x  >=  rightcircle                                   or
                 ((balle.y + balle.rayon) <= rect.y - rect.height / 2)       or
                 ((balle.y - balle.rayon) >= rect.y + rect.height / 2))
            
      if not ret then
          hyp =((leftcircle - balle.x) ^ 2 + (rect.y - balle.y) ^ 2)
          if (hyp < (2 * balle.rayon) ^ 2) then
             return true, hyp 
          end
          hyp =((rightcircle - balle.x) ^ 2 + (rect.y - balle.y) ^ 2)
            return (hyp < (2 * balle.rayon) ^ 2), hyp
      else
           return ret, hyp
      end 
  -- algo de collision entre un rectangle ou carré avec un cercle  ,  testé avec 1 raquette normale , 1 très grande raquette, tests OK 
  -- dans la partie "brick" les tests de collision retourne 0/1/2/3  0=pas de collision 1=collision sur le haut ou le bas  2=collision sur 1 des cotés  3=collision avec un angle    
  elseif collisionner == "brick" then  
      
      -- vu sur stackoverflow
      local dstx = math.abs(balle.x - rect.x[idbrick])
      local dsty = math.abs(balle.y - rect.y[idbrick])
      local w = rect.width[idbrick]
      local h = rect.height[idbrick]
      
      if (dstx > (w / 2 + balle.rayon)) then
          return 0, hyp -- v0.28
      end
      if (dsty > (h / 2 + balle.rayon)) then
          return 0, hyp -- v0.28 
      end
      if (dstx <= (w / 2)) then
          return 1, hyp -- v0.28 
      end
      if (dsty <= (h / 2)) then
          return 2, hyp -- v0.28
      end
      --  on regarde si on touche sur un angle de brique
      hyp = ((dstx - w / 2)^2) + ((dsty - h / 2)^2)
      if hyp > (balle.rayon ^ 2) then
          --return 3, hyp  -- v0.28
          return 0, hyp  -- v0.28
      end
      ------------ on detecte le coin touché
      dstx = balle.x - rect.x[idbrick]
      dsty = balle.y - rect.y[idbrick]
      -- on traitera les distances dans le code appelant
      return 3, dstx, dsty
      
      
  end
   
  
end -- end function


-- on retourne la balle
return balle