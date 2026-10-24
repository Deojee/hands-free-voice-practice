extends Line2D

@onready var spectrum = AudioServer.get_bus_effect_instance(1, 0)

var POINTS_COUNT = 80  # More points makes it look smoother on a big high-res screen
var FREQ_MAX = 10000.0

func _ready():
	# Clean up any editor default points
	clear_points()
	
	# Get the real size of your tablet screen right now
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	var center_y = screen_size.y / 2.0
	
	# Generate points flat across the entire screen width
	for i in range(POINTS_COUNT):
		var x_pos = i * (screen_width / (POINTS_COUNT - 1))
		add_point(Vector2(x_pos, center_y))

func _process(_delta):
	# Measure screen size every frame (in case you rotate your tablet!)
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	var center_y = screen_size.y / 2.0
	
	var prev_hz = 0
	
	for i in range(POINTS_COUNT):
		# Calculate the microphone sound data
		var hz = i * FREQ_MAX / POINTS_COUNT
		var magnitude = spectrum.get_magnitude_for_frequency_range(prev_hz, hz).length()
		
		# Translate sound to wave height scale
		var energy = clampf((linear_to_db(magnitude) + 60) / 60, 0.0, 1.0)
		
		# On a big tablet screen, 400 pixels tall looks great for max volume
		var wave_height = energy * 400.0 
		
		# Alternating points go UP and DOWN from the center line
		if i % 2 == 0:
			wave_height = -wave_height
			
		# Calculate the exact X position to spread out across the full screen width
		var x_pos = i * (screen_width / (POINTS_COUNT - 1))
		
		# Update the point instantly to its new full-screen coordinates
		set_point_position(i, Vector2(x_pos, center_y + wave_height))
		
		prev_hz = hz
