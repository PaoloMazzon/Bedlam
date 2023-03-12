import "lib/Engine" for Engine
import "lib/Util" for Hitbox
import "Enemy" for Enemy
import "Assets" for Assets
import "State" for Globals

class GhostProjectile is Enemy {
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

class Ghost is Enemy {
    construct new() { super() }

    hit_effect(player) {
        if (is_alt) {
            player.take_damage(5)
        } else {
            player.take_damage(3)
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_ghost.copy()
        hitbox = Hitbox.new_rectangle(8, 12)
        _walk_delay = Globals.rng.int(1 * 60, 4 * 60)
        _stand_delay = -1
        hp = 35
        if (is_alt) {
            hp = hp + 10
        }
        _on_ground_last_frame = true
        _shoot_delay = 90
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
            if (!near_player) {
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
                // Shoot at the player
                facing = -(x - level.player.x).sign
                hspeed = 0
                _shoot_delay = _shoot_delay - 1
                if (_shoot_delay <= 0) {
                    _shoot_delay = 90
                    var e = level.add_entity(GhostProjectile)
                    e.x = x + (facing * 4)
                    e.y = y + 6
                    e.hspeed = facing * 3
                    e.facing = facing
                }
            }
        }
        _on_ground_last_frame = on_ground
    }
}