import "lib/Renderer" for Renderer
import "lib/Drawing" for Surface
import "lib/Engine" for Level, Engine, Entity
import "lib/Util" for Math, Tileset
import "lib/Input" for Keyboard
import "Util" for Util
import "State" for Globals, Constants, Balance
import "Player" for Player
import "LevelControl" for Transition
import "Assets" for Assets

class Area is Level {
    construct new() {
        _paused = false
        _pause_timer = -1
    }

    tileset { _tileset } // tileset used for collision checking
    is_paused { _paused } // it is the entity's responsibility to check this
    
    pause(time_in_seconds) {
        _paused = true
        _pause_timer = (time_in_seconds * 60).round
    }
    
    pause() { 
        _paused = true 
        _pause_timer = -1
    }

    unpause() {
        _paused = false
        _pause_timer = -1
    }

    create() {
        super.create()
        _tilesets = Util.init_area(this)
        _tileset = _tilesets["collisions"]
        Globals.camera.x = Math.clamp(Globals.camera.x, 0, tileset.width - Constants.GAME_WIDTH)
        Globals.camera.y = Math.clamp(Globals.camera.y, 0, tileset.height - Constants.GAME_HEIGHT)
        Globals.camera.update()

        // Pre-load tilesets
        // Pre-load the image of the foreground tileset
        Renderer.set_texture_camera(false)
        _collision_surface = Surface.new(_tileset.width, _tileset.height)
        Renderer.set_target(_collision_surface)
        _tileset.draw()
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)

        // Pre-load the image of the backdrop tileset
        _background_surface = Surface.new(_tilesets["background"].width, _tilesets["background"].height)
        Renderer.set_target(_background_surface)
        _tilesets["background"].draw()
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)

        // Pre-load the image of the background tileset
        _foreground_surface = Surface.new(_tilesets["foreground"].width, _tilesets["foreground"].height)
        Renderer.set_target(_foreground_surface)
        _tilesets["foreground"].draw()
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)

        // Hold onto player handle
        _player = get_entity(Player)

        // For fading in/out
        _fade_in = (Balance.FADE_DURATION * 60).round
        pause(Balance.FADE_DURATION)
        _fade_out = -1
        _next_area = ""
        Renderer.set_texture_camera(true)
    }

    update() {
        Util.adjust_camera()

        // Draw tilesets
        Renderer.lock_cameras(Globals.camera)
        Renderer.set_target(Globals.game_surf)
        Renderer.set_colour_mod([0, 0, 0, 1])
        Renderer.clear()
        Renderer.set_colour_mod([1, 1, 1, 1])
        Tileset.draw_tiling_background(Assets.tex_forestbg, 0.8, Globals.camera)
        Renderer.draw_texture(_background_surface, 0, 0)
        Renderer.draw_texture(_collision_surface, 0, 0)
        super.update()
        Renderer.draw_texture(_foreground_surface, 0, 0)
        Util.draw_player_ui(_player)
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)
        Renderer.lock_cameras(Renderer.DEFAULT_CAMERA)
        Util.draw_game_surface()
        Renderer.unlock_cameras()

        // Handle fading in and out
        if (_fade_in != -1) {
            _fade_in = _fade_in - 1
            Renderer.set_colour_mod([0, 0, 0, (_fade_in / 60) / Balance.FADE_DURATION])
            Renderer.clear()
            Renderer.set_colour_mod([1, 1, 1, 1])
        } else if (_fade_out != -1) {
            _fade_out = _fade_out - 1
            Renderer.set_colour_mod([0, 0, 0, 1 - ((_fade_out / 60) / Balance.FADE_DURATION)])
            Renderer.clear()
            Renderer.set_colour_mod([1, 1, 1, 1])
            if (_fade_out == 0) {
                Util.change_area(_area, Area)
            }
        }

        // Check for collisions between the player and transitions
        var transition = entity_collision(_player, Transition)
        if (transition != null && _fade_out == -1) {
            _fade_out = (Balance.FADE_DURATION * 60).round
            _area = transition.area
            pause()
        }

        // Handle pausing
        if (is_paused && _pause_timer != -1) {
            _pause_timer = _pause_timer - 1
            if (_pause_timer == 0) {
                unpause()
            }
        }

        // Hotkeys
        if (Keyboard.key(Keyboard.KEY_LALT) && Keyboard.key_pressed(Keyboard.KEY_RETURN)) {
            Globals.fullscreen = !Globals.fullscreen
            var conf = Renderer.get_config()
            conf["fullscreen"] = Globals.fullscreen

            if (!Globals.fullscreen) {
                Globals.scale = Constants.DEFAULT_SCALE
                conf["window_width"] = Globals.scale * Constants.GAME_WIDTH
                conf["window_height"] = Globals.scale * Constants.GAME_HEIGHT
            }

            Renderer.set_config(conf)
            Util.maximize_scale()
        }
    }

    destroy() {
        super.destroy()
    }
}