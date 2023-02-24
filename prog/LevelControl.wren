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
        if (tiled_data["width"] == 0 || tiled_data["height"] == 0) {
            hitbox = Hitbox.new_rectangle(8, 16)
        } else {
            hitbox = Hitbox.new_rectangle(tiled_data["width"], tiled_data["height"])
        }
    }
}