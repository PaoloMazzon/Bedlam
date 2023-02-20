import "lib/File" for INI
import "lib/Util" for Buffer
import "random" for Random

class Constants {
    static GAME_WIDTH { 160 }
    static GAME_HEIGHT { 120 }
    static DEFAULT_SCALE { 5 }
    static WEAPON_SHORTSWORD { 1 }
    static FLOATING_TEXT_DURATION_FRAMES { 60 }
}

class Balance {
    static GRAVITY { 0.1 }
    static BASE_ENEMY_HP { 50 }
    static HIT_FREEZE_DELAY { 0.25 }
    static FADE_DURATION { 0.25 }
    static PLAYER_MANA { 60 }
    static PLAYER_MAX_BASE_HP { 40 }
    static PLAYER_HP_BOOSTS { 10 }
    static PLAYER_POSSIBLE_HP { 70 }
    static PLAYER_IFRAMES { 60 }
    static MANA_RESTORATION { Balance.PLAYER_MANA * 0.0003 } // per second
    static MANA_DAMAGE_THRESHHOLD { Balance.PLAYER_MANA * 0.20 }
    static MANA_BURN { Balance.PLAYER_MAX_BASE_HP * 0.0002 }
    static BOLT_COST { Balance.PLAYER_MANA * 0.05 }
    static ENEMY_IFRAMES { 5 }
    static MANA_POTION { 0.3 }
    static HEALTH_POTION { 0.3 }
    static KNOCKBACK_STUN_FRAMES { 10 }
    static SHORTSWORD_DAMAGE { 8 }
}

class Globals {
    static init() {
        __config = INI.open("config")
        __game_surf = null
        __camera = null
        __scale = __config.get_num("renderer", "scale", Constants.DEFAULT_SCALE)
        __fullscreen = __config.get_bool("renderer", "fullscreen", false)
        __area = __config.get_string("game", "area", "Map_A1#1")
        __rng = Random.new()
        __max_player_hp = __config.get_num("game", "max_hp", Balance.PLAYER_MAX_BASE_HP)
        __player_hp = __config.get_num("game", "hp", Balance.PLAYER_MAX_BASE_HP)
        __player_mana = __config.get_num("game", "mana", Balance.PLAYER_MANA)
        __player_has_bolt = __config.get_bool("game", "bolt", false)
        __player_has_shortsword = __config.get_bool("game", "shortsword", false)
        __post_shader = null
        __shader_buffer = Buffer.new(12)
        __health_potions = __config.get_num("game", "health_potions", 0)
        __mana_potions = __config.get_num("game", "mana_potions", 0)
        __equipped_weapon = __config.get_num("game", "weapon", 0)

        // Load unlocked items
        var str = __config.get_string("game", "unlocked_items", "")
        __unlocked_items = []
        if (str != "") {
            __unlocked_items = str.split(",")
        }
    }

    static game_surf { __game_surf }
    static game_surf=(s) { __game_surf = s }
    static camera { __camera }
    static camera=(s) { __camera = s }
    static post_shader { __post_shader }
    static post_shader=(s) { __post_shader = s }
    static shader_buffer { __shader_buffer }
    static shader_buffer=(s) { __shader_buffer = s }
    static rng { __rng }

    // Things that go in the ini automatically
    static scale { __scale }
    static fullscreen { __fullscreen }
    static area { __area }
    static max_player_hp { __max_player_hp }
    static player_hp { __player_hp }
    static player_mana { __player_mana }
    static player_has_bolt { __player_has_bolt }
    static player_has_shortsword { __player_has_shortsword }
    static health_potions { __health_potions }
    static mana_potions { __mana_potions }
    static equipped_weapon { __equipped_weapon }
    static item_unlocked(item) { __unlocked_items.indexOf(item) != -1 }
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
    static max_player_hp=(s) {
        __max_player_hp = s
        __config.set_num("game", "max_hp", __max_player_hp)
        __config.flush("config")
    }
    static player_hp=(s) {
        __player_hp = s
        __config.set_num("game", "hp", __player_hp)
        __config.flush("config")
    }
    static player_mana=(s) {
        __player_mana = s
        __config.set_num("game", "mana", __player_mana)
        __config.flush("config")
    }
    static player_has_bolt=(s) {
        __player_has_bolt = s
        __config.set_bool("game", "bolt", __player_has_bolt)
        __config.flush("config")
    }
    static player_has_shortsword=(s) {
        __player_has_shortsword = s
        __config.set_bool("game", "shortsword", __player_has_shortsword)
        __config.flush("config")
    }
    static health_potions=(s) {
        __health_potions = s
        __config.set_num("game", "health_potions", __health_potions)
        __config.flush("config")
    }
    static mana_potions=(s) {
        __mana_potions = s
        __config.set_num("game", "mana_potions", __mana_potions)
        __config.flush("config")
    }
    static equipped_weapon=(s) {
        __equipped_weapon = s
        __config.set_num("game", "weapon", __equipped_weapon)
        __config.flush("config")
    }
    static unlock_item(item) {
        if (!Globals.item_unlocked(item) && item != "health" && item != "mana") {
            __unlocked_items.add(item)
            var str = ""
            for (i in __unlocked_items) {
                if (i != "") {
                    str = str + i + ","
                }
            }
            __config.set_string("game", "unlocked_items", str)
            __config.flush("config")
        }
    }

    static move_camera(x, y) {
        camera.x = camera.x + x
        camera.y = camera.y + y
        camera.update()
    }
}
