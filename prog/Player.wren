import "lib/Engine" for Entity, Level, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox, Math
import "lib/Input" for Gamepad, Keyboard
import "State" for Globals, Constants, Balance
import "Enemy" for Enemy
import "Assets" for Assets
import "Spells" for Bolt, Shock, Laser
import "Weapon" for Weapon
import "Item" for Item
import "Dialogue" for Dialogue
import "MinorEntities" for TeleportSilhouette, Hit, Platform

class Player is Entity {
    construct new() { super() }

    take_damage(damage) {
        _hp = Math.clamp(_hp - damage, 0, _hp)
        _level.pause(Balance.HIT_FREEZE_DELAY)
        _iframes = Balance.PLAYER_IFRAMES
    }

    drain_health(damage) { _hp = Math.clamp(_hp - damage, 0, _hp) }

    heal(hp) { _hp = Math.clamp(_hp + hp, _hp, _max_hp) }

    restore_mana(mana) { _mana = Math.clamp(_mana + mana, _mana, Balance.PLAYER_MANA) }

    // Returns true if the requested mana is available, false if not enough
    spend_mana(mana) {
        if (_mana >= mana) {
            _mana = Math.clamp(_mana - mana, 0, _mana)
            return true
        } else {
            return false
        }
    }

    drain_mana(mana) {
        _mana = Math.clamp(_mana - mana, 0, _mana)
    }

    is_dead { _hp == 0 }

    mana { _mana }
    hp { _hp }
    max_hp { _max_hp }
    health_potions { _health_potions }
    mana_potions { _mana_potions }
    has_bolt { _has_bolt }
    has_shock { _has_shock }
    has_laser { _has_laser }
    has_bow { _has_bow }
    has_lspell { _has_lspell }
    has_shortsword { _has_shortsword }
    has_mace { _has_mace }
    has_spear { _has_spear }
    has_rapier { _has_rapier }
    has_lweapon { _has_lweapon }
    unlock_bolt() { _has_bolt = true }
    unlock_shock() { _has_shock = true }
    unlock_laser() { _has_laser = true }
    unlock_bow() { _has_bow = true }
    unlock_lspell() { _has_lspell = true } 
    unlock_shortsword() { _has_shortsword = true }
    unlock_mace() { _has_mace = true }
    unlock_spear() { _has_spear = true }
    unlock_rapier() { _has_rapier = true }
    unlock_lweapon() { _has_lweapon = true }
    equipped_weapon { _equipped_weapon }
    get_health_potion() { _health_potions = _health_potions + 1 }
    get_mana_potion() { _mana_potions = _mana_potions + 1 }
    unlock_double_jump() { _max_jumps = _max_jumps + 1 }
    unlock_teleport() { _teleport = true }
    unlock_walljump() { _walljump = true }
    unlock_health_heart() {
        _max_hp = _max_hp + Balance.PLAYER_HP_BOOSTS
        _hp = _max_hp
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        // Sprite
        Assets.spr_player_fall.origin_x = 2
        Assets.spr_player_fall.origin_y = 2
        Assets.spr_player_run.origin_x = 2
        sprite = Assets.spr_player_idle

        // Hitbox
        hitbox = Hitbox.new_rectangle(6, 12)
        hitbox.x_offset = -1

        // Meta
        _level = level

        // Physics
        _speed = 1.2
        _hspeed = 0
        _vspeed = 0
        _max_jumps = Globals.max_jumps
        _jumps = _max_jumps
        _jump_height = 2
        _facing = 1
        _walljump = Globals.walljump
        _teleport = Globals.teleport
        _walljump_side = 0

        // Combat things
        _mana = Globals.player_mana
        _max_hp = Globals.max_player_hp
        _hp = Globals.player_hp
        _iframes = 0
        _flicker = 0

        // Spells & potions
        _has_bolt = Globals.player_has_bolt
        _has_shock = Globals.item_unlocked("shock")
        _has_laser = Globals.item_unlocked("laser")
        _has_bow = Globals.item_unlocked("bow")
        _has_lspell = Globals.item_unlocked("lspell")
        _health_potions = Globals.health_potions
        _mana_potions = Globals.mana_potions

        // Weapons
        _has_shortsword = Globals.player_has_shortsword
        _has_mace = Globals.item_unlocked("mace")
        _has_spear = Globals.item_unlocked("spear")
        _has_rapier = Globals.item_unlocked("rapier")
        _has_lweapon = Globals.item_unlocked("lweapon")
        _weapon_frames = Globals.equipped_weapon
        _equipped_weapon = Globals.equipped_weapon
    }

