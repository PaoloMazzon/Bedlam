import "lib/Engine" for Engine, Entity, Level
import "lib/Util" for Math
import "lib/Renderer" for Renderer
import "State" for Balance
import "Spells" for Spell
import "Weapon" for Weapon
import "MinorEntities" for Death

// Enemies handle their own physics here, nearly identical to the players
class Enemy is Entity {
    hp { _hp }
    is_dead { _hp == 0 }
    hspeed { _hspeed }
    vspeed { _vspeed }
    hspeed=(s) { _hspeed = s }
    vspeed=(s) { _vspeed = s }
    hp=(s) { _hp = s }
    stun(frames) { _stun_timer = frames }
    is_stunned { _stun_timer > 0 }
    
    knockback(x, y) {
        _stun_timer = Balance.KNOCKBACK_STUN_FRAMES
        hspeed = x
        vspeed = y
    }

    take_damage(dmg) {
        _hp = Math.clamp(_hp - dmg, 0, hp)
        _level.pause(Balance.HIT_FREEZE_DELAY)
        _iframes = Balance.ENEMY_IFRAMES
    }

    construct new() {
        super()
        _hp = Balance.BASE_ENEMY_HP
        _hspeed = 0
        _vspeed = 0
        _iframes = 0
        _stun_timer = 0
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

        // Get hit by spells & weapons
        var spell = level.entity_collision(this, Spell)
        if (spell != null && _iframes == 0) {
            spell.hit_effect(level, this)
        }
        var wep = level.entity_collision(this, Weapon)
        if (wep != null && _iframes == 0) {
            wep.hit_effect(level, this)
        }

        // Death (Skull emoji)
        if (is_dead) {
            level.remove_entity(this)
            var d = level.add_entity(Death)
            d.x = x + (sprite.width / 2) - (d.sprite.width / 2)
            d.y = y + (sprite.height / 2) - (d.sprite.height / 2)
        }

        if (_iframes > 0) {
            _iframes = _iframes - 1
        }
        if (_stun_timer > 0) {
            _stun_timer = _stun_timer - 1
        }
    }

    draw(level) {
        if (_iframes > 0) {
            Renderer.set_colour_mod([0, 0, 0, 1])
        }
        super.draw(level)
        Renderer.set_colour_mod([1, 1, 1, 1])
    }
}