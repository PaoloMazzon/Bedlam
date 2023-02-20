import "lib/Engine" for Entity
import "lib/Util" for Hitbox
import "State" for Constants

// This is the instantaneous hitbox for weapons everything else in player
class Weapon {
    duration=(s) { _duration = s }
    weapon=(s) { _weapon = s }

    on_hit(enemy) {
        if (_weapon == Constants.WEAPON_SHORTSWORD) {
            enemy.take_damage(Balance.SHORTSWORD_DAMAGE)
        }
        _duration = 0
    }
    
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = 0
        _weapon = 0
    }

    update(level) {
        _duration = _duration - 1
        if (_duration <= 0) {
            level.remove_entity(this)
        }
    }
}