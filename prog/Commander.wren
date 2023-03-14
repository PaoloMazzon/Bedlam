import "lib/Engine" for Engine, Entity
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox, Math
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals, Balance

class CommanderVictory is Entity {
    construct new() { super() }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _duration = 60 * 6
    }

    update(level) {
        super.update(level)
        _duration = _duration - 1
        if (_duration <= 0) {
            level.remove_entity(this)
        }
    }

    draw(level) {
        Renderer.set_texture_camera(false)
        if (_duration > 60 * 5) {
            // fade in
            var val = 1 - ((_duration - (60 * 5)) / 60)
            Renderer.draw_texture(Assets.tex_commanderslain, Math.serp(val, -160, 0), 52)
        } else if (_duration < 60) {
            // fade out
            var val = _duration / 60
            Renderer.draw_texture(Assets.tex_commanderslain, Math.serp(val, 160, 0), 52)
        } else {
            Renderer.draw_texture(Assets.tex_commanderslain, 0, 52)
        }
        Renderer.set_texture_camera(true)
    }
}

class CommanderTrigger is Enemy {
    construct new() { super() }

    hit_effect(player) {
        _level.remove_entity(this)
        var commander = _level.get_entity(Commander)
        _level.dialogue.queue("Bedlam.", commander.x + 16 - 4, commander.y + 16)
        _level.dialogue.queue("The Seer told me to expect you.", commander.x + 16 - 4, commander.y + 16)
        _level.dialogue.queue("You must be the commander.", player.x, player.y)
        _level.dialogue.queue("You won't be the first wraith I've slain.", commander.x + 16 - 4, commander.y + 16)

        if (Globals.event_has_happened("helped_ray")) {
            _level.dialogue.queue("Where's my enchantment?", commander.x + 16 - 4, commander.y + 16)
            _level.dialogue.queue("...", commander.x + 16 - 4, commander.y + 16)
            _level.dialogue.queue("Ray must have stolen it again.", commander.x + 16 - 4, commander.y + 16)
            _level.dialogue.queue("No matter, I deal with you first.", commander.x + 16 - 4, commander.y + 16)
            commander.damage_bonus = 1
        }
        _level.dialogue.queue("...", player.x, player.y)
        commander.begin_attacking()
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        affected_by_gravity = false
        hp = 1
        invincible = true
        no_random_drops = true
        hitbox = Hitbox.new_rectangle(tiled_data["width"], tiled_data["height"])
        _level = level
        if (Globals.event_has_happened("killed_commander")) {
            level.remove_entity(this)
        }
        sprite = Assets.spr_bolt
    }
}

class CommanderProjectile is Enemy {
    construct new() { super() }

    hit_effect(player) {
        player.take_damage(7)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        affected_by_gravity = false
        hp = 1
        invincible = true
        _duration = 60
        no_random_drops = true
        sprite = Assets.spr_bolt.copy()
        hitbox = Hitbox.new_rectangle(8, 8)
        hitbox.x_offset = 4
        hitbox.y_offset = 4
        sprite.origin_x = 4
        sprite.origin_y = 4
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (_duration > 0) {
            _duration = _duration - 1
            if (_duration <= 0 || level.tileset.collision(hitbox, x + hspeed, y)) {
                level.remove_entity(this)
            }
        }
    }
}

class Commander is Enemy {
    construct new() { super() }

    remove_walls(level) {
        for (i in 37..45) {
            level.tileset[i, 34] = 0
            level.tileset[i, 35] = 0
        }
        level.create_collision_surface()
    }

    hit_effect(player) {
        if (_attack_timer > 0) {
            player.take_damage(16 * _damage_bonus)
        } else {
            player.take_damage(10 * _damage_bonus)
        }
    }

    begin_attacking() { _attack_player = true }
    damage_bonus=(s) { _damage_bonus = s }
    is_agro { _attack_player }
    flux { _flux }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_commander_idle
        hitbox = Hitbox.new_rectangle(25, 28)
        hitbox.y_offset = -4
        _jump_delay = Globals.rng.int(0.5 * 60, 1 * 60)
        hp = Balance.COMMANDER_MAX_HEALTH
        _on_ground_last_frame = true
        _attack_player = false
        _damage_bonus = 1.2
        _die = false
        if (Globals.event_has_happened("killed_commander")) {
            _die = true
        }
        _jump_phase = 60  * 5
        _charge_phase = -1
        _attack_timer = -1
        _wait_timer = 60
        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
        _stand_delay = -1
        _flux = hp
    }

    update(level) {
        if (_die) {
            remove_walls(level)
            level.remove_entity(this)
        }
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (is_stunned || !_attack_player) {
            return
        }

        // Walk and stand around
        var on_ground = level.tileset.collision(hitbox, x, y + 1)
        
        if (_jump_phase > -1) {
            if (on_ground && _jump_delay > 0) {
                _jump_delay = _jump_delay - 1
                sprite = Assets.spr_commander_idle
                if (hspeed != 0) {
                    hspeed = hspeed - (hspeed.sign * 0.25)
                }
            } else if (on_ground && _jump_delay <= 0) {
                hspeed = (level.player.x - x).sign * 1.4
                if (level.tileset.collision(hitbox, x + hspeed.sign, y)) {
                    hspeed = -hspeed
                }
                vspeed = -3
                _jump_delay = Globals.rng.int(0.5 * 60, 1 * 60)
                facing = hspeed.sign
            }
            if (!on_ground) {
                sprite = Assets.spr_commander_air
            }
            _jump_phase =  _jump_phase - 1
            if (_jump_phase <= -1) {
                _charge_phase = 60 * 6
                _jump_phase = -1
                hspeed = 0
                _attack_timer = -1
                _wait_timer = 60
            }
        } else {
            if (_attack_timer == -1 && _wait_timer == -1) {
                _wait_timer = 60
            }

            sprite = Assets.spr_commander_run
            // Either wait to attack or sprint at the player
            if (_wait_timer >= 0) {
                _wait_timer = _wait_timer - 1
                hspeed = 0
                if (_wait_timer == -1) {
                    _attack_timer = 40
                    hspeed = (level.player.x - x).sign * 1.8
                    
                    facing = hspeed.sign
                }
            } else {
                _attack_timer = _attack_timer - 1
                if (_attack_timer == -1) {
                    _wait_timer = 60
                }
            }

            _charge_phase =  _charge_phase - 1
            if (_charge_phase <= -1) {
                _jump_phase = 60 * 6
                _charge_phase = -1
                hspeed = 0
                _jump_delay = Globals.rng.int(0.5 * 60, 1 * 60)
            }
        }

        _on_ground_last_frame = on_ground

        if (hp < _flux) {
            _flux = _flux - 0.5
        }
    }

    destroy(level) {
        super.destroy(level)

        if (is_dead) {
            level.add_entity(CommanderVictory)
            Globals.record_event("killed_commander")
            remove_walls(level)
        }
    }
}