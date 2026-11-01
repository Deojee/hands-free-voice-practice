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

var totalInputFrames : int = 0

func _ready() -> void:
	# Enable the microphone input in the Godot AudioServer
	AudioServer.set_input_device_active(true)
	

func _physics_process(delta: float) -> void:
	
	
	
	if !_is_recording:
		return
	
	# Fetch the available frames from the microphone buffer
	_last_audio_samples = AudioServer.get_input_frames(AudioServer.get_input_frames_available())
	on_input_frame_captured.emit(_last_audio_samples, delta)
	totalInputFrames += _last_audio_samples.size()
	
	recordingTimer += delta
	
	#print(_last_audio_samples.size())
	
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
	totalInputFrames = 0
	
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
	
	Globals.lastRecordingSize = sizeToTrimSilence
	
# --- Formatting Methods ---





# --- Resource Generation ---



func get_recording_as_wav24b() -> AudioStreamWAV24B:
	#var target_mix_rate = int(AudioServer.get_input_mix_rate() if use_input_mix_rate else mix_rate)
	
	var theoreticalMixRate = totalInputFrames/recordingTimer
	prints(theoreticalMixRate,totalInputFrames,recordingTimer)
	
	return AudioStreamWAV24B.load_from_buffer(_recording_buffer, theoreticalMixRate, stereo)
