require("constants")
require("functions")

-- types de briques
local bricktype = {}
--bricktype.total = TOTAL_BRICK_TYPE   -- nombre total de briques diiferentes
--bricktype.normal = {}                 -- briques normales
--bricktype.broken = {}                 -- briques cassées
bricktype.normal = {
                    "brick01-1",
                    "brick02-1",
                    "brick03-1",
                    "brick04-1",
                    "brick05-1"
                   }
bricktype.broken = {
                    "brick01-2",
                    "brick02-2",
                    "brick03-2",
                    "brick04-2",
                    "brick05-2",
                   }
                   
                   
bricktype.nresist = {1, 2, 3, 3, -1}      -- valeur de resistance des briques normales  -1 : indestructible : en effet vu qu'on enleve -1 a chaque coup de la balle, pour une brique ayant une valeur < 0 on atteindra jamais 0  qui est la valeur de la destruction
bricktype.bresist = {0, 1, 2, 1, 0}      -- valeur de resistance des briques cassées (valeur a partir de laquelle on affiche la brique cassée)
                                      -- quand la valeur de resistance d'une brique = 0 , la brique est detruite
-- briques
local bricks = {}
bricks.total  = nil      --- nombre de briques chargés pour un niveau
bricks.img = {}         --- les references vers images des briques affichées à l'ecran : bricks.img[1] ex : brique verte  bricks.img[2] ex : brique verte...  bricks.img[3] : brique 
--bleue ...  la longeur du tableau #bricks.img  donne le nombre de brique affichées à l'ecran 

bricks.imgbroken = {}   --- ajout v 0.31  pour correction bug
bricks.nresist = {}     --- resistance initiale des briques normales, c'est cette valeur qui servira de reference pour bricks.resistance, cette valeur ne varie pas
bricks.bresist = {}     --- cette valeur sert de reference à partir de laquelle on affiche une brique cassée, cette valeur ne varie pas
bricks.resistance = {}  --  cette valeur prend au depart la valeur de bricks.nresist 
bricks.visible = {}     --  indique si la brique est visible ou non, si invisible : on ne detecte plus de collision
                        --  v0.48C -> trois etats : true : visible ,  false : invisible : on commence l'anim explosion, nil : anim terminée
bricks.x = {}           --- position x d'une brique
bricks.y = {}           --- position y d'une brique
bricks.width  = {}      --- largeur d'une brique
bricks.height = {}      --- hauteur d'une brique 

-- v0.48C

bricks.framespeed    = BRICK_FSPEED
bricks.numframeAnim  = {} -- numero de la frame en cours pour chaque brique 
bricks.imgAnim       = nil -- reference vers l'image contenant toutes les frames de l'anim explosion
bricks.frames        = {} -- tableau qui contient chaque image de l'animation
bricks.w_frame        = nil  -- largeur d'une frame
bricks.h_frame        = nil  -- hauteur d'une frame
-- couleurs aleatoires
bricks.red            = {}
bricks.green          = {}
bricks.blue           = {}
bricks.alpha          = {}
-- v0.48C charge les Animations de l'explosion d'une brique
-- appelé au début du programme
--
function bricks.loadAnimExplode(file)
   local frame = {}
   local nb = 0
   local nbrows = NB_ROWS_EXPLODE_ANIM
   local nbcols = NB_COLS_EXPLODE_ANIM
   local img, w, h  = getImageParams(file)
   w = w / nbcols
   h = h / nbrows
   for y=1, nbrows do
     for x=1, nbcols do
       nb = nb + 1 
       frame[nb] = love.graphics.newQuad((x - 1) * w, (y - 1) * h, w, h, img:getWidth(), img:getHeight()) 
       
     end  
   end  
   -- 
   
   
   
   return img, frame, w, h
end



