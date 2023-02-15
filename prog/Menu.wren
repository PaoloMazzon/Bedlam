import "lib/Engine" for Level
import "lib/Renderer" for Renderer, Camera
import "lib/Drawing" for Surface
import "lib/Input" for Gamepad
import "State" for Globals, Constants
import "Util" for Util
import "Area" for Area

class Menu is Level {
    construct new() { }
    
    create() {
        super.create()
        Globals.camera = Camera.new()
        Util.maximize_scale()
        Gamepad.stick_deadzone = 0.3
    }

    update() {
        Util.adjust_camera()

        // TODO: Add a menu
        Util.change_area(Globals.area, Area)

        super.update()
    }

    destroy() {
        super.destroy()
    }
}