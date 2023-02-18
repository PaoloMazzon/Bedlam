import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets

class Skeleton is Enemy {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_skeleton.copy()
        sprite.delay = 0.5
        hitbox = Hitbox.new_rectangle(8, 12)
    }

    update(level) {
        super.update(level)
    }
}