-- permet de RAZ les champs de briques --
function bricks.reset()
      bricks.total          = nil      --- nombre de briques chargés pour un niveau
      bricks.img            = {}         --- les references vers images des briques affichées à l'ecran : bricks.img[1] ex : brique verte  bricks.img[2] ex : brique verte...  bricks.img[3] : brique 
      --bleue ...  la longeur du tableau #bricks.img  donne le nombre de brique affichées à l'ecran 

      bricks.imgbroken      = {}   --- ajout v 0.31  pour correction bug
      bricks.nresist        = {}     --- resistance initiale des briques normales, c'est cette valeur qui servira de reference pour bricks.resistance, cette valeur ne varie pas
      bricks.bresist        = {}     --- cette valeur sert de reference à partir de laquelle on affiche une brique cassée, cette valeur ne varie pas
      bricks.resistance     = {}  --  cette valeur prend au depart la valeur de bricks.nresist 
      bricks.visible        = {}     --  indique si la brique est visible ou non, si invisible : les coord x et y sont mis à 10000, 10000
      bricks.x              = {}           --- position x d'une brique
      bricks.y              = {}           --- position y d'une brique
      bricks.width          = {}      --- largeur d'une brique
      bricks.height         = {}      ---
      -- v0.48C
      bricks.numframeAnim   = {} -- on reinitialise le tableau des Animations
      bricks.red            = {}
      bricks.green          = {}
      bricks.blue           = {}
      bricks.alpha          = {}
      -- on force le gb (très important ici..)
      collectgarbage()
end

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- charge les briques d'un level , level est une table
-- c'est ici qu'on chage les briques, leur valeur type brick, leur coord x et y calculés automatiquement..
-- parametre : le numero d'un level, le y de depart pour la rangée du haut,  le delta y d'ecartement entre 2 lignes 
-- retour p1 :true  : OK ,  p2 : nombre de briques du level
--        p&: false : KO  
function bricks.load(level, offset_y)  
  -- ici faire un RAZ de la table des briques et rechargez
  -- par un appel a une fonction par exemple
  --
  --
  --
  if level <= #levels and level > 0 then
     levelencours = level
    -- print(" xb :"..(bricktype.normal[levels[level][1]]:getWidth() / 2).."   yb : "..(bricktype.normal[levels[level][1]]:getHeight() /2))
   
   -- on ne s'occupe pas des coordonnées dans un premier temps
   -- on charge les briques
     local tot_bricks = 0
     for i=1, #levels[level] do
         if levels[level][i] > 0 then
           LoadBrick(levels[level][i], "normal")
           LoadBrick(levels[level][i], "broken")
           tot_bricks = tot_bricks + 1
         end
         
     end
     -- maintenant on va s'occuper des coordonnées --------------------
    --local yb =  offset_y_start * BRICK_INTERVAL
    
    local xbstart = (largeur - ((math.floor(largeur / BRICK_STD_LG)) * BRICK_STD_LG)) / 2 + (BRICK_STD_LG / 2)
    -- print ("xbstart="..xbstart)  
    local xb = xbstart
    local yb = BRICK_STD_HT * offset_y
    
    local num_brick = 1
    for i=1, #levels[level] do
        if levels[level][i] > 0 then
           --xb = xb + bricks.width[num_brick]
           if xb > (largeur - bricks.width[num_brick] / 2) then
             xb = xbstart 
             yb = yb + BRICK_STD_HT + BRICK_INTERVAL_Y
           end  
           table.insert(bricks.x, xb)
           table.insert(bricks.y, yb)
           -- debug 
           -- print("brique num : "..num_brick.." x="..xb.."  y="..yb) 
           num_brick = num_brick + 1
           if num_brick <= tot_bricks then
              xb = xb + bricks.width[num_brick] -- brique suivante
           end
        else
          --xb = xb + BRICK_STD_LG 
          if xb > (largeur - BRICK_STD_LG / 2) then
            xb = xbstart
            yb = yb  + BRICK_STD_HT + BRICK_INTERVAL_Y
          end
          xb = xb + BRICK_STD_LG 
          
        end
       
    end
    
    -- print("level numéro "..level..", chargement OK")
    return true, num_brick - 1
  else
    -- print("level numéro "..level.." inexistant, chargement KO")
    return false
  end

end

