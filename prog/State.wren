import "lib/File" for INI
import "random" for Random

class Constants {
    static GAME_WIDTH { 160 }
    static GAME_HEIGHT { 120 }
}

class Balance {
    static GRAVITY { 0.1 }
    static BASE_ENEMY_HP { 100 }
    static HIT_FREEZE_DELAY { 0.1 }
    static FADE_DURATION { 0.25 }
}

class Globals {
    static init() {
        __config = INI.open("config")
        __game_surf = null
        __camera = null
        __scale = __config.get_num("renderer", "scale", 5)
        __fullscreen = __config.get_bool("renderer", "fullscreen", false)
        __area = __config.get_string("game", "area", "Forest_A1#1")
        __rng = Random.new()
    }

    static game_surf { __game_surf }
    static game_surf=(s) { __game_surf = s }
    static camera { __camera }
    static camera=(s) { __camera = s }
    static rng { __rng }

    // Things that go in the ini automatically
    static scale { __scale }
    static fullscreen { __fullscreen }
    static area { __area }
    static scale=(s) {
        __scale = s
        __config.set_num("renderer", "scale", __scale)
        __config.flush("config")
    }
    static fullscreen=(s) {
        __fullscreen = s
        __config.set_bool("renderer", "fullscreen", __fullscreen)
        __config.flush("config")
    }
    static area=(s) {
        __area = s
        __config.set_string("game", "area", __area)
        __config.flush("config")
    }

    static move_camera(x, y) {
        camera.x = camera.x + x
        camera.y = camera.y + y
        camera.update()
    }
}
