import "lib/Engine" for Engine, Entity, Level
import "lib/Util" for Math
import "State" for Balance

// Enemies handle their own physics here, nearly identical to the players
class Enemy is Entity {
    hp { _hp }
    is_dead { _hp == 0 }
    hspeed { _hspeed }
    vspeed { _vspeed }
    hspeed=(s) { _hspeed = s }
    vspeed=(s) { _vspeed = s }

    take_damage(dmg) {
        Math.clamp(_hp = _hp - dmg, 0, hp)
        level.pause(Balance.HIT_FREEZE_DELAY)
    }

    construct new() {
        super()
        _hp = Balance.BASE_ENEMY_HP
        _hspeed = 0
        _vspeed = 0
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _level = level
    }

    update(level) {
        super.update(level)

        // Movement
        vspeed = vspeed + Balance.GRAVITY

        // Handle collisions
        if (level.tileset.collision(hitbox, x + hspeed, y)) {
            while (!level.tileset.collision(hitbox, x + hspeed.sign, y)) {
                x = x + hspeed.sign
            }
            hspeed = 0
        }
        if (level.tileset.collision(hitbox, x, y + vspeed)) {
            while (!level.tileset.collision(hitbox, x, y + vspeed.sign)) {
                y = y + vspeed.sign
            }
            vspeed = 0
        }
        x = x + hspeed
        y = y + vspeed

        // Death (Skull emoji)
        if (is_dead) {
            level.remove_entity(this)
        }
    }
}