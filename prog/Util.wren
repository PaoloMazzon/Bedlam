import "lib/Renderer" for Renderer
import "lib/Engine" for Engine
import "State" for Globals, Constants
import "Player" for Player
import "LevelControl" for Marker, Transition
import "Skeleton" for Skeleton

class Util {
    static maximize_scale() {
        var config = Renderer.get_config()
        Globals.scale = 1
        var w = config["window_width"]
        var h = config["window_height"]
        while ((Globals.scale + 1) * Constants.GAME_WIDTH <= w && (Globals.scale + 1) * Constants.GAME_HEIGHT <= h) {
            Globals.scale = Globals.scale + 1
        }
    }

    static adjust_camera() {
        var conf = Renderer.get_config()
        var x = (conf["window_width"] - (Globals.scale * Constants.GAME_WIDTH)) / 2
        var y = (conf["window_height"] - (Globals.scale * Constants.GAME_HEIGHT)) / 2
        //Globals.camera.x_on_screen = x
        //Globals.camera.y_on_screen = y
        //Globals.camera.w_on_screen = Globals.scale * Constants.GAME_WIDTH
        //Globals.camera.h_on_screen = Globals.scale * Constants.GAME_HEIGHT
        Globals.camera.width = Constants.GAME_WIDTH
        Globals.camera.height = Constants.GAME_HEIGHT
        Globals.camera.zoom = 1
        Globals.camera.update()
    }

    static draw_game_surface() {
        var conf = Renderer.get_config()
        var x = (conf["window_width"] - (Globals.scale * Constants.GAME_WIDTH)) / 2
        var y = (conf["window_height"] - (Globals.scale * Constants.GAME_HEIGHT)) / 2
        Renderer.draw_texture(Globals.game_surf, x, y, Globals.scale, Globals.scale, 0, 0, 0)
    }

    static change_area(new_area, level) {
        Globals.area = new_area
        Engine.switch_level(level.new())
    }

    static reload_area() {
        load_area(Globals.area)
    }

    static init_area(level) {
        var s = Globals.area.split("#")
        s[1] = Num.fromString(s[1])
        var ret = level.load("assets/" + s[0] + ".tmj")
        var p = level.add_entity(Player)
        var x = 0
        var y = 0
        var markers = level.get_entities(Marker)
        for (i in markers) {
            if (s[1] == i.id) {
                x = i.x
                y = i.y
                break
            }
        }
        p.x = x
        p.y = y

        // Setup camera initial position
        Globals.camera.x = (p.x + 4) - (Constants.GAME_WIDTH / 2)
        Globals.camera.y = (p.y + 6) - (Constants.GAME_HEIGHT / 2)
        Globals.camera.update()
        return ret
    }
}