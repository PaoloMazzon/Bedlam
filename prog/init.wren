import "lib/Renderer" for Renderer
import "lib/Engine" for Engine
import "State" for Constants, Globals
import "Menu" for Menu
import "LevelControl" for Marker
import "Item" for Item
import "Events" for Event

Globals.init()

var renderer_config = {
	"window_title": "Bedlam",
	"window_width": Globals.scale * Constants.GAME_WIDTH,
	"window_height": Globals.scale * Constants.GAME_HEIGHT,
	"fullscreen": Globals.fullscreen,
	"msaa": Renderer.MSAA_1X,
	"screen_mode": Renderer.SCREEN_MODE_TRIPLE_BUFFER,
	"filter_type": Renderer.FILTER_TYPE_NEAREST
}

var window_icon = "assets/game_icon.png"

Engine.fps_limit = 60
System.print(Engine.info)

var start_level = Menu.new()