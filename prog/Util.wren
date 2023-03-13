import "lib/Renderer" for Renderer
import "lib/Engine" for Engine
import "lib/Util" for Math
import "State" for Globals, Constants, Balance
import "lib/Input" for Gamepad, Keyboard
import "Player" for Player
import "LevelControl" for Marker, Transition
import "Skeleton" for Skeleton
import "Assets" for Assets
import "Weapon" for Weapon
import "NPC" for SavePoint

class Util {
    static maximize_scale() {
        var config = Renderer.get_config()
        Globals.scale = 1
        var w = config["window_width"]
        var h = config["window_height"]
        while ((Globals.scale + 1) * Constants.GAME_WIDTH <= w && (Globals.scale + 1) * Constants.GAME_HEIGHT <= h) {
            Globals.scale = Globals.scale + 1
        }
    }

    static adjust_camera() {
        var conf = Renderer.get_config()
        var x = (conf["window_width"] - (Globals.scale * Constants.GAME_WIDTH)) / 2
        var y = (conf["window_height"] - (Globals.scale * Constants.GAME_HEIGHT)) / 2
        Globals.camera.width = Constants.GAME_WIDTH
        Globals.camera.height = Constants.GAME_HEIGHT
        Globals.camera.zoom = 1
        Globals.camera.update()
    }

    static draw_game_surface() {
        // Get width/height
        var conf = Renderer.get_config()
        var x = (conf["window_width"] - (Globals.scale * Constants.GAME_WIDTH)) / 2
        var y = (conf["window_height"] - (Globals.scale * Constants.GAME_HEIGHT)) / 2
        
        // Setup the post shader
        Globals.shader_buffer.pointer = 0
        Globals.shader_buffer.write_float(conf["window_width"])
        Globals.shader_buffer.write_float(conf["window_height"])
        Globals.shader_buffer.write_float(0.5)
        //Globals.post_shader.data = Globals.shader_buffer
        
        // Draw background, black outline, and game surface with the post shader
        Renderer.draw_texture(Assets.tex_back, 0, 0, conf["window_width"] / Assets.tex_back.width, conf["window_height"] / Assets.tex_back.height, 0, 0, 0)
        Renderer.set_colour_mod([0, 0, 0, 1])
        Renderer.draw_rectangle(x - 1, y - 1, Globals.scale * Constants.GAME_WIDTH + 2, Globals.scale * Constants.GAME_HEIGHT + 2, 0, 0, 0)
        Renderer.set_colour_mod([1, 1, 1, 1])
        //Renderer.set_shader(Globals.post_shader)
        Renderer.draw_texture(Globals.game_surf, x, y, Globals.scale, Globals.scale, 0, 0, 0)
        //Renderer.set_shader(null)
    }

    static change_area(new_area, level) {
        Globals.area = new_area
        Engine.switch_level(level.new())
    }

    static reload_area() {
        load_area(Globals.area)
    }

    static init_area(level) {
        var s = Globals.area.split("#")
        s[1] = Num.fromString(s[1])
        var ret = level.load("assets/" + s[0] + ".tmj")
        var p = level.add_entity(Player)
        var x = 0
        var y = 0
        if (s[1] != 0) {
            var markers = level.get_entities(Marker)
            for (i in markers) {
                if (s[1] == i.id) {
                    x = i.x
                    y = i.y
                    break
                }
            }
            p.x = x
            p.y = y
        } else {
            var save = level.get_entity(SavePoint)
            p.x = save.x + 12
            p.y = save.y + 16
            p.heal(9999)
        }

        // Start of game stuff
        if (Globals.area == "Map_A1#1") {
            p.vspeed = Balance.GRAVITY  * 5
        }

        // Setup camera initial position
        Globals.camera.x = (p.x + 4) - (Constants.GAME_WIDTH / 2)
        Globals.camera.y = (p.y + 6) - (Constants.GAME_HEIGHT / 2)
        Globals.camera.update()
        level.set_focus(p.x, p.y)

        // Enable lighting if we're in the cathedral
        if (Globals.in_cathedral) {
            level.enable_lighting()
        } else {
            level.disable_lighting()
        }

        return ret
    }

