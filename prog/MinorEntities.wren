import "lib/Engine" for Entity
import "lib/Renderer" for Renderer
import "State" for Constants
import "Assets" for Assets

class Death is Entity { // death animations
    construct new() { super() }

    create(level, tiled_data) {
        sprite = Assets.spr_death.copy()
    }

    update(level) {
        if (sprite.frame == 6) {
            level.remove_entity(this)
        }
    }
}

class Hit is Entity { // hitting animations
    construct new() { super() }

    create(level, tiled_data) {
        sprite = Assets.spr_hit.copy()
        sprite.origin_x = 4
        sprite.origin_y = 4
    }

    update(level) {
        if (sprite.frame == 5) {
            level.remove_entity(this)
        }
    }
}

class FloatingText is Entity {
    static create_floating_text(level, text, x, y) {
        var e = level.add_entity(FloatingText)
        e.x = x - ((text.count * 8) / 2)
        e.y = y
        e.text = text
    }

    text=(s) { _text = s }

    construct new() { super() }

    create(level, tiled_data) {
        _text = ""
        _duration = Constants.FLOATING_TEXT_DURATION_FRAMES
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        _duration = _duration - 1
        if (_duration <= 0) {
            level.remove_entity(this)
        }
    }

    draw(level) {
        var p = _duration / Constants.FLOATING_TEXT_DURATION_FRAMES
        Renderer.set_colour_mod([1, 1, 1, p])
        Renderer.draw_font(Assets.fnt_font, _text, x, y - ((1 - p) * 10))
        Renderer.set_colour_mod([1, 1, 1, 1])
    }
}