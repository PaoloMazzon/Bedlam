import "lib/Engine" for Entity, Engine
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "State" for Globals
import "Assets" for Assets
import "MinorEntities" for FloatingText
import "Dialogue" for Dialogue

class Item is Entity {
    construct new() { super() }

    static create_item(level, item, x, y) {
        var data = {"x": x, "y": y, "properties": {"item": item}}
        level.add_entity(Item, data)
    }

    pickup_effect(level, player) {
        Globals.unlock_item(_item_id)
        level.remove_entity(this)
        var split = ""

        if (_item_id.split("_").count > 1) {
            split = _item_id.split("_")[0]
        }

        if (_item_id == "shortsword") {
            player.unlock_shortsword()
            FloatingText.create_floating_text(level, "Shortsword", x + 5, y - 20)
            level.dialogue.queue("Hold " + Dialogue.CHAR_GAMEPAD_RBUMPER + " and press " + Dialogue.CHAR_GAMEPAD_A + " to equip your new Shortsword.", level.player.x, level.player.y)
            level.dialogue.queue("Go try it on some enemies with " + Dialogue.CHAR_GAMEPAD_X + " and " + Dialogue.CHAR_GAMEPAD_Y + ".", level.player.x, level.player.y)
            var enemy = level.get_entity(Engine.get_class("Enemy::Enemy"))
            if (enemy != null) {
                level.dialogue.queue("", enemy.x, enemy.y)
            }
        } else if (_item_id == "mace") {
            player.unlock_mace()
            FloatingText.create_floating_text(level, "Axe", x + 5, y - 20)
        } else if (_item_id == "lweapon") {
            player.unlock_lweapon()
            FloatingText.create_floating_text(level, "Wraithslayer", x + 5, y - 20)
            level.dialogue.queue("Hold " + Dialogue.CHAR_GAMEPAD_LBUMPER + " and " + Dialogue.CHAR_GAMEPAD_RBUMPER + " then press " + Dialogue.CHAR_GAMEPAD_B + " to equip the Wraithslayer.", level.player.x, level.player.y)
        } else if (_item_id == "rapier") {
            player.unlock_rapier()
            FloatingText.create_floating_text(level, "Rapier", x + 5, y - 20)
        } else if (_item_id == "spear") {
            player.unlock_spear()
            FloatingText.create_floating_text(level, "Spear", x + 5, y - 20)
        } else if (_item_id == "lspell") {
            player.unlock_lspell()
            FloatingText.create_floating_text(level, "Hell", x + 5, y - 20)
            level.dialogue.queue("Hold " + Dialogue.CHAR_GAMEPAD_LBUMPER + " and " + Dialogue.CHAR_GAMEPAD_RBUMPER + " then press " + Dialogue.CHAR_GAMEPAD_X + " to cast rain hell.", level.player.x, level.player.y)
        } else if (_item_id == "bow") {
            player.unlock_bow()
            FloatingText.create_floating_text(level, "Bow", x + 5, y - 20)
        } else if (_item_id == "shock") {
            player.unlock_shock()
            FloatingText.create_floating_text(level, "Shock", x + 5, y - 20)
        } else if (_item_id == "laser") {
            player.unlock_laser()
            FloatingText.create_floating_text(level, "Laser", x + 5, y - 20)
        } else if (_item_id == "bolt") {
            player.unlock_bolt()
            FloatingText.create_floating_text(level, "Bolt", x + 5, y - 20)
            level.dialogue.queue("Hold " + Dialogue.CHAR_GAMEPAD_LBUMPER + " and press " + Dialogue.CHAR_GAMEPAD_A + " cast the spell.", level.player.x, level.player.y)
        } else if (_item_id == "health" || split == "health") {
            player.get_health_potion()
            FloatingText.create_floating_text(level, "Health Potion", x + 5, y - 20)
        } else if (_item_id == "mana" || split == "mana") {
            player.get_mana_potion()
            FloatingText.create_floating_text(level, "Mana Potion", x + 5, y - 20)
        } else if (_item_id == "double_jump") {
            player.unlock_double_jump()
            FloatingText.create_floating_text(level, "Double Jump", x + 5, y - 20)
            level.dialogue.queue("Press " + Dialogue.CHAR_GAMEPAD_A + " mid-air for an additional jump.", level.player.x, level.player.y)
        } else if (_item_id == "minimap") {
            FloatingText.create_floating_text(level, "Mini-map", x + 5, y - 20)
            level.dialogue.queue("Press " + Dialogue.CHAR_GAMEPAD_SELECT + " to reveal the mini-map.", level.player.x, level.player.y)
        } else if (_item_id == "teleport") {
            player.unlock_teleport()
            FloatingText.create_floating_text(level, "Teleport", x + 5, y - 20)
            level.dialogue.queue("Press " + Dialogue.CHAR_GAMEPAD_B + " to teleport in the direction you are facing.", level.player.x, level.player.y)
        } else if (_item_id == "walljump") {
            player.unlock_walljump()
            FloatingText.create_floating_text(level, "Walljump", x + 5, y - 20)
            level.dialogue.queue("Press " + Dialogue.CHAR_GAMEPAD_A + " against a wall to jump off of it.", level.player.x, level.player.y)
        } else if (split == "heart") {
            player.unlock_health_heart()
            FloatingText.create_floating_text(level, "Health Up", x + 5, y - 20)
        }
    }

