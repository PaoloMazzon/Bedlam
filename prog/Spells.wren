import "lib/Engine" for Engine, Level, Entity
import "lib/Util" for Math, Hitbox
import "Assets" for Assets
import "MinorEntities" for Hit

class Spell is Entity {
    set_velocity(dir, speed) {
        _direction = dir
        _speed = speed
    }

    set_duration(duration_in_seconds) { _duration = (duration_in_seconds * 60).round }
    
    set_penetrating { _penetrates = true }

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
    }

    update(level) {
        if (level.is_paused) {
            return
        }
        super.update(level)
        _duration = _duration - 1
        x = x + Math.cast_x(_speed, _direction)
        y = y + Math.cast_y(_speed, _direction)
        if (_duration <= 0 || level.tileset.collision(hitbox, x, y)) {
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
        entity.take_damage(5)
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
    }
}