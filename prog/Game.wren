import "lib/Engine" for Level
import "lib/Renderer" for Renderer, Camera
import "lib/Drawing" for Surface
import "State" for Globals, Constants

class Game is Level {
    construct new() { }
    
    create() {
        super.create()
        Globals.game_surf = Surface.new(Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
        Renderer.set_target(Globals.game_surf)
        Renderer.clear()
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)
        Globals.camera = Camera.new()
    }

    update() {
        Renderer.lock_cameras(Renderer.DEFAULT_CAMERA)
        var conf = Renderer.get_config()
        var x = (conf["window_width"] - (Globals.scale * Constants.GAME_WIDTH)) / 2
        var y = (conf["window_height"] - (Globals.scale * Constants.GAME_HEIGHT)) / 2
        Renderer.draw_texture(Globals.game_surf, x, y, Globals.scale, Globals.scale, 0, 0, 0)
        Renderer.unlock_cameras()

        super.update()
    }

    destroy() {
        super.destroy()
    }
}