import "lib/Engine" for Entity

class Marker is Entity {
    construct new() {}

    id { __id }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        __id = tiled_data["properties"]["id"]
    }
}

class Transition is Entity {
    construct new() {}

    area { __area }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        __area = tiled_data["properties"]["area"]
    }

    update(level) {
        super.update(level)
        // TODO: Wait for the player to collide with this and switch
    }
}