-- v0.48C  utilisé pour gérer les animations de l'explosion d'une brique
function bricks.update(speed, dt)
  -- on itere a travers toutes les briques
  for i=1, #bricks.x do
      if bricks.visible[i] == false then
          -- debug --
          --print("bricks.visible["..i.."] = "..tostring(bricks.visible[i]))
          -- fin debug
          bricks.numframeAnim[i] = bricks.numframeAnim[i] + (speed * dt)
          if bricks.numframeAnim[i] >= #bricks.frames then
            bricks.visible[i] = nil -- on va desactiver l'animation de l'explosion, c'est fini
            --bricks.numframeAnim[i] = 1
          end
      end  
  end
  
end  



--  dessine les briques à l'ecran , seulement si elles sont visibles
function bricks.draw()
 for i=1, #bricks.x do
    if bricks.visible[i] then
       love.graphics.draw(bricks.img[i],bricks.x[i],bricks.y[i],0, ZOOM_FACTOR, ZOOM_FACTOR, bricks.width[i] / 2, bricks.height[i] / 2)
    end
 end
 for i=1, #bricks.x do
    -- v0.48C
    if bricks.visible[i] == false then
      local frame= math.floor(bricks.numframeAnim[i])
      -- couleur + canal alpha aleatoires pour chaque explosion
      love.graphics.setColor(bricks.red[i], bricks.green[i], bricks.blue[i], bricks.alpha[i])
      love.graphics.draw(bricks.imgAnim, bricks.frames[frame], bricks.x[i],bricks.y[i], 0, ZOOM_FACTOR, ZOOM_FACTOR, bricks.w_frame / 2, bricks.h_frame / 2)
      love.graphics.setColor(1, 1, 1, 1)
    end
 end
end



-- charge une brique
-- parametres :
-- la table des briques , bricks
-- un numero qui correspond à un numéro d'image de brique
-- un typeImg "normal" ou "broken"
-- la hauteur et largeur d'une brique
-- retourne les nouvelles valeurs de x et y pour la prochaine brique, les mêmes valeurs sinon
function LoadBrick(number, typeImg)
   
  if number <= #bricktype[typeImg] then 
     
         local br = bricktype[typeImg][number]
         if typeImg == "normal"  then
             table.insert(bricks.img, br)                                -- pendant le jeu, on modifiera cette reference pour que ceci passe à une image "broken"
             table.insert(bricks.resistance, bricktype.nresist[number])  -- insertion resistance brique (cette valeur decroit pendant le jeu pour une brique touchée)
             table.insert(bricks.nresist, bricktype.nresist[number])     -- insertion resistance initiale brique non cassée
             table.insert(bricks.bresist, bricktype.bresist[number])     -- insertion seuil resistance pour brique cassée 
             table.insert(bricks.width, br:getWidth())                   -- insertion largeur brique  on a besoin de le preciser à cause de la fonction de collision
             table.insert(bricks.height, br:getHeight())                 -- insertion hauteur brique  on a besoin de le preciser à cause de la fonction de collision
             table.insert(bricks.visible, true)                          -- visible
         -- ajout v0.31
         elseif typeImg == "broken" then
             table.insert(bricks.imgbroken,br)
         end
         -- ajout v0.48C
             table.insert(bricks.numframeAnim, 1)                        -- valeur au départ, on part de la frame 1 de l'anim explosion
             table.insert(bricks.red,   math.random())                   --  valeur de R, V, B pour 1 Explosion  
             table.insert(bricks.green, math.random())                   --
             table.insert(bricks.blue,  math.random())                   --
             table.insert(bricks.alpha, math.random() + 0.3)             -- canal alpha 
  --else
     
     
  end
  
end

-- charge tous les types de briques
-- value represente soit "normal"  soit "broken" 
-- au retour myBrick contiendra des references vers les images et non plus
-- des chaines de caracteres representant un nom de fichier
--
function LoadBrickType(value) 
   -- debug
   -- print (#myBrick[value])
   --for i=1, myBrick.total do
   for i=1, #bricktype[value] do
        local fic = "Gfx/"..bricktype[value][i]..".png"
        bricktype[value][i], _, _ = getImageParams(fic)
        -- debug -- on a bien des references a des images 
       -- print("fic="..fic.."     bricktype."..value.."["..i.."]="..tostring(bricktype[value][i]))
   end
   
   
end



--- retourne les briques 
return bricks