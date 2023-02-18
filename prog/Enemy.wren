import "lib/Engine" for Engine, Entity, Level
import "lib/Util" for Math
import "State" for Balance

class Enemy {
    hp { _hp }
    is_dead { _hp == 0 }

    take_damage(dmg) {
        Math.clamp(_hp = _hp - dmg, 0, hp)
        level.pause(Balance.HIT_FREEZE_DELAY)
    }

    construct new() {
        super()
        _hp = Balance.BASE_ENEMY_HP
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _level = level
    }

    update(level) {
        super.update(level)
        if (is_dead) {
            level.remove_entity(this)
        }
    }
}