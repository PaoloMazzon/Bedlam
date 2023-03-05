import "lib/Engine" for Entity
import "lib/Util" for Hitbox, Math
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
        } else if (s == Constants.WEAPON_MACE) {
            if (!alt) {
                spr = Assets.spr_mace_1
                spr.origin_y = 4
            } else {
                spr = Assets.spr_mace_2
                spr.origin_x = 8
                spr.origin_y = 4
            }
        } else if (s == Constants.WEAPON_SPEAR) {
            if (!alt) {
                spr = Assets.spr_spear_1
            } else {
                spr = Assets.spr_spear_2
                spr.origin_y = 12
            }
        } else if (s == Constants.WEAPON_RAPIER) {
            spr = Assets.spr_rapier_1
        } else if (s == Constants.WEAPON_LEGEND) {
            spr = Assets.spr_magicsword_1
        }
        spr.frame = 0
        return spr
    }

    static weapon_icon(wep) {
        if (wep == Constants.WEAPON_SHORTSWORD) {
            return Assets.tex_shortsword_icon
        } else if (wep == Constants.WEAPON_MACE) {
            return Assets.tex_mace_icon
        } else if (wep == Constants.WEAPON_RAPIER) {
            return Assets.tex_rapier_icon
        } else if (wep == Constants.WEAPON_SPEAR) {
            return Assets.tex_spear_icon
        } else if (wep == Constants.WEAPON_LEGEND) {
            return Assets.tex_magicsword_icon
        }
        return null
    }

    get_hitbox(wep, alt) {
        if (wep == Constants.WEAPON_SHORTSWORD || wep == Constants.WEAPON_RAPIER || wep == Constants.WEAPON_LEGEND) {
            hitbox = Hitbox.new_rectangle(8, 8)
            hitbox.x_offset = 4
            hitbox.y_offset = 4
        } else if (wep == Constants.WEAPON_MACE) {
            hitbox = Hitbox.new_rectangle(8, 8)
            hitbox.x_offset = 4
            hitbox.y_offset = 4
        } else if (wep == Constants.WEAPON_SPEAR) {
            if (!alt) {
                hitbox = Hitbox.new_rectangle(16, 8)
                hitbox.x_offset = 8
                hitbox.y_offset = 4
            } else {
                hitbox = Hitbox.new_rectangle(16, 16)
                hitbox.x_offset = 4
                hitbox.y_offset = 8
            }
        }
    }

    // Return's the weapons duration
    set_weapon(s, alt, player) {
        _weapon = s
        if (s == Constants.WEAPON_RAPIER && alt) {
            _hspeed = player.facing * Balance.RAPIER_ALT_SPEED
        }
        var spr = Weapon.weapon_sprite(s, alt)
        _duration = ((spr.frame_count) * spr.delay * 60).round
        get_hitbox(s, alt)
        _alt = alt
        _player = player
        return _duration
    }

    hit_effect(level, enemy) {
        if (_weapon == Constants.WEAPON_SHORTSWORD) {
            if (!_alt) {
                enemy.take_damage(Balance.SHORTSWORD_DAMAGE)
            } else {
                enemy.take_damage(Balance.SHORTSWORD_DAMAGE / 2)
                enemy.knockback((enemy.x - _player.x).sign * 1, -2)
            }
        } else if (_weapon == Constants.WEAPON_MACE) {
            if (!_alt) {
                enemy.take_damage(Balance.MACE_DAMAGE)
            } else {
                enemy.take_damage(Balance.MACE_DAMAGE * 0.75)
                enemy.knockback((enemy.x - _player.x).sign * 1, 0)
            }
        } else if (_weapon == Constants.WEAPON_RAPIER) {
            if (!_alt) {
                enemy.take_damage(Balance.RAPIER_DAMAGE)
            } else {
                enemy.take_damage(Balance.RAPIER_DAMAGE * 1.25)
                enemy.knockback((enemy.x - _player.x).sign * Balance.RAPIER_ALT_SPEED, 1)
            }
        } else if (_weapon == Constants.WEAPON_SPEAR) {
            enemy.take_damage(Balance.SPEAR_DAMAGE)
        } else if (_weapon == Constants.WEAPON_LEGEND) {
            enemy.take_damage(Balance.LEGEND_DAMAGE)
        }
        _duration = 0
    }
    
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = 0
        _weapon = 0
        _alt = false
        _player = null
        _hspeed = 0
    }

    update(level) {
        _duration = _duration - 1
        x = x + _hspeed
        if (_hspeed != 0 && level.tileset.collision(hitbox, x, y)) {
            level.remove_entity(this)
        }
        if (_duration <= 0) {
            level.remove_entity(this)
        }
    }
}