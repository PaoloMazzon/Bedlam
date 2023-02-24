import "lib/Renderer" for Renderer
import "lib/Input" for Gamepad, Keyboard
import "lib/Engine" for Engine
import "lib/Util" for Math
import "Assets" for Assets

class Dialogue {
    construct new() {
        _message_queue = []
        _focus_queue = []
        _bar_fade = 0
    }

    static CHAR_GAMEPAD_A { String.fromCodePoint(0x80) }
    static CHAR_GAMEPAD_B { String.fromCodePoint(0x81) }
    static CHAR_GAMEPAD_X { String.fromCodePoint(0x82) }
    static CHAR_GAMEPAD_Y { String.fromCodePoint(0x83) }
    static CHAR_GAMEPAD_LBUMPER { String.fromCodePoint(0x84) }
    static CHAR_GAMEPAD_RBUMPER { String.fromCodePoint(0x85) }
    static CHAR_GAMEPAD_START { String.fromCodePoint(0x86) }
    static CHAR_GAMEPAD_SELECT { String.fromCodePoint(0x87) }
    static CHAR_GAMEPAD_UP { String.fromCodePoint(0x88) }
    static CHAR_GAMEPAD_RIGHT { String.fromCodePoint(0x89) }
    static CHAR_GAMEPAD_DOWN { String.fromCodePoint(0x8A) }
    static CHAR_GAMEPAD_LEFT { String.fromCodePoint(0x8B) }
    static CHAR_SMILE { String.fromCodePoint(0x8C) }
    static CHAR_FROWN { String.fromCodePoint(0x8D) }
    static CHAR_NEUTRAL { String.fromCodePoint(0x8E) }
    static CHAR_EYES { String.fromCodePoint(0x8F) }
    
    // Set message to "" to just move the camera
    queue(message, camera_focus) {
        // Process the message to display properly
        var processed_message = ""

        var prev_char = ""
        var line_count = 0
        var index = 0
        for (char in message) {
            var skip_new_line = false
            // Limit the characters
            if (processed_message.count >= (18 * 3 + 2)) {
                break
            }

            // Either just add the character or add a dash if near the end of the line
            if (line_count == 17 && char != " " && prev_char != " " && message.count - 1 > index && message[index + 1] != " ") {
                skip_new_line = true
                processed_message = processed_message + "-\n" + char
            } else if (!(line_count == 0 && char == " ")) {
                processed_message = processed_message + char
            } else {
                line_count = line_count - 1
            }

            // Add newlines
            line_count = line_count + 1
            if (line_count == 18) {
                if (!skip_new_line) {
                    processed_message = processed_message + "\n"
                    line_count = 0
                } else {
                    line_count = 1
                }
            }
            index = index + 1
            prev_char = char
        }

        // Adjust for trimmed last line
        if (processed_message.count > 18 * 3 + 2) {
            processed_message = processed_message[0..(18 * 3 + 2)]
            index = index + 1
        }

        _message_queue.add(processed_message)
        if (message == "") {
            _focus_queue.add([camera_focus[0], camera_focus[1]])
        } else {
            _focus_queue.add([camera_focus[0], camera_focus[1] - 20])
        }

        // If there was more to the message, call queue again with the rest
        if (index < message.count) {
            this.queue(message[index..message.count - 1], camera_focus)
        }
    }

    // Returns true if there are messages at the moment
    update(level) {
        Renderer.set_texture_camera(false)
        if (_message_queue.count > 0) {
            level.pause()
            level.set_focus(_focus_queue[0][0], _focus_queue[0][1])
            
            // Draw the message box if there is a message
            if (_message_queue[0] != "") {
                var yy = (Engine.time * 2).sin
                Renderer.draw_texture(Assets.tex_message_box, 0, 0)
                Renderer.draw_font(Assets.fnt_dialogue_font, _message_queue[0], 8, 8)
                Renderer.draw_texture(Assets.tex_down_arrow, 144, 32 + yy)
                _bar_fade = Math.clamp(_bar_fade - 0.05, 0, 1)
            } else {
                _bar_fade = Math.clamp(_bar_fade + 0.05, 0, 1)
            }

            // Draw little black border
            if (_bar_fade != 0) {
                Renderer.set_colour_mod([0, 0, 0, 1])
                Renderer.draw_rectangle(0, -16 + (16 * _bar_fade), 160, 16, 0, 0, 0)
                Renderer.draw_rectangle(0, 120 - (16 * _bar_fade), 160, 16, 0, 0, 0)
                Renderer.set_colour_mod([1, 1, 1, 1])
            }

            if (Gamepad.button_pressed(0, Gamepad.BUTTON_A) || Keyboard.key_pressed(Keyboard.KEY_Z)) {
                _message_queue.removeAt(0)
                _focus_queue.removeAt(0)
                if (_message_queue.count == 0) {
                    level.unpause()
                }
            }
            Renderer.set_texture_camera(true)
            return true
        } else {
            // Draw little black border
            _bar_fade = Math.clamp(_bar_fade - 0.05, 0, 1)
            if (_bar_fade != 0) {
                Renderer.set_colour_mod([0, 0, 0, 1])
                Renderer.draw_rectangle(0, -16 + (16 * _bar_fade), 160, 16, 0, 0, 0)
                Renderer.draw_rectangle(0, 120 - (16 * _bar_fade), 160, 16, 0, 0, 0)
                Renderer.set_colour_mod([1, 1, 1, 1])
            }
        }
        Renderer.set_texture_camera(true)
        return false
    }
}