    platforming(level) {
        var left = false
        var right = false
        var jump = false
        var teleport = false

        if (_weapon_frames == 0) {
            var lshoulder = Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER)
            var rshoulder = Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)
            left = Keyboard.key(Keyboard.KEY_LEFT) || Gamepad.button(0, Gamepad.BUTTON_DPAD_LEFT) || Gamepad.left_stick_x(0) < -0.3
            right = Keyboard.key(Keyboard.KEY_RIGHT) || Gamepad.button(0, Gamepad.BUTTON_DPAD_RIGHT) || Gamepad.left_stick_x(0) > 0.3
            jump = (Keyboard.key_pressed(Keyboard.KEY_Z) || (!lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_A)))
            teleport = Keyboard.key_pressed(Keyboard.KEY_LSHIFT) || (!lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_B))
        }

        y = y + 1
        var on_ground = level.tileset.collision(hitbox, x, y) || level.entity_collision(this, Platform)
        y = y - 1

        _hspeed = 0
        if (left) {
            _hspeed = _hspeed - _speed
            _facing = -1
        }
        if (right) {
            _hspeed = _hspeed + _speed
            _facing = 1
        }

        // Jumping
        if (on_ground && _jumps < _max_jumps) {
            _jumps = _max_jumps
            _walljump_side = 0
        }
        if (jump && (_jumps > 0 || on_ground)) {
            if (_jumps > 0 && !level.tileset.collision(hitbox, x, y + 1)) {
                _jumps = _jumps - 1
                Hit.create_hit_effect(level, x + 4, y + 12, -Num.pi / 2)
            }
            _vspeed = -_jump_height
        }
        _vspeed = _vspeed + Balance.GRAVITY

        // Wall jump
        if (_walljump && _weapon_frames == 0) {
            // Slow down when clutching to wall
            if (level.tileset.collision(hitbox, x + _facing, y) && level.tileset.collision(hitbox, x + _facing, y + 8) && !level.tileset.collision(hitbox, x, y + 8) && (left || right)) {
                if (_vspeed > 0) {
                    _vspeed = _vspeed / 2
                    if (jump && _walljump_side != _facing) {
                        _walljump_side = _facing
                        _vspeed = -_jump_height
                        _hspeed = _facing * -2
                        _facing = -_facing
                        if (_facing == 1) {
                            Hit.create_hit_effect(level, x + 4, y + 12, Num.pi / -4)
                        } else {
                            Hit.create_hit_effect(level, x + 4, y + 12, Num.pi / 4)
                        }
                    }
                }
            }
        }

        // Teleport
        if (!level.tileset.collision(hitbox, x + (Balance.TELEPORT_RANGE * _facing), y) && teleport && _teleport && x + (Balance.TELEPORT_RANGE * _facing) < (level.tileset.width - 8) && x + (Balance.TELEPORT_RANGE * _facing) > 8) {
            TeleportSilhouette.create_teleport_silhouette(level, x, y, sprite, _facing, sprite.frame)
            x = x + (Balance.TELEPORT_RANGE * _facing)
        } else if (x + (Balance.TELEPORT_RANGE * _facing) < level.tileset.width - 8 && x + (Balance.TELEPORT_RANGE * _facing) > 8 && teleport && _teleport) {
            TeleportSilhouette.create_teleport_silhouette(level, x, y, sprite, _facing, sprite.frame)
            while (!level.tileset.collision(hitbox, x + _facing, y)) {
                x = x + _facing
            }
        }
    }

    collisions(level) {
        // Walk up 1 block slopes
        if (level.tileset.collision(hitbox, x + _hspeed, y) && level.tileset.collision(hitbox, x, y + 1) && !level.tileset.collision(hitbox, x + _hspeed, y - 8)) {
            var counter = 0
            while (level.tileset.collision(hitbox, x + _hspeed, y) && counter < 10) {
                counter = counter + 1
                y = y - 1
            }
            y = y - 1
        }

        if (level.tileset.collision(hitbox, x + _hspeed, y)) {
            while (!level.tileset.collision(hitbox, x + _hspeed.sign, y)) {
                x = x + _hspeed.sign
            }
            _hspeed = 0
        }
        if (level.tileset.collision(hitbox, x, y + _vspeed)) {
            while (!level.tileset.collision(hitbox, x, y + _vspeed.sign)) {
                y = y + _vspeed.sign
            }
            _vspeed = 0
            _walljump_side = 0
        }
        y = y + _vspeed
        var platform = level.entity_collision(this, Platform)
        y = y - _vspeed
        var on_platform = false
        if (platform != null && y + hitbox.h < platform.y) {
            while (!platform.hitbox.collision(platform.x, platform.y, x, y + 1, hitbox)) {
                y = y + 1
            }
            _vspeed = 0
            on_platform = true
            _walljump_side = 0
        }
        x = x + _hspeed
        y = y + _vspeed

        // Animations
        if (_weapon_frames == 0) {
            if (_hspeed != 0) {
                sprite = Assets.spr_player_run
            } else {
                sprite = Assets.spr_player_idle
            }
            if (_vspeed > 0 && !level.tileset.collision(hitbox, x, y + 1) && !on_platform) {
                sprite = Assets.spr_player_fall
            } else if (_vspeed < 0) {
                sprite = Assets.spr_player_jump
            }
        }
    }

    combat(level) {
        if (_iframes > 0) {
            _iframes = _iframes - 1
        }
        _flicker = _flicker + 1
        if (_flicker == 10) {
            _flicker = 0
            if (_hspeed != 0 && _equipped_weapon == Constants.WEAPON_LEGEND) {
                TeleportSilhouette.create_teleport_silhouette_blue(level, x, y, sprite, _facing, sprite.frame)
            }
        }

        var enemy = level.entity_collision(this, Enemy)
        if (enemy != null && _iframes == 0) {
            enemy.hit_effect(this)
        }
    }

    potions(level) {
        var health_potion = false
        var mana_potion = false

        if (_weapon_frames == 0) {
            var lshoulder = Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER)
            var rshoulder = Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)
            health_potion = Keyboard.key_pressed(Keyboard.KEY_W) || (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_A))
            mana_potion = Keyboard.key_pressed(Keyboard.KEY_Q) || (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_Y))
        }

        if (mana_potion) {
            if (_mana_potions > 0) {
                _mana_potions = _mana_potions - 1
                restore_mana(Balance.PLAYER_MANA * Balance.MANA_POTION)
            }
        }
        if (health_potion) {
            if (_health_potions > 0) {
                _health_potions = _health_potions - 1
                heal(_max_hp * Balance.HEALTH_POTION)
            }
        }
    }

    spells(level) {
        var bolt_cast = false
        var shock_cast = false
        var laser_cast = false

        if (_weapon_frames == 0) {
            var lshoulder = Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER)
            var rshoulder = Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)
            bolt_cast = (Keyboard.key_pressed(Keyboard.KEY_A) || (lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_A)))
            shock_cast = lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_B)
            laser_cast = lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_Y)
        }

        restore_mana(Balance.MANA_RESTORATION)
        if (_mana < Balance.MANA_DAMAGE_THRESHHOLD) {
            drain_health(Balance.MANA_BURN)
        }
        if (bolt_cast && _has_bolt && spend_mana(Balance.BOLT_COST)) {
            var dir = 0
            var xx = x + 8
            if (_facing == -1) {
                dir = 3.141592635
                xx = x
            }
            Bolt.cast(level, xx, y + 6, dir)
        } else if (shock_cast && _has_shock && spend_mana(Balance.SHOCK_COST)) {
            var xx = x + 16
            if (_facing == -1) {
                xx = x - 8
            }
            Shock.cast(level, xx, y + 6, _facing, 0)
        } else if (laser_cast && _has_laser && spend_mana(Balance.LASER_COST)) {
            var xx = x + 8
            if (_facing == -1) {
                xx = x
            }
            Laser.cast(level, xx, y + 6, _facing)
        }
    }

    weapons(level) {
        var weapon_swing = false
        var weapon_alt = false
        var equip_shortsword = false
        var equip_mace = false

        if (_weapon_frames == 0) {
            var lshoulder = Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER)
            var rshoulder = Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)
            weapon_swing = Keyboard.key_pressed(Keyboard.KEY_X) || (!lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_X))
            weapon_alt = Keyboard.key_pressed(Keyboard.KEY_C) || (!lshoulder && !rshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_Y))
            equip_shortsword = Keyboard.key_pressed(Keyboard.KEY_1) || (rshoulder && !lshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_A))
            equip_mace = (rshoulder && !lshoulder && Gamepad.button_pressed(0, Gamepad.BUTTON_B))
        }

        if (_weapon_frames > 0) {
            _weapon_frames = _weapon_frames - 1
            if (_weapon_frames == 0) {
                sprite = Assets.spr_player_idle
            }
        }
        if (equip_shortsword && _has_shortsword) {
            _equipped_weapon = Constants.WEAPON_SHORTSWORD
        } else if (equip_mace && _has_mace) {
            _equipped_weapon = Constants.WEAPON_MACE
        }
        if ((weapon_swing || weapon_alt) && _equipped_weapon != 0) {
            var w = level.add_entity(Weapon)
            _weapon_frames = w.set_weapon(_equipped_weapon, weapon_alt, this)
            sprite = Weapon.weapon_sprite(_equipped_weapon, weapon_alt)
            w.x = x + 8 + (w.hitbox.w / 2)
            w.y = y + 6
            if (_facing == -1) {
                w.x = x - (w.hitbox.w / 2)
            }

            // Add another hitbox if its the mace swinging
            if (_equipped_weapon == Constants.WEAPON_MACE && weapon_alt) {
                var ww = level.add_entity(Weapon)
                ww.set_weapon(_equipped_weapon, weapon_alt, this)
                ww.x = x + 8 + (ww.hitbox.w / 2)
                ww.y = y + 6
                if (_facing == 1) {
                    ww.x = x - (w.hitbox.w / 2)
                }
            }
        }
    }

    pickups(level) {
        var item = level.entity_collision(this, Item)
        if (item != null) {
            item.pickup_effect(level, this)
        }
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)

        platforming(level)
        collisions(level)
        combat(level)
        potions(level)
        spells(level)
        weapons(level)
        pickups(level)

        // Camera
        level.set_focus(x, y)
    }

    draw(level) {
        if (_iframes == 0 || (_iframes > 0 && _flicker > 4)) {
            sprite.scale_x = _facing
            var draw_x = x + 1
            if (_facing == -1) { draw_x = draw_x + 8 }
            if (!level.is_paused) {
                Renderer.draw_sprite(sprite, draw_x, y)
            } else {
                Renderer.draw_sprite(sprite, sprite.frame, draw_x, y)
            }
        }
    }

    destroy(level) {
        super.destroy(level)
        if (!is_dead) {
            Globals.player_mana = _mana
            Globals.player_hp = _hp
            Globals.max_player_hp = _max_hp
            Globals.health_potions = _health_potions
            Globals.mana_potions = _mana_potions
            Globals.player_has_bolt = _has_bolt
            Globals.player_has_shortsword = _has_shortsword
            Globals.equipped_weapon = _equipped_weapon
            Globals.max_jumps = _max_jumps
            Globals.walljump = _walljump
            Globals.teleport = _teleport
            Globals.save_to_file()
        } else {
            Globals.reload()
        }
    }
}