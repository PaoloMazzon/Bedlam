import "lib/Engine" for Engine, Entity
import "lib/Util" for Hitbox
import "State" for Globals
import "Assets" for Assets

class Event is Entity {
    create(level, tiled_data) {
        _event_id = tiled_data["properties"]["event"]
        if (Globals.item_unlocked(_event_id)) {
            level.remove_entity(this)
        }
        _texture = null
        hitbox = Hitbox.new_rectangle(tiled_data["width"], tiled_data["height"])
        hitbox.y_offset = 8
        _first = true

        var split = ""

        if (_event_id.split("_").count > 1) {
            split = _event_id.split("_")[0]
        }
        
        // TODO: Add events
    }

    update(level) {
        if (_first) {
            _first = false
            // Snap to the ground
            x = x.round
            y = y.round
            while (!level.tileset.collision(hitbox, x, y + 1) && y < level.tileset.height) {
                y = y + 1
            }
            y = y + 1
        }
    }
}