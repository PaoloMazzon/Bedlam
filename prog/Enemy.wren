import "lib/Engine" for Engine, Entity, Level
import "lib/Util" for Math
import "lib/Renderer" for Renderer
import "State" for Balance, Globals
import "Spells" for Spell
import "Weapon" for Weapon
import "MinorEntities" for Death
import "Item" for Item

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
    facing { _facing }
    facing=(s) { _facing = s }
    is_alt { _alt }
    invincible=(s) { _invincible = s }
    invincible { _invincible }
    affected_by_gravity { _gravity }
    affected_by_gravity=(s) { _gravity = s }
    no_random_drops=(s) { _no_random_drops = s }
    no_random_drops { _no_random_drops }
    near_player { (_level.player.y - y).abs < 18 && (_level.player.x - x).abs < 80 }
    
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

    hit_effect(player) { } // called when the player touches this enemy

    construct new() {
        super()
        _hp = Balance.BASE_ENEMY_HP
        _hspeed = 0
        _vspeed = 0
        _iframes = 0
        _stun_timer = 0
        _facing = 1
        _item = null
        _alt = false
        _invincible = false
        _gravity = true
        _no_random_drops = false
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _level = level
        if (tiled_data != null) {
            if (tiled_data["properties"].containsKey("item")) {
                _item = tiled_data["properties"]["item"]
            }
            if (tiled_data["properties"].containsKey("alt")) {
                _alt = tiled_data["properties"]["alt"]
            }
            if (tiled_data["properties"].containsKey("requires")) {
                var requires = tiled_data["properties"]["requires"]
                if (!Globals.item_unlocked(requires)) {
                    level.remove_entity(this)
                }
            }
        }
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)

        // Movement
        if (_gravity) {
            vspeed = vspeed + Balance.GRAVITY
        }

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
        x = Math.clamp(x, 0, level.tileset.width - sprite.width)

        // Get hit by spells & weapons
        var spell = level.entity_collision(this, Spell)
        if (spell != null && _iframes == 0 && !_invincible) {
            spell.hit_effect(level, this)
        }
        var wep = level.entity_collision(this, Weapon)
        if (wep != null && _iframes == 0 && !_invincible) {
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
        if (sprite != null) {
            if (_iframes > 0) {
                Renderer.set_colour_mod([0, 0, 0, 1])
            } else if (_alt) {
                Renderer.set_colour_mod([1, 0.2, 0.2, 1])
            }
            sprite.scale_x = facing
            var draw_x = x
            if (facing == -1) {
                draw_x = draw_x + sprite.width
            }
            if (!level.is_paused) {
                Renderer.draw_sprite(sprite, draw_x, y)
            } else {
                Renderer.draw_sprite(sprite, sprite.frame, draw_x, y)

            }
            Renderer.set_colour_mod([1, 1, 1, 1])
        }
    }

    destroy(level) {
        super.destroy(level)

        if (_item != null) {
            Item.create_item(level, _item, x, y)
        } else if (!no_random_drops) {
            // Chance to get a potion
            var n = Globals.rng.int(20)
            if (n == 0) {
                Item.create_item(level, "health", x, y)
            } else if (n == 1) {
                Item.create_item(level, "mana", x, y)
            }
        }
    }
}