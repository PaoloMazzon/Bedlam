import "lib/Engine" for Entity
import "lib/Util" for Hitbox

class Marker is Entity {
    construct new() {}

    id { _id }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _id = tiled_data["properties"]["id"]
    }
}

// Collisions handled by Area
class Transition is Entity {
    construct new() {}

    area { _area }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _area = tiled_data["properties"]["area"]
        hitbox = Hitbox.new_rectangle(8, 16)
    }
}