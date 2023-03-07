import "lib/Engine" for Entity
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "State" for Constants, Globals
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

    static create_teleport_silhouette_blue(level, x, y, spr, facing, frame) {
        var t = level.add_entity(TeleportSilhouette)
        t.sprite = spr.copy()
        t.facing = facing
        t.frame = frame
        t.x = x
        t.y = y
        t.blue = true
    }
    
    facing=(s) { _facing = s }
    frame=(s) { _frame = s }
    blue=(s) { _blue = s }

    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = Constants.SILHOUETTE_DURATION_FRAMES
        _frame = 0
        _facing = 0
        _blue = false
    }

    update(level) {
        if (_duration <= 0) {
            level.remove_entity(this)
        }
        _duration = _duration - 1
        if (_blue) {
            _duration = _duration - 4
        }
    }

    draw(level) {
        if (_blue) {
            Renderer.set_colour_mod([0, 0.5, 1, _duration / Constants.SILHOUETTE_DURATION_FRAMES])
        } else {
            Renderer.set_colour_mod([0, 0, 0, _duration / Constants.SILHOUETTE_DURATION_FRAMES])
        }
        sprite.scale_x = _facing
        if (_facing == -1) {
            Renderer.draw_sprite(sprite, _frame, x + 8, y)
        } else {
            Renderer.draw_sprite(sprite, _frame, x, y)
        }
        Renderer.set_colour_mod([1, 1, 1, 1])
    }
}

class Light is Entity {
    construct new() {}

    radius { _radius + _mod }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _radius = 10
        _mod = 0
        _refresh = 3
        if (tiled_data != null && tiled_data["properties"].containsKey("light")) {
            _radius = tiled_data["properties"]["light"]
        }
    }

    update(level) {
        super.update(level)
        if (_refresh == 0) {
            _refresh = 3
            _mod = Globals.rng.int(-1, 2)
        } else {
            _refresh = _refresh - 1
        }
    }
}

class Platform is Entity {
    construct  new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hitbox = Hitbox.new_rectangle(tiled_data["width"], tiled_data["height"])
    }
}