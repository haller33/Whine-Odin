package whine

import "core:fmt"
import "core:mem"
import "core:c"
import sdl "vendor:sdl2"


TEST :: false
SHOW_LEAK :: false

FREQ :: 43200
SAMPLE_DT :: ( 1.0 / FREQ )

WAVE_PREVIEW_SAMPLES :: 100

BACKGROUND_COLOR :: 0x181818FF

WAVE_PREVIEW_WIDTH :: 1000.0
WAVE_PREVIEW_HEIGHT :: 300.0
WAVE_PREVIEW_SAMPLE_COLOR :: 0xFFFF00FF


SLIDER_THICCNESS :: 5.0
SLIDER_COLOR :: 0x00FF00FF
SLIDER_GRIP_SIZE :: 30.0
SLIDER_GRIP_COLOR :: 0xFF0000FF



Slider :: enum {
    SLIDER_FREQ = 0,
    SLIDER_VOLUME,
    // TODOO: add a slider for the amount of preview samples
    // TODO: add a slider for additional noise for the periods
}

Gen :: struct {
    period : f32,
    volume : f32,
}

// AudioCallback,
white_noise_callback :: proc "c" (userdata : rawptr, stream : [^]u8, len : c.int ) {
    // context = default_context()
// white_noise_callback :: proc "c" AudioCallback {
    // assert(len % 2 == 0);
    a := 1 + 1
    // white_noise(userdata, (Sint16*) stream, len / 2);
}


mainland :: proc () {

    /*
    gen : sdl.Gen = {
        .period = 10.0,
        .volume = 0.5,
    };
    don't know yet how to construct this.
    */

    gen := Gen {
	period = 10.0,
	volume = 0.5,
    }

    
    desired : sdl.AudioSpec = {
        freq = FREQ,
        format = sdl.AUDIO_S16LSB,
        channels = 1,
        callback = white_noise_callback,
        userdata = &gen,
    };

    
    quit : bool = false;


    if 0 > sdl.Init(sdl.INIT_AUDIO | sdl.INIT_VIDEO) {

	fmt.eprintf ( "ERROR: could not initialize SDL: ", sdl.GetError())
	return
    }

    fmt.println ( "Hello World" )

    window : ^sdl.Window = sdl.CreateWindow("Whine", 0, 0, 800, 600, sdl.WINDOW_RESIZABLE);
    
    if window == c.NULL {
        fmt.eprintf( "ERROR: could not create a window: %s\n", sdl.GetError());
	return
    }
    
    
    renderer : ^sdl.Renderer = sdl.CreateRenderer(window, -1, sdl.RENDERER_ACCELERATED);
    if renderer == c.NULL {
        fmt.eprintf( "ERROR: could not create a renderer: %s\n", sdl.GetError());
	return 
    }

    
    if sdl.OpenAudio(&desired, cast(^sdl.AudioSpec) c.NULL) < 0 {
        fmt.eprintf( "ERROR: could not open audio device: %s\n", sdl.GetError());
	return
    }

    for quit {
        event : sdl.Event

	
	if (sdl.WaitEvent(&event)) {
            #partial switch event.type {
            case .sdl.QuitEvent: 
                quit = true
	    }
        }
	

    }
    
}

test :: proc () {

}


main :: proc () {

    track: mem.Tracking_Allocator
    mem.tracking_allocator_init(&track, context.allocator)
    context.allocator = mem.tracking_allocator(&track)

    when !TEST {
	mainland ()
    } else {
	test ()
    }

    when SHOW_LEAK {
	for _, leak in track.allocation_map {
	    fmt.printf("%v leaked %v bytes\n", leak.location, leak.size)
	}
	for bad_free in track.bad_free_array {
	    fmt.printf("%v allocation %p was freed badly\n", bad_free.location, bad_free.memory)
	}
    }
    return
}
