import "lib/Engine" for Entity, Level, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox, Math
import "lib/Input" for Gamepad, Keyboard
import "State" for Globals, Constants, Balance
import "Assets" for Assets

class Player is Entity {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hitbox = Hitbox.new_rectangle(6, 12)
        hitbox.x_offset = -1
        _speed = 1.2
        _hspeed = 0
        _vspeed = 0
        _jumps = 0
        _max_jumps = 0
        _jump_height = 2
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)

        _hspeed = 0

        // Left/right
        if (Keyboard.key(Keyboard.KEY_A) || Gamepad.button(0, Gamepad.BUTTON_DPAD_LEFT) || Gamepad.left_stick_x(0) < -0.3) {
            _hspeed = _hspeed - _speed
        }
        if (Keyboard.key(Keyboard.KEY_D) || Gamepad.button(0, Gamepad.BUTTON_DPAD_RIGHT) || Gamepad.left_stick_x(0) > 0.3) {
            _hspeed = _hspeed + _speed
        }

        // Jumping
        if (level.tileset.collision(hitbox, x, y + 1) && _jumps < _max_jumps) {
            _jumps = _max_jumps
        }
        if ((Keyboard.key_pressed(Keyboard.KEY_SPACE) || Gamepad.button_pressed(0, Gamepad.BUTTON_A)) && (_jumps > 0 || level.tileset.collision(hitbox, x, y + 1))) {
            if (_jumps > 0) {
                _jumps = _jumps - 1
            }
            _vspeed = -_jump_height
        }
        _vspeed = _vspeed + Balance.GRAVITY

        // Handle collisions
        if (level.tileset.collision(hitbox, x + _hspeed, y)) {
            while (!level.tileset.collision(hitbox, x + _hspeed.sign, y)) {
                x = x + _hspeed.sign
            }
            _hspeed = 0
        }
        if (level.tileset.collision(hitbox, x, y + _vspeed)) {
            while (!level.tileset.collision(hitbox, x, y + _vspeed.sign)) {
                y = y + _vspeed.sign
            }
            _vspeed = 0
        }
        x = x + _hspeed
        y = y + _vspeed

        var diff_x = ((x + 4) - (Constants.GAME_WIDTH / 2)) - Globals.camera.x
        var diff_y = ((y + 6) - (Constants.GAME_HEIGHT / 2)) - Globals.camera.y
        Globals.camera.x = Math.clamp(Globals.camera.x + (diff_x * 0.1), 0, level.tileset.width - Constants.GAME_WIDTH)
        Globals.camera.y = Math.clamp(Globals.camera.y + (diff_y * 0.1), 0, level.tileset.height - Constants.GAME_HEIGHT)
        Globals.camera.update()
    }

    draw(level) {
        Renderer.set_colour_mod([0, 0.5, 1, 1])
        Renderer.draw_rectangle_outline(x + 1, y, 6, 12, 0, 0, 0, 1)
        Renderer.set_colour_mod([1, 1, 1, 1])
    }
}