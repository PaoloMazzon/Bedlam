import "lib/Engine" for Level, Engine
import "lib/Renderer" for Renderer, Camera, Shader
import "lib/Drawing" for Surface
import "lib/Input" for Gamepad, Keyboard
import "State" for Globals, Constants
import "Util" for Util
import "Assets" for Assets
import "Area" for Area

class Menu is Level {
    construct new() { }
    
    create() {
        super.create()
        Globals.camera = Camera.new()
        Util.maximize_scale()
        Globals.game_surf = Surface.new(Constants.GAME_WIDTH, Constants.GAME_HEIGHT)
        //Globals.post_shader = Shader.load("assets/post.vert.spv", "assets/post.frag.spv", 12)

        _pointer = "continue"
        _gamepad_screen_timer = 60 * 3
        _fade_in = 0
    }

    menu_logic() {
        // Menu input
        if (Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_DOWN) || Gamepad.left_stick_y(0) < -0.1) {
            if (_pointer == "continue") {
                _pointer = "new"
            } else if (_pointer == "new") {
                _pointer = "quit"
            } else if (_pointer == "quit") {
                _pointer = "fullscreen"
            }
        }
        if (Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_UP) || Gamepad.left_stick_y(0) > 0.1) {
            if (_pointer == "fullscreen" || _pointer == "music" || _pointer == "sound") {
                _pointer = "quit"
            } else if (_pointer == "quit") {
                _pointer = "new"
            } else {
                _pointer = "continue"
            }
        }
        if (Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_RIGHT) || Gamepad.left_stick_x(0) > 0.1) {
            if (_pointer == "continue" || _pointer == "new" || _pointer == "quit") {
                _pointer = "fullscreen"
            } else if (_pointer == "fullscreen") {
                _pointer = "music"
            } else {
                _pointer = "sound"
            }
        }
        if (Gamepad.button_pressed(0, Gamepad.BUTTON_DPAD_LEFT) || Gamepad.left_stick_x(0) < -0.1) {
            if (_pointer == "fullscreen") {
                _pointer = "quit"
            } else if (_pointer == "music") {
                _pointer = "fullscreen"
            } else if (_pointer == "sound") {
                _pointer = "music"
            }
        }

        if (Gamepad.button_pressed(0, Gamepad.BUTTON_A)) {
            if (_pointer == "continue") {
                Util.change_area(Globals.area, Area)
            } else if (_pointer == "new") {
                Globals.reset_save()
                Util.change_area(Globals.area, Area)
            } else if (_pointer == "quit") {
                Engine.quit()
            } else if (_pointer == "fullscreen") {
                Globals.fullscreen = !Globals.fullscreen
                var conf = Renderer.get_config()
                conf["fullscreen"] = Globals.fullscreen

                if (!Globals.fullscreen) {
                    Globals.scale = Constants.DEFAULT_SCALE
                    conf["window_width"] = Globals.scale * Constants.GAME_WIDTH
                    conf["window_height"] = Globals.scale * Constants.GAME_HEIGHT
                }

                Renderer.set_config(conf)
                Util.maximize_scale()
            } else if (_pointer == "music") {
                Globals.music = !Globals.music
            } else if (_pointer == "sound") {
                Globals.sound = !Globals.sound
            }
        }


        Renderer.lock_cameras(Globals.camera)

        Renderer.set_target(Globals.game_surf)
        Renderer.draw_texture(Assets.tex_menu, 0, 0)

        // Draw pointer
        if (_pointer == "continue") {
            Renderer.draw_texture(Assets.tex_menu_pointer, 32 + (Engine.time * 2).sin, 58)
        } else if (_pointer == "new") {
            Renderer.draw_texture(Assets.tex_menu_pointer, 27 + (Engine.time * 2).sin, 76)
        } else if (_pointer == "quit") {
            Renderer.draw_texture(Assets.tex_menu_pointer, 52 + (Engine.time * 2).sin, 94)
        } else if (_pointer == "fullscreen") {
            Renderer.draw_texture(Assets.tex_menu_pointer_down, 119, 98 + (Engine.time * 2).sin)
        } else if (_pointer == "music") {
            Renderer.draw_texture(Assets.tex_menu_pointer_down, 133, 98 + (Engine.time * 2).sin)
        } else if (_pointer == "sound") {
            Renderer.draw_texture(Assets.tex_menu_pointer_down, 147, 98 + (Engine.time * 2).sin)
        }
        var mod = Renderer.get_colour_mod()
        if (!Globals.fullscreen) {
            Renderer.set_colour_mod([1, 0, 0, 1])
            Renderer.draw_line(119, 107, 128 + 1, 116 + 1)
        }
        if (!Globals.music) {
            Renderer.set_colour_mod([1, 0, 0, 1])
            Renderer.draw_line(133, 107, 142 + 1, 116 + 1)
        }
        if (!Globals.sound) {
            Renderer.set_colour_mod([1, 0, 0, 1])
            Renderer.draw_line(147, 107, 156 + 1, 116 + 1)
        }
        Renderer.set_colour_mod(mod)
        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)
        Renderer.lock_cameras(Renderer.DEFAULT_CAMERA)
        Util.draw_game_surface()
        Renderer.unlock_cameras()
    }

    gamepad_screen_logic() {
        Renderer.lock_cameras(Globals.camera)
        Renderer.set_target(Globals.game_surf)

        Renderer.draw_texture(Assets.tex_gamepad, 0, 0)

        Renderer.set_target(Renderer.RENDER_TARGET_DEFAULT)
        Renderer.lock_cameras(Renderer.DEFAULT_CAMERA)
        Util.draw_game_surface()
        Renderer.unlock_cameras()
    }

    update() {
        Util.adjust_camera()

        if (_gamepad_screen_timer >= 0) {
            _gamepad_screen_timer = _gamepad_screen_timer - 1

            if (Gamepad.button_pressed(0, Gamepad.BUTTON_A)) {
                _gamepad_screen_timer = -1
            }

            if (_gamepad_screen_timer < 60) {
                var fade = _gamepad_screen_timer / 60
                Renderer.set_colour_mod([fade, fade, fade, 1])
            }
            gamepad_screen_logic()

            Renderer.set_colour_mod([1, 1, 1, 1])
        } else {
            if (_fade_in < 60) {
                _fade_in = _fade_in + 1
            }
            var fade = _fade_in / 60
            Renderer.set_colour_mod([fade, fade, fade, 1])
            menu_logic()
            Renderer.set_colour_mod([1, 1, 1, 1])
        }

        super.update()

        // Hotkeys
        if (Keyboard.key(Keyboard.KEY_LALT) && Keyboard.key_pressed(Keyboard.KEY_RETURN)) {
            Globals.fullscreen = !Globals.fullscreen
            var conf = Renderer.get_config()
            conf["fullscreen"] = Globals.fullscreen

            if (!Globals.fullscreen) {
                Globals.scale = Constants.DEFAULT_SCALE
                conf["window_width"] = Globals.scale * Constants.GAME_WIDTH
                conf["window_height"] = Globals.scale * Constants.GAME_HEIGHT
            }

            Renderer.set_config(conf)
            Util.maximize_scale()
        }
    }

    destroy() {
        super.destroy()
    }
}