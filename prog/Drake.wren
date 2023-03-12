import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Drake is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (is_alt) {
            player.take_damage(8)
        } else {
            player.take_damage(5)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_drake.copy()
        hitbox = Hitbox.new_rectangle(16, 10)
        hspeed = 0.65
        affected_by_gravity = false
        if (is_alt) {
            hp = 30
        } else {
            hp = 20
        }
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (is_stunned) {
            return
        }

        if (level.tileset.collision(hitbox, x + hspeed, y) || x + hspeed > level.tileset.width - 16 || x + hspeed < 0) {
            hspeed = -hspeed
            facing = hspeed.sign
        }
    }
}