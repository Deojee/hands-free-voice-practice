extends DirectAudioInputRecorder

class_name VolumeAwareDirectAudioInputRecorder

## A high-performance audio capture node designed for Godot 4.6+.
##
## This node specifically addresses long-standing engine issues regarding 
## input desynchronization, lag, and audio garbling (see GitHub issues #80173, #76797).
## By utilizing direct low-level access to the audio input buffer (PR #113288),
## it provides a stable alternative to the standard capture bus system.
## It supports 8-bit, 16-bit, and external 24-bit formatting for WAV audio formats, 
## as well as real-time volume monitoring.



var minimumVolumeToRecord : float = -60
var hasReachedMinimumVolume : bool = false

var secondsSinceReachingMinimumVolume : float = 0
var secondsOfSilenceBeforeShutoff : float = 2.0
var sizeToTrimSilence : int = 0.0
#time after silence starts that it still records
var silenceCoyoteTime : float = 0.15

#maximum recording time before calling stop capturing
#includes silence
var forceShutoffTime : float = 0
#how longer we've been recording
var recordingTimer : float = 0.0


func _ready() -> void:
	# Enable the microphone input in the Godot AudioServer
	AudioServer.set_input_device_active(true)
	

func _physics_process(delta: float) -> void:
	
	
	
	if !_is_recording:
		return
	
	# Fetch the available frames from the microphone buffer
	_last_audio_samples = AudioServer.get_input_frames(AudioServer.get_input_frames_available())
	on_input_frame_captured.emit(_last_audio_samples, delta)
	
	recordingTimer += delta
	
	print(_last_audio_samples.size())
	
	var volume : float = _get_peak_volume_db(_last_audio_samples).x
	if volume > minimumVolumeToRecord:
		hasReachedMinimumVolume = true
		secondsSinceReachingMinimumVolume = 0.0
	else:
		secondsSinceReachingMinimumVolume += delta
	
	
	# Store the raw audio data continuously while recording is active
	
	if hasReachedMinimumVolume:
		_recording_buffer.append_array(_last_audio_samples)
	
	if volume > minimumVolumeToRecord or secondsSinceReachingMinimumVolume < silenceCoyoteTime:
		sizeToTrimSilence = _recording_buffer.size()
	
	if recordingTimer > forceShutoffTime:
		stop_capturing()
	elif hasReachedMinimumVolume and secondsSinceReachingMinimumVolume > secondsOfSilenceBeforeShutoff:
		stop_capturing()
	 

func _volumeAudible():
	var volume : float = get_peak_volume_db().x
	return volume > minimumVolumeToRecord

# --- Public Interface ---


## Starts capturing microphone input and clears any previous recordings.
func start_capturing() -> void:
	_last_recording = null
	_recording_buffer.clear()
	_is_recording = true
	on_recording_start.emit()
	recordingTimer = 0.0
	secondsSinceReachingMinimumVolume = 0.0
	
	hasReachedMinimumVolume = false
	#records a frame of audio data in case no more is captured
	_last_audio_samples = AudioServer.get_input_frames(AudioServer.get_input_frames_available())
	#on_input_frame_captured.emit(_last_audio_samples, 0.16)
	_recording_buffer.append_array(_last_audio_samples)
	sizeToTrimSilence = _recording_buffer.size() #so that it's not trimmed into nothing

## Stops capturing microphone input and finalizes the buffer.
func stop_capturing() -> void:
	_is_recording = false
	
	_recording_buffer.resize(sizeToTrimSilence)
	
	on_recording_end.emit()
	
# --- Formatting Methods ---





# --- Resource Generation ---

## Generates and returns a standard Godot AudioStreamWAV resource from the recorded buffer.
func get_recording() -> AudioStreamWAV:
	
	#print("GET RECORDING CALLED")
	
	if _last_recording != null:
		return _last_recording
	
	var wav_audio = AudioStreamWAV.new()
	
	# Configure the resource properties
	wav_audio.format = AudioStreamWAV.FORMAT_16_BITS if format == 1 else AudioStreamWAV.FORMAT_8_BITS
	wav_audio.mix_rate = int(AudioServer.get_input_mix_rate()) if use_input_mix_rate else int(mix_rate)
	wav_audio.stereo = stereo
	
	# Process the bytes based on the selected format
	var byte_array: PackedByteArray
	if format == 0:
		byte_array = _format_to_8_bits(_recording_buffer)
	elif format == 1:
		byte_array = _format_to_16_bits(_recording_buffer)
	else:
		push_error("Use get_recording_as_wav24b method to export as 24 bits")
	
	wav_audio.data = byte_array
	_last_recording = wav_audio
	
	return wav_audio

