import "lib/Renderer" for Renderer
import "Assets" for Assets

class Dialogue {
    construct new() {
        _message_queue = []
        _focus_queue = []
    }

    static CHAR_GAMEPAD_A { "\x80" }
    static CHAR_GAMEPAD_B { "\x81" }
    static CHAR_GAMEPAD_X { "\x82" }
    static CHAR_GAMEPAD_Y { "\x83" }
    static CHAR_GAMEPAD_LBUMPER { "\x84" }
    static CHAR_GAMEPAD_RBUMPER { "\x85" }
    static CHAR_GAMEPAD_START { "\x86" }
    static CHAR_GAMEPAD_SELECT { "\x87" }
    static CHAR_GAMEPAD_UP { "\x88" }
    static CHAR_GAMEPAD_RIGHT { "\x89" }
    static CHAR_GAMEPAD_DOWN { "\x8A" }
    static CHAR_GAMEPAD_LEFT { "\x8B" }
    static CHAR_SMILE { "\x8C" }
    static CHAR_FROWN { "\x8D" }
    static CHAR_NEUTRAL { "\x8E" }
    static CHAR_EYES { "\x8F" }
    
    queue(message, camera_focus) {
        _message_queue.add(message)
        _focus_queue.add(camera_focus)
    }

    update(level) {
        // TODO: This
    }
}