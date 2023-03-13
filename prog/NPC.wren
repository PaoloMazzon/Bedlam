import "lib/Engine" for Engine, Entity
import "lib/Input" for Gamepad
import "lib/Renderer" for Renderer
import "lib/Util" for Hitbox
import "State" for Globals
import "Assets" for Assets
import "Item" for Item
import "Dialogue" for Dialogue
import "MinorEntities" for FloatingText

class NPC is Entity {
    data { _data }
    data=(s) { _data = s }
    center_x { x + (sprite.width / 2) - 8 }
    center_y { y + (sprite.height / 2) }

    on_player_interact(level, player) { /* for child classes */ }

    create(level, tiled_data) {
        super.create(level, tiled_data)
        _data = ""
        if (tiled_data != null && tiled_data["properties"].containsKey("data")) {
            _data = tiled_data["properties"]["data"]
        }
        _colliding = false
        _first = true
    }

    update(level) {
        // Snap to the ground
        if (_first) {
            _first = false
            y = y.floor
            while (!level.tileset.collision(hitbox, x, y + 1)) {
                y = y + 1
            }
            y = y + 1
        }


        _colliding = hitbox.collision(x, y, level.player.x, level.player.y, level.player.hitbox)

        if (_colliding && Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_UP) && !level.is_paused) {
            Globals.play_sound(Assets.aud_menu)
            on_player_interact(level, level.player)
        }
    }

    draw(level) {
        super.draw(level)
        if (_colliding && sprite != null) {
            Renderer.draw_texture(Assets.tex_uparrow, x + (sprite.width / 2) - 4, y - 11 + (Engine.time * 2).sin)
        }
    }
}

class SlimeNPC is NPC {
    on_player_interact(level, player) {
        if (Globals.item_unlocked("toy") && !Globals.event_has_happened("slime_gives_spell")) {
            Globals.record_event("slime_gives_spell")
            Item.create_item(level, "lspell", x + 30, y)
            level.dialogue.queue("Thank you for returning my toy!", center_x, center_y)
            level.dialogue.queue("Here, you can have this.", center_x, center_y)
            level.dialogue.queue("I don't know what it is but it looks cool.", center_x, center_y)
        } else if (Globals.event_has_happened("slime_gives_spell")) {
            level.dialogue.queue("Thank you for returning my toy!", center_x, center_y)
        } else {
            level.dialogue.queue("Some bad men took my toy and broke it " + Dialogue.CHAR_FROWN, center_x, center_y)
            level.dialogue.queue("Where can I find them?", level.player.x, level.player.y)
            level.dialogue.queue("I don't know, they all left.", center_x, center_y)
        }
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_slimenpc
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
        if (Globals.event_has_happened("slime_gives_spell") && !Globals.item_unlocked("lspell")) {
            Item.create_item(level, "lspell", x + 30, y)
        }
    }
}

class BlacksmithNPC is NPC {
    on_player_interact(level, player) {
        if (Globals.item_unlocked("toy")) {
            level.dialogue.queue("...", center_x, center_y)
            level.dialogue.queue(Dialogue.CHAR_SMILE, center_x, center_y)
        } else if (Globals.item_unlocked("fragment_1") && Globals.item_unlocked("fragment_2") && Globals.item_unlocked("fragment_3") && !Globals.item_unlocked("toy")) {
            level.dialogue.queue("Is that a broken toy you have " + Dialogue.CHAR_EYES, center_x, center_y)
            level.dialogue.queue("Let me fix it for you.", center_x, center_y)
            FloatingText.create_floating_text(level, "Toy", player.x + 4, player.y - 20)
            Globals.unlock_item("toy")
            level.dialogue.queue("...", center_x, center_y)
            level.dialogue.queue("Good as new.", center_x, center_y)
        } else {
            level.dialogue.queue("The commander never gets me anything to do anymore.", center_x, center_y)
            level.dialogue.queue("I wish I had something to work on...", center_x, center_y)
        }
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_blacksmith
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
    }
}

class BridgeNPC is NPC {
    on_player_interact(level, player) {
        if (Globals.item_unlocked("quest_sword") && !Globals.item_unlocked("bow")) {
            level.dialogue.queue("...", center_x, center_y)
            level.dialogue.queue(Dialogue.CHAR_SMILE, center_x, center_y)
            level.dialogue.queue("You found my sword!", center_x, center_y)
            level.dialogue.queue("Here, you can have this to show my gratitude.", center_x, center_y)
            player.unlock_bow()
            FloatingText.create_floating_text(level, "Bow", player.x + 4, player.y - 20)
        } else {
            level.dialogue.queue("One of the other soldiers took my sword...", center_x, center_y)
        }
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_bridgenpc
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
    }
}

class ImprisonedNPC is NPC {
    on_player_interact(level, player) {
        if (!Globals.item_unlocked("heart_2")) {
            level.dialogue.queue("Oh hey old friend! Thanks again for the sword.", center_x, center_y)
            level.dialogue.queue("They imprisoned me for throwing rocks at a bird.", center_x, center_y)
            level.dialogue.queue("I don't need this in here, you take it.", center_x, center_y)
            player.unlock_health_heart()
            FloatingText.create_floating_text(level, "Health Up", player.x + 4, player.y - 20)
        } else {
            level.dialogue.queue("See you around " + Dialogue.CHAR_SMILE, center_x, center_y)
        }
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_bridgenpc
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
        if (!Globals.item_unlocked("bow")) {
            level.remove_entity(this)
        }
    }
}

class SavePoint is NPC {
    on_player_interact(level, player) {
        FloatingText.create_floating_text(level, "Game saved", x + 16, y - 8)
        player.heal(99999)
        Globals.play_sound(Assets.aud_heal)
        Globals.area = Globals.area.split("#")[0] + "#0"
        Globals.save_to_file()
    }

    construct new() {}

    create(level, tiled_data) {
        super.create(level, tiled_data)
        sprite = Assets.spr_save
        hitbox = Hitbox.new_rectangle(sprite.width, sprite.height)
    }
}