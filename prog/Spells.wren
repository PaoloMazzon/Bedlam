import "lib/Engine" for Engine, Level, Entity
import "lib/Util" for Math, Hitbox
import "lib/Renderer" for Renderer
import "Assets" for Assets
import "MinorEntities" for Hit
import "State" for Globals

class Spell is Entity {
    set_velocity(dir, speed) {
        _direction = dir
        _speed = speed
    }

    set_duration(duration_in_seconds) { _duration = (duration_in_seconds * 60).round }
    
    set_penetrating() { _penetrates = true }

    is_static=(s) { _static = s }
    is_static { _static }

    // What should be called if something is hit by this spell -- override this and call the super
    hit_effect(level, entity) {
        if (!_penetrates) {
            level.remove_entity(this)
        }
        var hit = level.add_entity(Hit)
        hit.x = x
        hit.y = y
        hit.sprite.rotation = _direction
    }

    construct new() {
        _direction = 0
        _speed = 0
        _duration = 0
        _penetrates = false
        _static = false
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        _duration = _duration - 1
        if (!is_static) {
            x = x + Math.cast_x(_speed, _direction)
            y = y + Math.cast_y(_speed, _direction)
        }
        if (_duration <= 0 || (level.tileset.collision(hitbox, x, y) && !_penetrates)) {
            level.remove_entity(this)
            
            if (_duration > 0) {
                var hit = level.add_entity(Hit)
                hit.x = x
                hit.y = y
                hit.sprite.rotation = _direction
            }
        }
    }
}

class Bolt is Spell {
    construct new() { super() }

    hit_effect(level, entity) {
        super.hit_effect(level, entity)
        entity.take_damage(8)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_bolt.copy()
        hitbox = Hitbox.new_rectangle(8, 8)
        hitbox.x_offset = 4
        hitbox.y_offset = 4
        sprite.origin_x = 4
        sprite.origin_y = 4
    }

    static cast(level, x, y, dir) {
        var bolt = level.add_entity(Bolt)
        bolt.x = x
        bolt.y = y
        bolt.sprite.rotation = dir
        bolt.set_velocity(dir, 3)
        bolt.set_duration(0.5)
        Globals.play_sound(Assets.aud_bolt)
    }
}

class Shock is Spell {
    construct new() { super() }

    chain=(s) { _chain = s }

    hit_effect(level, entity) {
        super.hit_effect(level, entity)
        entity.take_damage(15)
        
        // Bounce to another entity
        var type = Engine.get_class("Enemy::Enemy")
        var enemies = level.get_entities(type)
        for (enemy in enemies) {
            if (enemy != entity && enemy.sprite != null && Math.point_distance(entity.x, entity.y, enemy.x, enemy.y) < 16 + enemy.sprite.width) {
                var facing = (enemy.x - entity.x).sign
                if (facing == 1) {
                    Shock.cast(level, entity.x + entity.sprite.width + 8, entity.y + (entity.sprite.height / 2), facing, _chain)
                } else {
                    Shock.cast(level, entity.x - 8, entity.y + (entity.sprite.height / 2), facing, _chain)
                }
            }
        }
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_shock.copy()
        sprite.frame = 0
        hitbox = Hitbox.new_rectangle(16, 8)
        hitbox.x_offset = 8
        hitbox.y_offset = 4
        sprite.origin_x = 8
        sprite.origin_y = 4
        _chain = 0
    }

    static cast(level, x, y, facing, chain) {
        if (chain <= 2) {
            var shock = level.add_entity(Shock)
            shock.x = x
            shock.y = y
            shock.sprite.scale_x = facing
            shock.set_velocity(0, 0)
            shock.set_duration(0.1)
            shock.chain = chain + 1
            Globals.play_sound(Assets.aud_bolt)
        }
    }
}

class Laser is Spell {
    construct new() { super() }

    length=(s) { _length = s }
    length { _length }

    hit_effect(level, entity) {
        super.hit_effect(level, entity)
        entity.take_damage(25)
        _destroy = true
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        set_penetrating()
        _length = 1
        _destroy = false
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        if (_destroy) {
            level.remove_entity(this)
        }
    }

    draw(level) {
        Renderer.set_colour_mod([1, 0, 0, 1])
        Renderer.draw_rectangle(x, y, length.abs, 4, 0, 0, 0)
        Renderer.set_colour_mod([1, 1, 1, 1])
    }

    static cast(level, x, y, facing) {
        var laser = level.add_entity(Laser)
        laser.x = x
        laser.y = y
        laser.set_velocity(0, 0)
        laser.set_duration(0.20)

        // Figure out how far the laser shoots
        var yy = (y / 8).floor
        var w = 0
        for (i in 0..level.tileset.width) {
            var xx = ((x + (i * facing)) / 8).floor
            if (level.tileset[xx, yy] != 0 || xx > level.tileset.tile_width || xx < 0) {
                w = (i - 2) * facing
                break
            }
        }

        // Make hitbox for said width
        laser.length = w
        if (facing == -1) {
            laser.x = x + w
        }
        laser.y = laser.y - 2
        laser.hitbox = Hitbox.new_rectangle(w.abs, 4)

        // Audio
        Globals.play_sound(Assets.aud_laser)
    }
}

class Bow is Spell {
    construct new() { super() }

    hit_effect(level, entity) {
        super.hit_effect(level, entity)
        entity.take_damage(20)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_magicsword_bolt.copy()
        hitbox = Hitbox.new_rectangle(8, 8)
        hitbox.x_offset = 4
        hitbox.y_offset = 4
        sprite.origin_x = 4
        sprite.origin_y = 4
    }

    static cast(level, x, y, dir) {
        var bow = level.add_entity(Bow)
        bow.x = x
        bow.y = y
        bow.sprite.rotation = dir
        bow.set_velocity(dir, 3)
        bow.set_duration(1.5)
        bow.set_penetrating()
        Globals.play_sound(Assets.aud_bow)
    }
}

class Hell is Spell {
    construct new() { super() }

    delay=(s) { _delay = s }
    delay { _delay }

    hit_effect(level, entity) {
        super.hit_effect(level, entity)
        entity.take_damage(15)
    }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_meteor.copy()
        hitbox = Hitbox.new_rectangle(16, 16)
        hitbox.x_offset = 8
        hitbox.y_offset = 8
        sprite.origin_x = 8
        sprite.origin_y = 8
        _delay = 0
    }

    update(level) {
        super.update(level)
        if (y > level.tileset.height + 8) {
            level.remove_entity(this)
        }

        if (delay > 0) {
            delay = delay - 1
        } else {
            is_static = false
        }
    }

    static cast(level) {
        for (i in 0..30) {
            var hell = level.add_entity(Hell)
            hell.x = Globals.rng.int(-level.tileset.height, level.tileset.width)
            hell.y = -8
            hell.set_velocity(Num.pi / 4, 2)
            hell.set_duration(999)
            hell.set_penetrating()
            hell.delay = Globals.rng.int(4 * 60)
            hell.is_static = true
            Globals.play_sound(Assets.aud_hell)
        }
    }
}