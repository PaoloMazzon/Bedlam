import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class Soldier is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (_attack_timer > 0) {
            if (is_alt) {
                player.take_damage(18)
            } else {
                player.take_damage(13)
            }
        } else {
            if (is_alt) {
                player.take_damage(8)
            } else {
                player.take_damage(5)
            }
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _idle_sprite = Assets.spr_soldier_idle.copy()
        _attack_sprite = Assets.spr_soldier_agro.copy()

        sprite = Assets.spr_soldier_idle.copy()
        hitbox = Hitbox.new_rectangle(8, 12)
        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
        _stand_delay = -1
        if (is_alt) {
            hp = 100
            drop_chance = 1 / 4
        } else {
            hp = 55
            drop_chance = 1 / 6
        }
        _on_ground_last_frame = true
        _attack_timer = -1
        _wait_timer = 60
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (is_stunned) {
            return
        }

        // Walk and stand around
        var on_ground = level.tileset.collision(hitbox, x, y + 1)
        if (on_ground && !_on_ground_last_frame) {
            hspeed = 0
        }
        if (level.tileset.collision(hitbox, x, y + 1)) {
            if (!near_player && _attack_timer == -1) {
                sprite = _idle_sprite

                // Stop attacking if the player walked away
                if (_attack_timer > -1) {
                    hspeed = 0
                    _attack_timer = -1
                }

                if (_walk_delay != -1) {
                    _walk_delay = _walk_delay - 1
                    if (_walk_delay == 0) {
                        _walk_delay = -1
                        _stand_delay = Globals.rng.int(1 * 60, 4 * 60)
                        hspeed = Globals.rng.sample([-0.5, 0.5])
                        facing = hspeed.sign
                    }
                } else if (_stand_delay != -1) {
                    _stand_delay = _stand_delay - 1
                    if (_stand_delay == 0) {
                        _stand_delay = -1
                        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
                        hspeed = 0
                    }
                }

                // Don't walk off cliffs or into walls
                if (!level.tileset.collision(hitbox, x + (8 * hspeed.sign) + hspeed, y + 1) || level.tileset.collision(hitbox, x + hspeed, y)) {
                    _stand_delay = -1
                    _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
                    hspeed = 0
                }
            } else {
                _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
                _stand_delay = -1

                if (_attack_timer == -1 && _wait_timer == -1) {
                    _wait_timer = 60
                }

                sprite = _attack_sprite
                // Either wait to attack or sprint at the player
                if (_wait_timer >= 0) {
                    _wait_timer = _wait_timer - 1
                    hspeed = 0
                    if (_wait_timer == -1) {
                        _attack_timer = 40
                        if (is_alt) {
                            hspeed = (level.player.x - x).sign * 1.8
                        } else {
                            hspeed = (level.player.x - x).sign * 1.4
                        }
                        facing = hspeed.sign
                    }
                } else {
                    _attack_timer = _attack_timer - 1
                    if (_attack_timer == -1) {
                        _wait_timer = 60
                    }
                }
            }
        }
        _on_ground_last_frame = on_ground
        
        if (hspeed == 0) {
            sprite.frame = 0
        }

        if (facing == -1) {
            sprite.origin_x = -8
        } else {
            sprite.origin_x = 0
        }
    }
}