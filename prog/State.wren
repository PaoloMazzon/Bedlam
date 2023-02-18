import "lib/File" for INI

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
        var config = INI.open("config")
        __game_surf = null
        __camera = null
        __scale = config.get_num("renderer", "scale", 5)
        __fullscreen = config.get_bool("renderer", "fullscreen", false)
        __area = config.get_string("game", "area", "Forest_A1#1")
    }

    static game_surf { __game_surf }
    static game_surf=(s) { __game_surf = s }
    static camera { __camera }
    static camera=(s) { __camera = s }
    static scale { __scale }
    static scale=(s) { __scale = s }
    static fullscreen { __fullscreen }
    static fullscreen=(s) { __fullscreen = s }
    static area { __area }
    static area=(s) { __area = s }

    static move_camera(x, y) {
        camera.x = camera.x + x
        camera.y = camera.y + y
        camera.update()
    }
}
