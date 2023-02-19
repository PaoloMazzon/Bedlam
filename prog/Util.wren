import "lib/Renderer" for Renderer
import "lib/Engine" for Engine
import "State" for Globals, Constants, Balance
import "lib/Input" for Gamepad, Keyboard
import "Player" for Player
import "LevelControl" for Marker, Transition
import "Skeleton" for Skeleton
import "Assets" for Assets

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
        //Globals.camera.x_on_screen = x
        //Globals.camera.y_on_screen = y
        //Globals.camera.w_on_screen = Globals.scale * Constants.GAME_WIDTH
        //Globals.camera.h_on_screen = Globals.scale * Constants.GAME_HEIGHT
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
        Globals.post_shader.data = Globals.shader_buffer
        
        // Draw background, black outline, and game surface with the post shader
        Renderer.draw_texture(Assets.tex_window_background, 0, 0, conf["window_width"] / 192, conf["window_height"] / 108, 0, 0, 0)
        Renderer.set_colour_mod([0, 0, 0, 1])
        Renderer.draw_rectangle_outline(x - 1, y - 1, Globals.scale * Constants.GAME_WIDTH + 2, Globals.scale * Constants.GAME_HEIGHT + 2, 0, 0, 0, 1)
        Renderer.set_colour_mod([1, 1, 1, 1])
        Renderer.set_shader(Globals.post_shader)
        Renderer.draw_texture(Globals.game_surf, x, y, Globals.scale, Globals.scale, 0, 0, 0)
        Renderer.set_shader(null)
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

        // Setup camera initial position
        Globals.camera.x = (p.x + 4) - (Constants.GAME_WIDTH / 2)
        Globals.camera.y = (p.y + 6) - (Constants.GAME_HEIGHT / 2)
        Globals.camera.update()
        return ret
    }

    static draw_player_ui(player) {
        Renderer.set_texture_camera(false)
        Renderer.draw_texture(Assets.tex_status_back, 2, 2)
        Renderer.draw_texture_part(Assets.tex_health, 13, 2, 0, 0, Assets.tex_health.width * (player.hp / player.max_hp), Assets.tex_health.height)
        Renderer.draw_texture_part(Assets.tex_mana, 13, 2, 0, 0, Assets.tex_mana.width * (player.mana / Balance.PLAYER_MANA), Assets.tex_mana.height)
        
        if (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && !Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
            // Spell wheel
            Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
            if (player.has_bolt) {
                Renderer.draw_texture(Assets.tex_bolt_icon, 137, 26)
            }
        } else if (Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
            // Mixed wheel
            Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
            Renderer.draw_texture(Assets.tex_health_potion, 137, 26)
            Renderer.draw_texture(Assets.tex_mana_potion, 137, 4)
        } else if (!Gamepad.button(0, Gamepad.BUTTON_LEFT_SHOULDER) && Gamepad.button(0, Gamepad.BUTTON_RIGHT_SHOULDER)) {
            // Weapon wheel
            Renderer.draw_texture(Assets.tex_spell_wheel, 124, 2)
        }

        Renderer.draw_texture(Assets.tex_potionbg, 2, 96)
        Renderer.draw_font(Assets.fnt_font, player.health_potions.toString, 13, 98)
        Renderer.draw_font(Assets.fnt_font, player.mana_potions.toString, 13, 108)

        Renderer.set_texture_camera(true)
    }
}