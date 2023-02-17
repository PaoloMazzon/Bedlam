import "lib/Renderer" for Renderer
import "lib/Drawing" for Surface
import "lib/Engine" for Level, Engine, Entity
import "Util" for Util
import "State" for Globals, Constants

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

        // Pre-load tilesets
        // Pre-load the image of the foreground tileset
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
    }

    update() {
        Util.adjust_camera()

        // Draw tilesets
        Renderer.lock_cameras(Globals.camera)
        // TODO: Draw a background
        Renderer.draw_texture(_background_surface, 0, 0)
        Renderer.draw_texture(_collision_surface, 0, 0)
        super.update()
        Renderer.draw_texture(_foreground_surface, 0, 0)
        Renderer.unlock_cameras()

        // Handle pausing
        if (is_paused && _pause_timer != -1) {
            _pause_timer = _pause_timer - 1
            if (_pause_timer == 0) {
                unpause()
            }
        }
    }

    destroy() {
        super.destroy()
    }
}