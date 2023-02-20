import "lib/Engine" for Entity
import "lib/Util" for Hitbox
import "State" for Constants, Balance
import "Assets" for Assets

// This is the instantaneous hitbox for weapons everything else in player
class Weapon is Entity {
    static weapon_sprite(s, alt) {
        var spr = null
        if (s == Constants.WEAPON_SHORTSWORD) {
            if (!alt) {
                spr = Assets.spr_shortsword_1
            } else {
                spr = Assets.spr_shortsword_2
                spr.origin_y = 4
            }
        }
        spr.frame = 0
        return spr
    }

    static weapon_icon(wep) {
        if (wep == Constants.WEAPON_SHORTSWORD) {
            return Assets.tex_shortsword_icon
        }
        return null
    }

    get_hitbox(wep, alt) {
        if (wep == Constants.WEAPON_SHORTSWORD) {
            hitbox = Hitbox.new_rectangle(8, 8)
            hitbox.x_offset = 4
            hitbox.y_offset = 4
        }
    }

    // Return's the weapons duration
    set_weapon(s, alt) {
        _weapon = s
        var spr = Weapon.weapon_sprite(s, alt)
        _duration = ((spr.frame_count) * spr.delay * 60).round
        get_hitbox(s, alt)
        return _duration
    }

    hit_effect(level, enemy) {
        if (_weapon == Constants.WEAPON_SHORTSWORD) {
            if (!_alt) {
                enemy.take_damage(Balance.SHORTSWORD_DAMAGE)
            } else {
                enemy.take_damage(Balance.SHORTSWORD_DAMAGE / 2)
                // TODO: Knockback
            }
        }
        _duration = 0
    }
    
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = 0
        _weapon = 0
        _alt = false
    }

    update(level) {
        _duration = _duration - 1
        if (_duration <= 0) {
            level.remove_entity(this)
        }
    }
}