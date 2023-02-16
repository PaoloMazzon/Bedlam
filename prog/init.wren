import "lib/Renderer" for Renderer
import "lib/Engine" for Engine
import "State" for Constants, Globals
import "Menu" for Menu
import "LevelControl" for Marker

Globals.init()

var renderer_config = {
	"window_title": "Game",
	"window_width": Globals.scale * Constants.GAME_WIDTH,
	"window_height": Globals.scale * Constants.GAME_HEIGHT,
	"fullscreen": Globals.fullscreen,
	"msaa": Renderer.MSAA_32X,
	"screen_mode": Renderer.SCREEN_MODE_TRIPLE_BUFFER,
	"filter_type": Renderer.FILTER_TYPE_NEAREST
}

Engine.fps_limit = 60
System.print(Engine.info)

var start_level = Menu.new()