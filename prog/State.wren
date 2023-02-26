import "lib/File" for INI
import "lib/Util" for Buffer
import "random" for Random

class Constants {
    static GAME_WIDTH { 160 }
    static GAME_HEIGHT { 120 }
    static DEFAULT_SCALE { 5 }
    static WEAPON_SHORTSWORD { 1 }
    static WEAPON_MACE { 2 }
    static WEAPON_SPEAR { 3 }
    static WEAPON_RAPIER { 4 }
    static WEAPON_LEGEND { 5 }
    static FLOATING_TEXT_DURATION_FRAMES { 60 }
    static SILHOUETTE_DURATION_FRAMES { 60 }
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
    static SHOCK_COST { Balance.PLAYER_MANA * 0.15 }
    static LASER_COST { Balance.PLAYER_MANA * 0.2 }
    static ENEMY_IFRAMES { 5 }
    static MANA_POTION { 0.7 }
    static HEALTH_POTION { 0.3 }
    static KNOCKBACK_STUN_FRAMES { 10 }
    static SHORTSWORD_DAMAGE { 8 }
    static MACE_DAMAGE { 12 }
    static TELEPORT_RANGE { 40 }
}

class Globals {
    static reload() {
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
        __max_jumps = __config.get_num("game", "jumps", 0)
        __walljump = __config.get_bool("game", "walljump", false)
        __teleport = __config.get_bool("game", "teleport", false)

        // Load unlocked items
        var str = __config.get_string("game", "unlocked_items", "")
        __unlocked_items = []
        if (str != "") {
            __unlocked_items = str.split(",")
        }
    }

    static init() {
        __config = INI.open("config")
        __game_surf = null
        __camera = null
        this.reload()
    }

    static in_cathedral {
        var s = this.area.split("#")
        var loc = s[0].split("_")[1]
        if (["B4", "B5", "B6", "B7", "A6", "C6", "C7", "D7"].indexOf(loc) != -1) {
            return true
        } else {
            return false
        }
    }

    static in_tomb {
        var s = this.area.split("#")
        var loc = s[0].split("_")[1]
        if (["A1", "A2", "A3", "B1", "B2", "B3", "C1", "C3", "D3"].indexOf(loc) != -1) {
            return true
        } else {
            return false
        }
    }

    static in_bridge {
        var s = this.area.split("#")
        var loc = s[0].split("_")[1]
        if (["E3", "E4", "F3", "F4"].indexOf(loc) != -1) {
            return true
        } else {
            return false
        }
    }

    static in_nexus {
        var s = this.area.split("#")
        var loc = s[0].split("_")[1]
        if (["E6", "F1", "F6", "F7", "G1", "G2", "G3", "G4", "G5", "G6", "G7"].indexOf(loc) != -1) {
            return true
        } else {
            return false
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
    static max_jumps { __max_jumps }
    static walljump { __walljump }
    static teleport { __teleport }
    static item_unlocked(item) { __unlocked_items.indexOf(item) != -1 }
    static event_has_happened(event) { __unlocked_items.indexOf(item) != -1 }
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
    static area=(s) { __area = s }
    static max_player_hp=(s) { __max_player_hp = s }
    static player_hp=(s) { __player_hp = s }
    static player_mana=(s) { __player_mana = s }
    static player_has_bolt=(s) { __player_has_bolt = s }
    static player_has_shortsword=(s) { __player_has_shortsword = s }
    static health_potions=(s) { __health_potions = s }
    static mana_potions=(s) { __mana_potions = s }
    static equipped_weapon=(s) { __equipped_weapon = s }
    static max_jumps=(s) { __max_jumps = s }
    static walljump=(s) { __walljump = s }
    static teleport=(s) { __teleport = s }
    static unlock_item(item) {
        if (!Globals.item_unlocked(item) && item != "health" && item != "mana") {
            __unlocked_items.add(item)
        }
    }
    static record_event(event) {
        if (!Globals.item_unlocked(item) && item != "message") {
            __unlocked_items.add(item)
        }
    }

    static save_to_file() {
        __config.set_string("game", "area", __area)
        __config.set_num("game", "max_hp", __max_player_hp)
        __config.set_num("game", "hp", __player_hp)
        __config.set_num("game", "mana", __player_mana)
        __config.set_bool("game", "bolt", __player_has_bolt)
        __config.set_bool("game", "shortsword", __player_has_shortsword)
        __config.set_num("game", "health_potions", __health_potions)
        __config.set_num("game", "mana_potions", __mana_potions)
        __config.set_num("game", "weapon", __equipped_weapon)
        __config.set_num("game", "jumps", __max_jumps)
        __config.set_bool("game", "walljump", __walljump)
        __config.set_bool("game", "teleport", __teleport)

        var str = ""
        for (i in __unlocked_items) {
            if (i != "") {
                str = str + i + ","
            }
        }
        __config.set_string("game", "unlocked_items", str)
        
        __config.flush("config")
    }

    static move_camera(x, y) {
        camera.x = camera.x + x
        camera.y = camera.y + y
        camera.update()
    }
}
