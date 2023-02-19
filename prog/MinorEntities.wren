import "lib/Engine" for Entity
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