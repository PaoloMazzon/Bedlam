import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Skeleton is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (is_alt) {
            player.take_damage(7)
        } else {
            player.take_damage(5)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_skeleton.copy()
        sprite.delay = 0.45
        hitbox = Hitbox.new_rectangle(8, 12)
        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
        _stand_delay = -1
        if (!is_alt) {
            hp = 40
        } else {
            hp = 70
        }
        _on_ground_last_frame = true
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (is_stunned) {
            return
        }

        // Walk and stand around
        var on_ground = level.tileset.collision(hitbox, x, y + 1)
        if (on_ground && !_on_ground_last_frame) {
            hspeed = 0
        }
        if (level.tileset.collision(hitbox, x, y + 1)) {
            if (_walk_delay != -1) {
                _walk_delay = _walk_delay - 1
                if (_walk_delay == 0) {
                    _walk_delay = -1
                    _stand_delay = Globals.rng.int(1 * 60, 4 * 60)
                    hspeed = Globals.rng.sample([-0.5, 0.5])
                    facing = hspeed.sign
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
        }
        _on_ground_last_frame = on_ground
    }
}