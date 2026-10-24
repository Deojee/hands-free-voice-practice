extends Control

@onready var recorder = $DirectAudioInputRecorder
@onready var player = $AudioStreamPlayerWav24B

var line : Line2D

var linePoints = 300
var volumeScale = 1.5

func _ready() -> void:
	
	line = $Line2D
	
	line.clear_points()
	
	# Get the real size of your tablet screen right now
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	var center_y = screen_size.y / 2.0
	
	
	for i in range(linePoints):
		var x_pos = i * (screen_width / (linePoints - 1))
		line.add_point(Vector2(x_pos, center_y))
	
		pass
func _physics_process(delta: float) -> void:
	
	return
	var copyLine = line.points
	
	for i in range(1,linePoints):
		line.set_point_position(i,
			Vector2(
				line.get_point_position(i).x,
				copyLine[i-1].y
			)
		)
	
	line.set_point_position(0, 
		Vector2(
			0,
			-recorder.get_peak_volume_db().x * volumeScale
		)
	)
	
	print(recorder.get_peak_volume_db())
	print(line.get_point_position(0).y)
	
	pass


func _on_record_pressed() -> void:
	recorder.start_capturing()


func _on_stop_pressed() -> void:
	recorder.stop_capturing()
	var recording : AudioStreamWAV24B  = recorder.get_recording_as_wav24b()

	# Save it to the user folder
	recording.save_to_wav("user://high_fidelity_capture.wav")

	# Play it back immediately
	player.play_24bit(recording)


func _on_direct_audio_input_recorder_on_input_frame_captured(last_input_frames: PackedVector2Array, delta: float) -> void:
	#print("chunk:", last_input_frames.size())
	print(last_input_frames)
	
	linePoints = last_input_frames.size()
	
	line.clear_points()
	var screen_size = get_viewport_rect().size
	var screen_width = screen_size.x
	var center_y = screen_size.y / 2.0
	
	for i in range(linePoints):
		var x_pos = i * (screen_width / (linePoints - 1))
		line.add_point(Vector2(x_pos, last_input_frames[i].x * 1000))
	
	pass
