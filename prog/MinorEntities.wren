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
    static create_hit_effect(level, x, y, rotation) {
        var h = level.add_entity(Hit)
        h.x = x
        h.y = y
        h.sprite.rotation = rotation
    }

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

class TeleportSilhouette is Entity {
    
    static create_teleport_silhouette(level, x, y, spr, facing, frame) {
        var t = level.add_entity(TeleportSilhouette)
        t.sprite = spr.copy()
        t.facing = facing
        t.frame = frame
        t.x = x
        t.y = y
    }
    
    facing=(s) { _facing = s }
    frame=(s) { _frame = s }

    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = Constants.SILHOUETTE_DURATION_FRAMES
        _frame = 0
        _facing = 0
    }

    update(level) {
        if (_duration <= 0) {
            level.remove_entity(this)
        }
        _duration = _duration - 1
    }

    draw(level) {
        Renderer.set_colour_mod([0, 0, 0, _duration / Constants.SILHOUETTE_DURATION_FRAMES])
        sprite.scale_x = _facing
        if (_facing == -1) {
            Renderer.draw_sprite(sprite, _frame, x + 8, y)
        } else {
            Renderer.draw_sprite(sprite, _frame, x, y)
        }
        Renderer.set_colour_mod([1, 1, 1, 1])
    }
}