    static draw_player_ui(player) {
        Renderer.set_texture_camera(false)

        // Minimap
        if (Gamepad.button(0, Gamepad.BUTTON_BACK) && Globals.item_unlocked("minimap")) {
            Renderer.draw_texture(Assets.tex_minimap, 0, 0)
            
            // Draw flashing rectangle where the player is
            var coords = Globals.area_coords
            var x = 52 + (9 * (coords[0] - 1))
            var y = 32 + (9 * (coords[1] - 1))
            var s = Math.serp(Engine.time, 0, 1)
            Renderer.set_colour_mod([s, s, s, 1])
            Renderer.draw_rectangle(x, y, 2, 2, 0, 0, 0)
            Renderer.set_colour_mod([1, 1, 1, 1])
            Renderer.draw_font(Assets.fnt_font, Globals.percent_completed + "\%", 2, 110)
        } else {
            Renderer.draw_texture(Assets.tex_status_back, 2, 2)
            Renderer.set_colour_mod([1, 1, 1, 0.5])
            Renderer.draw_texture_part(Assets.tex_health, 13, 2, 0, 0, Assets.tex_health.width * (player.hp_flux / Balance.PLAYER_POSSIBLE_HP), Assets.tex_health.height)
            Renderer.draw_texture_part(Assets.tex_mana, 13, 2, 0, 0, Assets.tex_mana.width * (player.mana_flux / Balance.PLAYER_MANA), Assets.tex_mana.height)
            Renderer.set_colour_mod([1, 1, 1, 1])
            Renderer.draw_texture_part(Assets.tex_health, 13, 2, 0, 0, Assets.tex_health.width * (player.hp / Balance.PLAYER_POSSIBLE_HP), Assets.tex_health.height)
            Renderer.draw_texture_part(Assets.tex_mana, 13, 2, 0, 0, Assets.tex_mana.width * (player.mana / Balance.PLAYER_MANA), Assets.tex_mana.height)

            // HP cap display
            if (player.max_hp != Balance.PLAYER_POSSIBLE_HP) {
                Renderer.set_colour_mod([0, 0, 0, 1])
                Renderer.draw_line(13 + (50 * (player.max_hp / Balance.PLAYER_POSSIBLE_HP)).round, 4, 13 + (49 * (player.max_hp / Balance.PLAYER_POSSIBLE_HP)).round, 10)
                Renderer.set_colour_mod([1, 1, 1, 1])
            }
            
            if (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && !Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
                // Spell wheel
                Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
                if (player.has_bolt) {
                    Renderer.draw_texture(Assets.tex_bolt_icon, 137, 26)
                }
                if (player.has_shock) {
                    Renderer.draw_texture(Assets.tex_shock_icon, 148, 15)
                }
                if (player.has_laser) {
                    Renderer.draw_texture(Assets.tex_laser_icon, 137, 4)
                }
                if (player.has_bow) {
                    Renderer.draw_texture(Assets.tex_bow_icon, 126, 15)
                }
                // A is 137, 26
                // B is 148, 15
                // X is 126, 15
                // Y is 137, 4
            } else if (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
                // Mixed wheel
                Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
                if (player.health_potions > 0) {
                    Renderer.draw_texture(Assets.tex_health_potion, 137, 26)
                }
                if (player.mana_potions > 0) {
                    Renderer.draw_texture(Assets.tex_mana_potion, 137, 4)
                }
                if (player.has_lspell) {
                    Renderer.draw_texture(Assets.tex_hell_icon, 126, 15)
                }
                if (player.has_lweapon) {
                    Renderer.draw_texture(Assets.tex_magicsword_icon, 148, 15)
                    if (player.equipped_weapon == Constants.WEAPON_LEGEND) {
                        Renderer.set_colour_mod([87 / 255, 8 / 255, 97 / 255, 1])
                        Renderer.draw_rectangle_outline(148 - 1, 15 - 1, 11, 11, 0, 0, 0, 1)
                        Renderer.set_colour_mod([1, 1, 1, 1])
                    }
                }
            } else if (!Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
                // Weapon wheel
                Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
                if (player.has_shortsword) { // a
                    Renderer.draw_texture(Weapon.weapon_icon(Constants.WEAPON_SHORTSWORD), 137, 26)
                    if (player.equipped_weapon == Constants.WEAPON_SHORTSWORD) {
                        Renderer.set_colour_mod([87 / 255, 8 / 255, 97 / 255, 1])
                        Renderer.draw_rectangle_outline(137 - 1, 26 - 1, 11, 11, 0, 0, 0, 1)
                        Renderer.set_colour_mod([1, 1, 1, 1])
                    }
                }
                if (player.has_mace) { // b
                    Renderer.draw_texture(Weapon.weapon_icon(Constants.WEAPON_MACE), 148, 15)
                    if (player.equipped_weapon == Constants.WEAPON_MACE) {
                        Renderer.set_colour_mod([87 / 255, 8 / 255, 97 / 255, 1])
                        Renderer.draw_rectangle_outline(148 - 1, 15 - 1, 11, 11, 0, 0, 0, 1)
                        Renderer.set_colour_mod([1, 1, 1, 1])
                    }
                }
                if (player.has_spear) { // y
                    Renderer.draw_texture(Weapon.weapon_icon(Constants.WEAPON_SPEAR), 137, 4)
                    if (player.equipped_weapon == Constants.WEAPON_SPEAR) {
                        Renderer.set_colour_mod([87 / 255, 8 / 255, 97 / 255, 1])
                        Renderer.draw_rectangle_outline(137 - 1, 4 - 1, 11, 11, 0, 0, 0, 1)
                        Renderer.set_colour_mod([1, 1, 1, 1])
                    }
                }
                if (player.has_rapier) { // x
                    Renderer.draw_texture(Weapon.weapon_icon(Constants.WEAPON_RAPIER), 126, 15)
                    if (player.equipped_weapon == Constants.WEAPON_RAPIER) {
                        Renderer.set_colour_mod([87 / 255, 8 / 255, 97 / 255, 1])
                        Renderer.draw_rectangle_outline(126 - 1, 15 - 1, 11, 11, 0, 0, 0, 1)
                        Renderer.set_colour_mod([1, 1, 1, 1])
                    }
                }
                // A is 137, 26
                // B is 148, 15
                // X is 126, 15
                // Y is 137, 4
            } else {
                // Equipped weapon
                Renderer.draw_texture(Assets.tex_weapon_box, 146, 2)
                if (player.equipped_weapon != 0) {
                    Renderer.draw_texture(Weapon.weapon_icon(player.equipped_weapon), 148, 4)
                }
            }

            Renderer.draw_texture(Assets.tex_potionbg, 2, 96)
            Renderer.draw_font(Assets.fnt_font, player.health_potions.toString, 13, 98)
            Renderer.draw_font(Assets.fnt_font, player.mana_potions.toString, 13, 108)
        }

        Renderer.set_texture_camera(true)
    }
}