import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Spikes is Enemy {
    construct new() { super() }

    hit_effect(player) {
        player.take_damage(10)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hitbox = Hitbox.new_rectangle(tiled_data["width"], tiled_data["height"])
        hp = 20
    }

    update(level) {
        
    }
}