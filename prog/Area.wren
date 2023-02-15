import "lib/Renderer" for Renderer
import "lib/Drawing" for Surface
import "lib/Engine" for Level, Engine, Entity
import "Util" for Util
import "State" for Globals, Constants

class Area is Level {
    construct new() {}

    tileset { _tileset }

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
    }

    destroy() {
        super.destroy()
    }
}