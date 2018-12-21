require("constants")


local sounds = {}
-- v0.47
sounds.tabsrc = {}
sounds.fnames = {
                 SFX_START,           --  joué quand on commence un level ou qu'on engage la balle
                 BREAKOUT,            --  joué quand on rentre dans le jeu 
                 BALL_LOST,           --  joué quand on perd une balle
                 BRICK_NORMAL,        --  joué quand une brique normale est heurté 
                 BRICK_BROKEN,        --  joué quand une brique cassée est heurtée 
                 BRICK_DESTROYED,     --  joué quand 1 brique est détruite
                 BRICK_DESTROYED_2,   --  2eme son possible pour brk detruite 
                 EXIT_GAME,           --  joué quand on quitte le jeu
                 PAD                  --  joué quand la balle rebondit sur le pad
                }
-- v0.47  permet de savoir si on attend ou non avant de rejouer le même son
sounds.wait   = {
                 true,
                 true,
                 true,
                 false,
                 false,
                 false,
                 false,
                 true,
                 false
                }

function loadSounds(sfxpath)
   for k, v in pairs(sounds.fnames) do
     -- debug
     -- print(tostring(k).." + "..tostring(v))
     -- print("> "..sounds.fnames[k])
     sounds[v] = nil
     local f = sfxpath.."//"..v
     if love.filesystem.getInfo(f) ~= nil then
     --if love.filesystem.exists(f) then
       sounds[v] = love.audio.newSource(f,"static") -- référence vers sons d'origine a conserver
       -- v0.47
       sounds.tabsrc[v] = {} -- table contenant les references vers les sons brefs à jouer rapidement
       sounds.wait[v] = sounds.wait[k]
       
     end
   
  end
  return sounds
end

-- v0.47  pour pouvoir rapidement jouer le même son
-- param1 : un nom de ficher ou de constante ex : BRICK_NORMAL
-- param2 : dit si on doit attendre la fin d'un son pour jouer un autre son (true) ou non (false) 
-- param3 : servira pour le temps d'attente mini entre 2 sons ..
function sounds.playsource(fname, wait)
     -- print("fname = "..tostring(fname))
    if not wait then
       if sounds.tabsrc[fname] ~= nil then
          
          -- print("nombre d'elements de sounds["..fname.."] = "..#sounds.tabsrc[fname])
          for i, s in pairs(sounds.tabsrc[fname]) do
             if not s:isPlaying() then
                love.audio.play(s)
                return
              end
          end
                   
          local snd = sounds[fname]:clone()
          --local snd = love.audio.newSource(f, "static") 
          table.insert(sounds.tabsrc[fname], snd)
          love.audio.play(snd)  -- lit l'element cloné
      end
   else
      love.audio.play(sounds[fname])
   end
   

end

function newsource(fname, method)
    if method == nil or method == 0 then
        return love.audio.newSource(fname, "static")
    
    end    
end



return sounds