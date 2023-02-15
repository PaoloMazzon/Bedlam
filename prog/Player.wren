import "lib/Engine" for Entity, Level, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "lib/Input" for Gamepad
import "State" for Globals, Constants

class Player is Entity {
    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hitbox = Hitbox.new_rectangle(8, 12)
        hitbox.y_offset = 2
    }

    update(level) {
        super.update(level)

        x = x + (Gamepad.left_stick_x(0) * 10)
        y = y + (Gamepad.left_stick_y(0) * 10)

        Globals.camera.x = (x + 4) - (Constants.GAME_WIDTH / 2)
        Globals.camera.y = (y + 6) - (Constants.GAME_HEIGHT / 2)
        Globals.camera.update()
    }

    draw(level) {
        Renderer.set_colour_mod([0, 128, 255, 255])
        Renderer.draw_rectangle_outline(x, y, 8, 12, 0, 0, 0, 1)
        Renderer.set_colour_mod([255, 255, 255, 255])
    }
}