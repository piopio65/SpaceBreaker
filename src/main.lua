-- Cette ligne permet d'afficher des traces dans la console pendant l'execution
-- v 0.10 -- initial release
-- v 0.15 -- on introduit les briques
-- v0.20 -- mise en place de TypeBricks et de bricks
-- v0.25 -- amelioration de Bricks et TypeBricks
-- v0.28 -- reimplementation des collisions bricks / pad
-- v0.30 -- on implemente enfin les bricks , affichage de celles-ci
-- v0.31 -- implementation collisions balle / brick todo :   s'il y a des trous dans levels alors la correspondance de levels[numlevel][indice] a mettre dans bricks.img
         ---                                                 est incorrecte , remedier à ça par l'ajout d'une table supplentaire pour bricks sans les trous
            -- todo : il arrive que la balle se bloque : pour y remedier : faire un rebond en faisant legerement varier l'angle de rebond (alatoirement)
            -- probleme apparemment résolu : le comportement de la balle heutant les briques est satisfaisant.
            -- TODO : introduire dose d'incertitude lorsque la balle heurte une brique dans un des coins (mettre un petit delta d'angle aleatoire)
-- v0.33  -- reorganisation du code
-- v 0.42 -- implementaion Sfx
-- v 0.44 -- amelioration collision balle / pad
          -- mise en place du changement de level par appui sur 1 touche
-- v 0.45 -- implementation du nouveau pad
-- v 0.46 -- implementation ecran accueil, tests ok
-- v 0.47 -- amélioration de la jouabilité des sons dans le jeu
-- v 0.48 -- faire un ecran de fade in / fade out  (rectangle blanc)
-- v 0.48A -- ecrans fade in /ou implémentés mais il reste des bugs
-- v 0.48B -- suppression bugs fade in / out
-- v 0.48C -- balle tournante et animations briques qui explosent lorsqu'elles sont detruites
-- v 0.50  -- todo : plusieurs balles
-- v0.51 ------------------------  initial commit -------------------------------------------------------------

io.stdout:setvbuf('no')
require("constants")
require("functions")

local raquette = require("raquette")
local stars    = require("stars")
local balle    = require("ball")
local bricks   = require("bricks")
local sounds   = require("sfx")

local reso
--local bricktype = require("bricks")
local fullscreen = false
-- font
local fontfps, fontready
-- variables à initaliser
local initball, soundtoplay

-- pour debug
local deltatime

-- Empeche Love de filtrer les contours des images quand elles sont redimentionnées
-- Indispensable pour du pixel art
love.graphics.setDefaultFilter("nearest")

--------------  niveau de départ --------------------
local level = START_LEVEL
local ecran = SCR_WELCOME
-----------------------------------------------------

local ret, nbricks
local minwait   = MIN_WAIT  -- 0.08 s  temps d'attente mini entre 2 sons simultanés
local startwait = MIN_WAIT

-- 0.48A 0.48B ----------------------------
local transition_start = false
local trans_state       = nil
local transition_middle = math.pi / 2
local transition_end    = math.pi
local alpha_timer       = 0
-------------------------------------

