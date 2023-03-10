import "lib/Engine" for Engine, Entity
import "lib/Input" for Gamepad
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "State" for Globals
import "Assets" for Assets

class NPC is Entity {
    data { _data }
    data=(s) { _data = s }
    center_x { x + (sprite.width / 2) - 8 }
    center_y { y + (sprite.height / 2) }

    on_player_interact(level, player) { /* for child classes */ }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _data = ""
        if (tiled_data != null && tiled_data["properties"].containsKey("data")) {
            _data = tiled_data["properties"]["data"]
        }
        _colliding = false
        _first = true
    }

    update(level) {
        // Snap to the ground
        if (_first) {
            _first = false
            while (!level.tileset.collision(hitbox, x, y + 1)) {
                y = y + 1
            }
            y = y + 1
        }


        _colliding = hitbox.collision(x, y, level.player.x, level.player.y, level.player.hitbox)

        if (_colliding && Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_UP) && !level.is_paused) {
            on_player_interact(level, level.player)
        }
    }

    draw(level) {
        super.draw(level)
        if (_colliding && sprite != null) {
            Renderer.draw_texture(Assets.tex_uparrow, x + (sprite.width / 2) - 4, y - 11 + (Engine.time * 2).sin)
        }
    }
}

class SlimeNPC is NPC {
    on_player_interact(level, player) {
        // TODO: This
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_slimenpc
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
    }
}