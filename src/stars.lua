require("constants")
local frameRounded

--- v0.45 stars of pad ------------------------------
local stars = {}
stars.nbframes = 3
stars.img = nil
stars.width = nil
stars.height = nil
stars.frame = 1
stars.framespeed = STARS_FSPEED -- vitesse anim stars

--- chargement dessin des etoiles du pad
function stars.load(starsFile, nbframes)
    local img=love.graphics.newImage(starsFile)
    local frame = {}
    for i=1, nbframes do
        frame[i]=love.graphics.newQuad((i-1) * img:getWidth() / nbframes, 0, img:getWidth() / nbframes, img:getHeight(), img:getWidth(), img:getHeight())
    end
    return img, frame
end

--- update dessin des etoiles
function stars.update(frame, speed, dt)
   frameRounded=math.floor(stars.frame)
   --frame=frame + speed * dt
   frame = frame + stars.framespeed * dt
   if frame >= #stars.frames then
     frame = 1
   end
   return frame
end

-- dessine les etoiles
-- param1 : une reference de raquette
-- param2 : un decalage de x pixels par rapport à la raquette
-- param3 : 1 image normale (droite)   -1 : image inversée (gauche)
-- param4 : si 0 aucun affichage des etoiles, both : affichage permanent des 2 cotés   alternate : affichage à doite ou à gauche selon le sens de depl du pad

----function stars.draw(refpad, offsetx, sens, drawWhenpadMove)



function stars.draw(refpad, drawWhenpadMove)
     local depX = nil
     local sens = nil
     offsetx = (((refpad.width / 2) * refpad.zoomlg)  + stars.width / 2)

     if drawWhenpadMove == "both" then
       --   love.graphics.draw(stars.img, stars.frames[frameRounded], refpad.x + offsetx , refpad.y, 0, sens * ZOOM_FACTOR, ZOOM_FACTOR, stars.width / 2, stars.height / 2)
          for i = -1, 1, 2 do
              love.graphics.draw(stars.img, stars.frames[frameRounded], refpad.x + (i * offsetx) , refpad.y, 0, i * ZOOM_FACTOR, ZOOM_FACTOR, stars.width / 2, stars.height / 2)
          end
     elseif drawWhenpadMove == "alternate" then
        depX = refpad.x - refpad.oldx
        if depX ~= 0 then
               if (depX > 0) then
                 sens = -1
               elseif (depX < 0) then
                 sens = 1
               end
               love.graphics.draw(stars.img, stars.frames[frameRounded], refpad.x + (sens * offsetx) , refpad.y, 0, sens * ZOOM_FACTOR, ZOOM_FACTOR, stars.width / 2, stars.height / 2)
        end

     end -- fin drawWhen
end -- end function

return stars
