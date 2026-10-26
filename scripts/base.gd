extends Control

@onready var recorder = $DirectAudioInputRecorder
@onready var player = $AudioStreamPlayerWav24B

var spectrogram : TextureRect 

var volumeScale = 1.5
var textureRes : Vector2 = Vector2(512,1024)

var image: Image
var texture: ImageTexture
var spectrogramCol = 0

func _ready() -> void:
	spectrogram = $TextureRect
	
	image = Image.create(textureRes.x,textureRes.y,false,Image.FORMAT_BPTC_RGBA)
	image.decompress()
	texture = ImageTexture.create_from_image(image)
	spectrogram.texture = texture
	
	pass


func _physics_process(delta: float) -> void:
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


var LLargest = 0
var SSmallest = 10
var inputSum = 0
func _on_direct_audio_input_recorder_on_input_frame_captured(last_input_frames: PackedVector2Array, delta: float) -> void:
	#print("chunk:", last_input_frames.size())
	#print(last_input_frames)
	#var largest = 0
	#var smallest = 1
	#for i in range(last_input_frames.size()):
		#var data = last_input_frames[i].x
		#if data > largest:
			#largest = data
		#if data < smallest:
			#smallest = data
	#
	#prints("L",largest,"S",smallest)
	#if LLargest < largest:
		#LLargest = largest
	#if SSmallest > smallest:
		#SSmallest = smallest
	#prints("LL",LLargest,"SS",SSmallest)
	
	
	
	var inputSize = last_input_frames.size()
	print(inputSize)
	inputSum += inputSize
	prints(inputSum,Time.get_ticks_msec()/1000.0)
	
	return
	
	if inputSize == 0:
		return
	
	
	for i in range(inputSize):
		var data = last_input_frames[i].x
		data = remap(data,-0.14/2.0,0.2/2.0,0,1)
		var color = Color.RED.lerp(Color.BLACK,data)
		
		#print(data)
		
		if inputSize == 512:
			var j = i*2.0
			if j == 0:
				j = 2
			if j == 2:
				j = 4
			image.set_pixel(spectrogramCol,j - 2,color)
			image.set_pixel(spectrogramCol,j - 1,color)
		else:
			image.set_pixel(spectrogramCol,i,color)
	
	
	
	texture.update(image)
	
	spectrogramCol += 1
	if spectrogramCol >= textureRes.x:
		spectrogramCol = 0
	pass
