import "lib/Engine" for Engine
import "lib/Util" for Hitbox, Math
import "lib/Renderer" for Renderer
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Spikeball is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (is_alt) {
            player.take_damage(15)
        } else {
            player.take_damage(10)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hp = 20
        _length = 16
        _speed = 0.1
        _rotation = 0
        _first = true
        hitbox = Hitbox.new_rectangle(16, 16)
        hitbox.x_offset = 8
        hitbox.y_offset = 8
        if (tiled_data["properties"].containsKey("length")) {
            _length = tiled_data["properties"]["length"]
        }
        if (tiled_data["properties"].containsKey("speed")) {
            _speed = tiled_data["properties"]["speed"]
        }
        if (tiled_data["properties"].containsKey("rotation")) {
            _rotation = tiled_data["properties"]["rotation"]
        }
    }

    update(level) {
        if (_first) {
            _first = false
            _original_x = x
            _original_y = y
        }

        if (level.is_paused) {
            return
        }
        
        x = _original_x + Math.cast_x(_length, _rotation)
        y = _original_y + Math.cast_y(_length, _rotation)
        _rotation = _rotation + _speed
    }

    draw(level) {
        Renderer.set_colour_mod([0.1, 0.1, 0.1, 1])
        Renderer.draw_line(_original_x, _original_y, x, y)
        Renderer.set_colour_mod([1, 1, 1, 1])
        Renderer.draw_texture(Assets.tex_spike, x - 8, y - 8)
    }
}