-- Cette ligne permet de débloquer le debug dans ZeroBraneStudio
if arg[#arg] == "-debug" then require("mobdebug").start() end

function love.load()

  --- init seed for random numbers ----------------------------
  math.randomseed(os.time())

  -----------------  valeurs pour le début d'un level ------------
  initball = true
  soundtoplay = SFX_START
  ----------------------------------------------------------------
  -- load font for score, fps ..
  fontfps = love.graphics.newFont("Fonts/Kenney Rocket Square.ttf", 24)
  fontready = love.graphics.newFont("Fonts/Kenney Rocket Square.ttf", 48)
  -- load font for info intro level
  --love.graphics.setFont(fontfps)

  -- load sounds
  sounds = loadSounds(SFX_PATH)
  -------------------------- debug -----------------------------------
   reso = getFSModes()

  --- table triée des resolutions accessibles en full screen
  --for i=1, #reso do
    -- print(tostring(reso[i].width).." x "..tostring(reso[i].height))
  --end



  --for i = 1, #modes do
  -- -- print (modes.a[i].." x "..modes.b[i])
  --end
  local retres = love.window.setMode(SCR_WIDTH ,SCR_HEIGHT , {fullscreen = fullscreen, vsync=true, fullscreentype= "exclusive" })
  --if retres then
  --   retres= "OK"
  --else
  --  retres="Failed"
  --end

  -- print ("resolution "..SCR_WIDTH.." x "..SCR_HEIGHT.." fullscreen : "..tostring(fullscreen).." : "..retres)

  love.window.setTitle(MAIN_TITLE)
  love.mouse.setVisible(MOUSE_VISIBLE)

  largeur = love.graphics.getWidth()
  hauteur = love.graphics.getHeight()
  -- debug
  -- print("lg: "..largeur.." ht: "..hauteur)

  -- chargement de la balle
  balle.load(GFX_PATH..BALL)

  -- chargement des images des briques
  LoadBrickType("normal")
  LoadBrickType("broken")
  -- appel ecran accueil
  -- param1 : un nom de fichier
  -- param2 : un type d'ecran , SCR_WELCOME  ou  SCR_LEVEL
  LoadLevel(GFX_PATH..BG..INTRO..".jpg", SCR_WELCOME)

  ---     chargement images raquette ------------------------------------------------------------
  raquette.img, raquette.frames = raquette.load(GFX_PATH..PAD_NAME, raquette.nbframes)
  raquette.width, raquette.height = raquette.img:getDimensions()
  raquette.width = raquette.width / raquette.nbframes


  --    v0.48C  chargement images de l'animation explosion brique -------------------------------------
  bricks.imgAnim, bricks.frames, bricks.w_frame, bricks.h_frame = bricks.loadAnimExplode(GFX_PATH..ANIM_EXPLODE_NAME)


  -- debug pour voir si chargement correct, ok
  -- print("Explosion img w : "..tostring(bricks.imgAnim:getWidth()).."   img h : "..tostring(bricks.imgAnim:getHeight()))
  -- for k, v  in pairs(bricks.frames) do
  --    print ("img num : "..tostring(k).."  = "..tostring(v))
  -- end
  -- fin debug

  -- initialisation des parametres de depart de la raquette
  raquette.init()
  -- raquette.y = hauteur - raquette.height

  ----   chargement images etoiles -------------------------------------------------------------
  stars.img, stars.frames = stars.load(GFX_PATH..STARS_NAME, stars.nbframes)
  stars.width, stars.height = stars.img:getDimensions()
  stars.width = stars.width / stars.nbframes


  -- on joue le son de départ
  -----------------------------------------------------------------------------------------------
  sounds.playsource(BREAKOUT, true)
  -- debug
  --print(ecran)
  --print(trans_state)
end


function love.update(dt)
   -- debug
   deltatime = dt

   -- v0.46 -- ecran accueil
   --if ecran == SCR_WELCOME then
  if trans_state == nil then
    return
  end

  if trans_state == "start" then
     alpha_timer = alpha_timer + dt
     if alpha_timer >= transition_middle then
        trans_state = "middle"
        LoadLevel(GFX_PATH..BG..(level)..".jpg", ecran)
     end

  elseif trans_state == "middle" then
     alpha_timer = alpha_timer + dt
     if alpha_timer >= transition_end then
        alpha_timer = 0
        trans_state = "end"
     end

  end


   --- la boucle de jeu se deroule ici ---
   if ecran == SCR_LEVEL then

         -- startwait = startwait + dt
         raquette.frame =raquette.update(raquette.frame, raquette.framespeed, dt)
         -- v0.45 mise à jour du dessin des etoiles
         stars.frame = stars.update(stars.frame, stars.framespeed, dt)

         if trans_state == "middle" then
            balle.init(raquette)
         elseif trans_state == "end" then
                 startwait = startwait + dt
                 if initball then
                    -- mettre l'appel à balle.init ici pour voir la balla etre sur
                    -- la raquette tout de suite quand on perd une vie
                    -- balle.init(raquette)
                    if sounds[soundtoplay] ~= nil then
                        if not sounds[soundtoplay]:isPlaying() then
                            soundtoplay = SFX_START
                            -- debug
                            print("START...")
                            -- fin debug
                            sounds.playsource(soundtoplay, sounds.wait[soundtoplay])
                            --initball = false
                             -- mettre l'appel à balle.init ici pour voir la balla etre sur
                             -- la raquette à la fin de la phrase prononcée
                            balle.init(raquette)
                            initball = false
                        end
                    end
                 -- la balle est relancée ici...
                 else
                     if not balle.wait then --- pour debug permet de figer la balle par appui sur w
                       soundtoplay, initball = balle.update(dt, bricks, raquette)
                       -- v0.48C
                       bricks.update(bricks.framespeed, dt)

                       if soundtoplay ~= nil then
                         if (startwait >= minwait) then
                            startwait = 0
                            sounds.playsource(soundtoplay, sounds.wait[soundtoplay])
                         end
                       end
                     end -- fin balle.wait
                 end

                --- debug ca fonctionne retreciisement et agrandissement raquette
                 if love.keyboard.isDown("up") then
                   print(tostring(raquette.AlterWidth("plus", 1.5, dt)))
                 end
                 if love.keyboard.isDown("down") then
                    print(tostring(raquette.AlterWidth("minus", 3.5, dt)))
                 end

        end -- fin test trans_state


   end

end

function love.draw()
    love.graphics.push()
    love.graphics.setColor(1, 1, 1, 100)
    love.graphics.draw(background.img,0,0,0,background.sx,background.sy)

    --- quand on revient à l'ecran d'accueil, on continue à dessiner ce qu'il y a à l'ecran
    --- quand state est dans l'etat start
    if ecran == SCR_WELCOME then
         if trans_state == "start" then
              drawElementsLevel(raquette, stars, bricks, balle, fontfps)
         end
    -- quand on passe dans un ecran de niveau, on ne dessine que les elements à partir
    -- de l'état "middle"
    elseif ecran == SCR_LEVEL then
          if trans_state ~= "start" then
              drawElementsLevel(raquette, stars, bricks, balle, fontfps)
          end
          if trans_state == "middle" then
              --love.graphics.setFont(fontfps)
              --setFont(font)
              drawStartLevel("PLAYER\nGET READY", fontready)
          end


    end
    if trans_state ~= "end" then
        love.graphics.setColor(1, 1, 1, math.sin(alpha_timer))
        love.graphics.rectangle("fill",0,0, largeur,  hauteur)
    end
    love.graphics.pop()
end

function love.mousepressed(x, y, button)
  if button == 1 and not initball then
    balle.colle=false
  end
end


function love.keypressed(key)
    -- v0.44 test changement de level, tout a l'air OK !!!!!
    -- v0.46 basculement entre ecran accueil et level 1

    if ecran == SCR_WELCOME then
          if (key == "n") then
            ecran = SCR_LEVEL
            level = START_LEVEL
            -- 0.48A
            alpha_timer = 0
            trans_state = "start"

          elseif key == TOGGLE_EXIT and (trans_state == "end" or trans_state == nil) then
            exitProgram()
          end

    elseif ecran == SCR_LEVEL then
          if (key ==  TOGGLE_EXIT) then
             ecran = SCR_WELCOME
             level = INTRO
             alpha_timer = 0
             trans_state = "start"
          end

            -- pour debug
          if (key=="w") then
            if balle.wait then
               balle.wait=false
            else
               balle.wait=true
            end
          end
          -- fin debug




    end

    -------- changement de resolution, accessible n'importe quand
    if (key == TOGGLE_FULL_SCREEN) then
      fullscreen = not fullscreen
      ret = setMode(SCR_WIDTH, SCR_HEIGHT, fullscreen)
      local sret
      if ret then
        sret = "OK"
      else
        sret = "Failed"
      end
      -- print ("resolution "..SCR_WIDTH.." x "..SCR_HEIGHT.." fullscreen : "..tostring(fullscreen).." : "..sret)
    end


end

--- permet de charger un level ou un autre type ecran accueil, credits, gameover...etc., tests a faire
--- param 1 nom de fichier image
--- param 2 un type d'ecran  accueil ou level
function LoadLevel(fname, typecr)

      if typecr == SCR_WELCOME then
        -- chargement image accueil
        background.img = SetBackGround(fname)
        background.sx, background.sy = getImageScale(background.img, largeur, hauteur)


      elseif typecr == SCR_LEVEL then
        -- chargement d'un level
        initball = true
        soundtoplay = SFX_START
        background.img = SetBackGround(fname)
        background.sx, background.sy = getImageScale(background.img, largeur, hauteur)
        bricks.reset()
        ret, nbricks =bricks.load(level, 3)
        if ret then
         bricks.total = nbricks
         print("nombre de briques chargées : "..nbricks)
        end

      end




end




-- charge l'image d'un level
function SetBackGround(fname)
  --local bgfile = "Gfx/background"..numlevel..".jpg"
  -- local bgfile = level
  return getImageParams(fname)
end

--- permet de sortir du programme
function exitProgram()
  love.audio.play(sounds[EXIT_GAME])
  while sounds[EXIT_GAME]:isPlaying() do
     love.timer.sleep(1)
  end
  love.event.quit()

end
