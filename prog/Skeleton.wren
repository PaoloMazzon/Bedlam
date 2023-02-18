import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Skeleton is Enemy {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_skeleton.copy()
        sprite.delay = 0.45
        hitbox = Hitbox.new_rectangle(8, 12)
        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
        _stand_delay = -1
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)

        // Walk and stand around
        if (_walk_delay != -1) {
            _walk_delay = _walk_delay - 1
            if (_walk_delay == 0) {
                _walk_delay = -1
                _stand_delay = Globals.rng.int(1 * 60, 4 * 60)
                hspeed = Globals.rng.sample([-0.5, 0.5])
            } else {
                sprite.frame = 0
            }
        } else if (_stand_delay != -1) {
            _stand_delay = _stand_delay - 1
            if (_stand_delay == 0) {
                _stand_delay = -1
                _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
                hspeed = 0
            }
        }

        // Don't walk off cliffs or into walls
        if (!level.tileset.collision(hitbox, x + (8 * hspeed.sign) + hspeed, y + 1) || level.tileset.collision(hitbox, x + hspeed, y)) {
            _stand_delay = -1
            _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
            hspeed = 0
        }

        // Animation
        if (hspeed > 0) {
            sprite.scale_x = -1
            sprite.origin_x = 8
        } else if (hspeed < 0) {
            sprite.scale_x = 1
            sprite.origin_x = 0
        }
    }
}