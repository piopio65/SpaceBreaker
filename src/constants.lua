MAIN_TITLE = "SPACE BREAKER"
MOUSE_VISIBLE = false
SCR_WIDTH = 1360
SCR_HEIGHT = 768

BALL_MAX_DELTA_ANGLE = 62
BALL_VERTICAL_ANGLE = 270
BALL_START_ANGLE = 315
BALL_MAX_SPEED = 900
BALL_SPEED = 520                    -- vitesse de deplacement de la balle en pixels / s
BALL_ROTATE_SPEED = BALL_SPEED             -- vitesse de rotation en degrés / s

RATIO_SEP_SCREEN = 0.90             -- pourcentage de la hauteur de l'ecran
--TOTAL_BRICK_TYPE = 3              -- nombre total de type de briques differentes
ZOOM_FACTOR    = 1
BRICK_STD_LG   = 96 * ZOOM_FACTOR
BRICK_STD_HT   = 32 * ZOOM_FACTOR
BRICK_RATIO_LG_HT   =  BRICK_STD_LG / BRICK_STD_HT
BRICK_INTERVAL      =  32     -- 32 pixels d'interval entre chaque brick
BRICK_INTERVAL_Y    =  12      -- 12 pixel d'intervalle
-- v0.48D
NB_ROWS_EXPLODE_ANIM = 4      -- nombre de lignes de l'Anim de l'explosion d'une brique
NB_COLS_EXPLODE_ANIM = 8      -- nombre de colonnes de l'Anim de l'explosion d'une brique


STARS_FSPEED        =  10      -- vitesse d'animation des petites etoiles du pad
PAD_FSPEED          =  8       -- vitesse d'animation de l'eclair du pad
-- v0.48C
BRICK_FSPEED        =  NB_ROWS_EXPLODE_ANIM * NB_COLS_EXPLODE_ANIM * 2.1  -- vitesse d'animation de l'Animation Explosion d'une brique

ZOOM_FACTOR_PAD = 1            -- ratio de largeur normal pour le pad
ZOOM_FACTOR_MAX_X_PAD = 1.7    -- ratio de largeur max du pad
ZOOM_FACTOR_MIN_X_PAD = 0.45   -- ratio de largeur min du pad
MAX_DELTA_ANGLE_WHEN_BOUNCE  = 11   -- delta angle max en degrés lorsque la balle
                                   --rebondit sur un coin de brique

TOGGLE_FULL_SCREEN = "f5"          -- switche entre le fs et le mode fenetré
TOGGLE_EXIT = "escape"

-- SCREEN NAMES
SCR_WELCOME  = "accueil"
SCR_LEVEL    = "level"

-- miscellaneous
BG           = "background"
START_LEVEL  = 1
MIN_WAIT     = 0.10      -- temps d'attente mini a jouer entre 2 sons (en s)

-- GFX
GFX_PATH     = "Gfx/"
PAD_NAME     = "pad.png"
STARS_NAME   = "small-stars.png"
--INTRO        = "intro.jpg"
INTRO        = "intro"
BALL         = "ball.png"
-- V0.48D explosion
ANIM_EXPLODE_NAME = "bricks-explode.png"


-- SFX
SFX_PATH           = "Sfx/sounds/"
BREAKOUT           = "breakout.wav"
SFX_START          = "start.wav"
BALL_LOST          = "ball-lost.wav"
PAD                = "pad.wav"
BRICK_NORMAL       = "brick-normal.wav"
BRICK_BROKEN       = "brick-broken.wav"
BRICK_DESTROYED    = "brick-destroyed.wav"
BRICK_DESTROYED_2  = "brick-destroyed-2.wav"
EXIT_GAME          = "exit-game.wav"
-- MUSIC


--RATIO_BRICK_STD_LG_BRICK_INTERVAL =  BRICK_STD_LG / BRICK_INTERVAL --  3
math.maxinteger=2^31
math.mininteger=-2^31