    create(level, tiled_data) {
        _item_id = tiled_data["properties"]["item"]
        if (Globals.item_unlocked(_item_id)) {
            level.remove_entity(this)
        }
        _texture = null
        hitbox = Hitbox.new_rectangle(10, 10)
        hitbox.y_offset = 8
        _first = true

        var split = ""

        if (_item_id.split("_").count > 1) {
            split = _item_id.split("_")[0]
        }

        if (_item_id == "shortsword") {
            _texture = Assets.tex_shortsword_icon
        } else if (_item_id == "mace") {
            _texture = Assets.tex_mace_icon
        } else if (_item_id == "bolt") {
            _texture = Assets.tex_bolt_icon
        } else if (_item_id == "shock") {
            _texture = Assets.tex_shock_icon
        } else if (_item_id == "laser") {
            _texture = Assets.tex_laser_icon
        } else if (_item_id == "lspell") {
            _texture = Assets.tex_hell_icon
        } else if (_item_id == "bow") {
            _texture = Assets.tex_bow_icon
        } else if (_item_id == "lweapon") {
            _texture = Assets.tex_magicsword_icon
        } else if (_item_id == "rapier") {
            _texture = Assets.tex_rapier_icon
        } else if (_item_id == "spear") {
            _texture = Assets.tex_spear_icon
        } else if (_item_id == "health" || split == "health") {
            _texture = Assets.tex_health_potion
        } else if (_item_id == "mana" || split == "mana") {
            _texture = Assets.tex_mana_potion
        } else if (_item_id == "walljump") {
            _texture = Assets.tex_wall_jump_icon
        } else if (_item_id == "teleport") {
            _texture = Assets.tex_teleport_icon
        } else if (_item_id == "minimap") {
            _texture = Assets.tex_minimap_icon
        } else if (_item_id == "double_jump") {
            _texture = Assets.tex_doublejump_icon
        } else if (split == "heart") {
            _texture = Assets.tex_health_up_icon
        }
    }

    update(level) {
        if (_first) {
            _first = false
            // Snap to the ground
            x = x.round
            y = y.round
            while (!level.tileset.collision(hitbox, x, y + 1)) {
                y = y + 1
            }
            y = y + 1
        }
    }

    draw(level) {
        Renderer.draw_texture(Assets.tex_item_holder, x, y)

        if (_texture != null) {
            var yy = (Engine.time * 2).sin
            if (level.is_paused) {
                yy = 0
            }
            Renderer.draw_texture(_texture, x + 1, y - 11 + yy)
        }
    }
}