## Generates and returns a custom 24-bit AudioStreamWAV24B resource.
func get_recording_as_wav24b() -> AudioStreamWAV24B:
	var target_mix_rate = int(AudioServer.get_input_mix_rate() if use_input_mix_rate else mix_rate)
	return AudioStreamWAV24B.load_from_buffer(_recording_buffer, target_mix_rate, stereo)

## Takes an existing stereo AudioStreamWAV and returns a new mono version of it.
func convert_to_mono(original_stream: AudioStreamWAV) -> AudioStreamWAV:
	if not original_stream.stereo:
		return original_stream # Already mono

	var stereo_data: PackedByteArray = original_stream.data
	var mono_data: PackedByteArray = PackedByteArray()
	
	# Determine byte size based on the audio format (1 byte for 8-bit, 2 for 16-bit)
	var bytes_per_sample: int = 2 if original_stream.format == AudioStreamWAV.FORMAT_16_BITS else 1
	var frame_size: int = bytes_per_sample * 2 # Left + Right
	
	# Extract only the left channel from the raw data
	for i in range(0, stereo_data.size(), frame_size):
		for byte_index in range(bytes_per_sample):
			if i + byte_index < stereo_data.size():
				mono_data.append(stereo_data[i + byte_index])
	
	var mono_stream = AudioStreamWAV.new()
	mono_stream.format = original_stream.format
	mono_stream.mix_rate = original_stream.mix_rate
	mono_stream.stereo = false
	mono_stream.data = mono_data
	
	return mono_stream

# --- Volume Monitoring ---

## Calculates the linear volume (0.0 to 1.0) using Root Mean Square (RMS).
func _get_input_volume_rms(frames: PackedVector2Array) -> float:
	if frames.is_empty():
		return _last_rms_volume_db
		
	var sum_of_squares: float = 0.0
	
	for frame in frames:
		# Square both channels (Left and Right)
		sum_of_squares += frame.x * frame.x
		sum_of_squares += frame.y * frame.y
		
	# Calculate the mean (average). 
	# We multiply frames.size() by 2 because each frame has 2 channels.
	var mean_square: float = sum_of_squares / (frames.size() * 2)
	
	# Return the square root of the mean
	_last_rms_volume_db = sqrt(mean_square)
	
	return _last_rms_volume_db

## Returns the current average input volume in linear scale (0.0 to 1.0).
func get_input_volume_lineal() -> float:
	return _get_input_volume_rms(_last_audio_samples)

## Returns the current average input volume in Decibels (dB).
func get_input_volume_db() -> float:
	var linear_vol = _get_input_volume_rms(_last_audio_samples)
	return linear_to_db(linear_vol)

## Internal helper to calculate peak volume in Decibels. Returns Vector2(Left dB, Right dB).
func _get_peak_volume_db(frames: PackedVector2Array) -> Vector2:
	if frames.is_empty():
		return _last_peak_volume_db
		
	var peak_left: float = 0.0
	var peak_right: float = 0.0
	
	for frame in frames:
		# Extract the absolute amplitude value using absf()
		var abs_l: float = absf(frame.x)
		var abs_r: float = absf(frame.y)
		
		# Update the peak if this frame is louder than our recorded peak
		if abs_l > peak_left:
			peak_left = abs_l
		if abs_r > peak_right:
			peak_right = abs_r
			
	# Convert linear peaks to Decibels
	var db_left: float = linear_to_db(peak_left)
	var db_right: float = linear_to_db(peak_right)
	
	_last_peak_volume_db = Vector2(db_left, db_right)
	
	return _last_peak_volume_db

## Returns the peak volume of the current frame in Decibels as a Vector2 (X = Left, Y = Right).
func get_peak_volume_db() -> Vector2:
	return _get_peak_volume_db(_last_audio_samples)
