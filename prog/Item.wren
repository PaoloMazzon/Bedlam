import "lib/Engine" for Entity, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "State" for Globals
import "Assets" for Assets

class Item is Entity {
    construct new() { super() }

    pickup_effect(level, player) {
        Globals.unlock_item(_item_id)
        level.remove_entity(this)

        if (_item_id == "shortsword") {
            player.unlock_shortsword()
        } else if (_item_id == "bolt") {
            player.unlock_bolt()
        }
    }

    create(level, tiled_data) {
        _item_id = tiled_data["properties"]["item"]
        if (Globals.item_unlocked(_item_id)) {
            level.remove_entity(this)
        }
        _texture = null
        hitbox = Hitbox.new_rectangle(10, 10)
        hitbox.y_offset = 8
        _first = true

        if (_item_id == "shortsword") {
            _texture = Assets.tex_shortsword_icon
        }

        if (_item_id == "bolt") {
            _texture = Assets.tex_bolt_icon
        }
    }

    update(level) {
        if (_first) {
            _first = false
            // Snap to the ground
            x = x.round
            y = y.round
            while (!level.tileset.collision(hitbox, x, y + 1)) {
                y = y + 1
            }
        }
    }

    draw(level) {
        Renderer.draw_texture(Assets.tex_item_holder, x, y)

        if (_texture != null) {
            var yy = (Engine.time * 2).sin
            Renderer.draw_texture(_texture, x + 1, y - 11 + yy)
        }
    }
}