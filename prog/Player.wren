import "lib/Engine" for Entity, Level, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox, Math
import "lib/Input" for Gamepad, Keyboard
import "State" for Globals, Constants, Balance
import "Enemy" for Enemy
import "Assets" for Assets
import "Spells" for Bolt

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
    has_bolt { _bolt }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        hitbox = Hitbox.new_rectangle(6, 12)
        hitbox.x_offset = -1

        // Meta
        _level = level

        // Physics
        _speed = 1.2
        _hspeed = 0
        _vspeed = 0
        _jumps = 0
        _max_jumps = 0
        _jump_height = 2
        _facing = 1

        // Combat things
        _mana = Globals.player_mana
        _max_hp = Globals.max_player_hp
        _hp = Globals.player_hp
        _iframes = 0
        _flicker = 0

        // Spells & potions
        _bolt = Globals.player_has_bolt
        _health_potions = Globals.health_potions
        _mana_potions = Globals.mana_potions
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)

        /****************** Platforming ******************/
        _hspeed = 0
        if (Keyboard.key(Keyboard.KEY_LEFT) || Gamepad.button(0, Gamepad.BUTTON_DPAD_LEFT) || Gamepad.left_stick_x(0) < -0.3) {
            _hspeed = _hspeed - _speed
            _facing = -1
        }
        if (Keyboard.key(Keyboard.KEY_RIGHT) || Gamepad.button(0, Gamepad.BUTTON_DPAD_RIGHT) || Gamepad.left_stick_x(0) > 0.3) {
            _hspeed = _hspeed + _speed
            _facing = 1
        }

        // Jumping
        if (level.tileset.collision(hitbox, x, y + 1) && _jumps < _max_jumps) {
            _jumps = _max_jumps
        }
        if ((Keyboard.key_pressed(Keyboard.KEY_Z) || (!Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_A))) && (_jumps > 0 || level.tileset.collision(hitbox, x, y + 1))) {
            if (_jumps > 0) {
                _jumps = _jumps - 1
            }
            _vspeed = -_jump_height
        }
        _vspeed = _vspeed + Balance.GRAVITY

        /****************** Collisions ******************/
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
        }
        x = x + _hspeed
        y = y + _vspeed

        /****************** Camera ******************/
        var diff_x = ((x + 4) - (Constants.GAME_WIDTH / 2)) - Globals.camera.x
        var diff_y = ((y + 6) - (Constants.GAME_HEIGHT / 2)) - Globals.camera.y
        Globals.camera.x = Math.clamp(Globals.camera.x + (diff_x * 0.1), 0, level.tileset.width - Constants.GAME_WIDTH)
        Globals.camera.y = Math.clamp(Globals.camera.y + (diff_y * 0.1), 0, level.tileset.height - Constants.GAME_HEIGHT)
        Globals.camera.update()

        /****************** Combat ******************/
        if (_iframes > 0) {
            _iframes = _iframes - 1
        }
        _flicker = _flicker + 1
        if (_flicker == 10) {
            _flicker = 0
        }

        /****************** Mana/Spell casting ******************/
        restore_mana(Balance.MANA_RESTORATION)
        if (_mana < Balance.MANA_DAMAGE_THRESHHOLD) {
            drain_health(Balance.MANA_BURN)
        }
        if ((Keyboard.key_pressed(Keyboard.KEY_A) || (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && !Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_A))) && spend_mana(Balance.BOLT_COST) && _bolt) {
            var dir = 0
            var xx = x + 8
            if (_facing == -1) {
                dir = 3.141592635
                xx = x
            }
            Bolt.cast(level, xx, y + 6, dir)
        }

        /****************** Potions ******************/
        if (Keyboard.key_pressed(Keyboard.KEY_Q) || (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_Y))) {
            if (_mana_potions > 0) {
                _mana_potions = _mana_potions - 1
                restore_mana(Balance.PLAYER_MANA * Balance.MANA_POTION)
            }
        }
        if (Keyboard.key_pressed(Keyboard.KEY_W) || (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER) && Gamepad.button_pressed(0, Gamepad.BUTTON_A))) {
            if (_health_potions > 0) {
                _health_potions = _health_potions - 1
                heal(_max_hp * Balance.HEALTH_POTION)
            }
        }

        // TODO: Enemies should do this, not the player
        var enemy = level.entity_collision(this, Enemy)
        if (enemy != null && _iframes == 0) {
            take_damage(3)
        }
    }

    draw(level) {
        if (_iframes == 0 || (_iframes > 0 && _flicker > 4)) {
            Renderer.set_colour_mod([0, 0.5, 1, 1])
            Renderer.draw_rectangle_outline(x + 1, y, 6, 12, 0, 0, 0, 1)
            Renderer.set_colour_mod([1, 1, 1, 1])
        }
    }

    destroy(level) {
        super.destroy(level)
        Globals.player_mana = _mana
        Globals.player_hp = _hp
        Globals.max_player_hp = _max_hp
        Globals.health_potions = _health_potions
        Globals.mana_potions = _mana_potions
    }
}