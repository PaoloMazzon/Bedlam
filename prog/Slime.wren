import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Slime is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (is_alt) {
            player.take_damage(8)
        } else {
            player.take_damage(6)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_slime.copy()
        hitbox = Hitbox.new_rectangle(12, 10)
        _jump_delay = Globals.rng.int(0.5 * 60, 1 * 60)
        hp = 35
        if (is_alt) {
            hp = hp + 15
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
        
        if (on_ground && _jump_delay > 0) {
            _jump_delay = _jump_delay - 1
            sprite.frame = 0
            if (hspeed != 0) {
                hspeed = hspeed - (hspeed.sign * 0.25)
            }
        } else if (on_ground && _jump_delay <= 0 && sprite.frame == 5) {
            hspeed = Globals.rng.sample([-1.25, 1.25])
            if (level.tileset.collision(hitbox, x + hspeed.sign, y)) {
                hspeed = -hspeed
            }
            if (is_alt) {
                vspeed = -3
            } else {
                vspeed = -1.75
            }
            _jump_delay = Globals.rng.int(0.5 * 60, 1 * 60)
            facing = hspeed.sign
        }

        _on_ground_last_frame = on_ground
    }
}