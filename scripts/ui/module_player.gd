extends Control

var module : Module
var clipNum = 0 #-1 so when it increases it's fine

enum STATES {REFERENCE,RECORDING,PLAYBACK,AWAITING,NULL}
var state : STATES = STATES.REFERENCE
var paused : bool = false

@onready var recorder : VolumeAwareDirectAudioInputRecorder = $Recorder
@onready var recorderPlayback : AudioStreamPlayerWav24B = $recordingPlayback
@onready var defaultPlayer = $anythingPlayer

@export var startSpeakingSound : AudioStream
@export var stopSpeakingSound : AudioStream
@export var referenceSound : AudioStream

@onready var stoplight : ColorRect = $MarginContainer/VBoxContainer/stoplight
@onready var stoplightLabel : Label = $MarginContainer/VBoxContainer/stoplight/Label

func _ready() -> void:
	
	Globals.Settings.loadSettings()
	
	module = Globals.currentModule
	
	recorder.secondsOfSilenceBeforeShutoff = 1.0
	recorder.minimumVolumeToRecord = -30
	
	pass

var timer : float = 0.0
#the amount of time you have to repeat the phrase compared to original duration
var timeMultiplier = 2.0

#slows down the loop so it's not so compact
var DELAY_DURATION = 0.2
var LONG_DELAY_DURATION = 1.0

var driveTween : Tween
func _physics_process(delta: float) -> void:
	
	if paused:
		stoplight.color = Color.PURPLE
		stoplightLabel.text = "Paused"
		return
	
	#animating the stoplight
	if recorder.is_recording():
		
		var audible = recorder._volumeAudible()
		if audible:
			stoplight.color = Color.GREEN
		elif recorder.hasReachedMinimumVolume:
			stoplight.color = Color.YELLOW
		else:
			stoplight.color = Color.RED
		
		
		var text = ""
		text += str(snapped(recorder.forceShutoffTime - recorder.recordingTimer,0.1))
		text += "\n"
		text += str(snapped(recorder.secondsOfSilenceBeforeShutoff - recorder.secondsSinceReachingMinimumVolume,0.1))
		
		stoplightLabel.text = text
		
	else:
		stoplight.color = Color.DIM_GRAY
		stoplightLabel.text = ""
	
	if !driveTween or !driveTween.is_running():
		if driveTween:
			driveTween.kill()
		
		
		
		
		
		var currentClip : ReferenceClip = module.references[clipNum]
		currentClip.getAudioStream()
		var sound = currentClip.sound
		var currentClipLength : float = currentClip.getLength()
		currentClip.clearAudioStream() #garbage collection
		
		
		print(clipNum)
		updateClipNumLabel()
		
		clipNum += 1
		if clipNum >= module.getClipNum():
			clipNum = 0
		
		driveTween = create_tween()
		driveTween.tween_property(defaultPlayer,"stream",referenceSound,0.0)
		driveTween.tween_callback(defaultPlayer.play)
		driveTween.tween_await(defaultPlayer.finished)
		
		driveTween.tween_property(defaultPlayer,"stream",sound,0.0).set_delay(DELAY_DURATION)
		driveTween.tween_callback(defaultPlayer.play)
		driveTween.tween_await(defaultPlayer.finished)
		
		driveTween.tween_property(defaultPlayer,"stream",startSpeakingSound,0.0).set_delay(DELAY_DURATION)
		driveTween.tween_callback(defaultPlayer.play)
		driveTween.tween_await(defaultPlayer.finished)
		
		driveTween.tween_property(
			recorder,
			"forceShutoffTime",
			currentClipLength * timeMultiplier,
			0.0).set_delay(DELAY_DURATION)
		driveTween.tween_callback(recorder.start_capturing).set_delay(DELAY_DURATION) #this delay prevents it hearing itself
		driveTween.tween_await(recorder.on_recording_end)
		
		driveTween.tween_property(defaultPlayer,"stream",stopSpeakingSound,0.0).set_delay(DELAY_DURATION)
		driveTween.tween_callback(defaultPlayer.play)
		driveTween.tween_await(defaultPlayer.finished)
		
		
		driveTween.tween_callback(self.playBackRecording).set_delay(DELAY_DURATION)
		
		driveTween.tween_await(recorderPlayback.finished)
		driveTween.tween_callback(self.foo).set_delay(LONG_DELAY_DURATION)
		
	
	
	

func foo():
	pass
	#does nothing

func updateClipNumLabel():
	var currentClip : ReferenceClip = module.references[clipNum]
	var currentClipLength : float = currentClip.getLength()
	
	$"MarginContainer/VBoxContainer/clip number".text = str(clipNum + 1) + "/" + str(module.getClipNum())
	$MarginContainer/VBoxContainer/transcript.text = currentClip.transcript

func stopEverything():
	if recorder.is_recording():
		recorder.stop_capturing()
	if driveTween:
		driveTween.kill()
		driveTween = null
	
	recorderPlayback.playing = false
	defaultPlayer.playing = false
	

func playBackRecording():
	var recording : AudioStreamWAV24B = recorder.get_recording_as_wav24b()
	recorderPlayback.play_24bit(recording)
	

func _on_pause_pressed() -> void:
	paused = !paused
	
	if paused:
		stopEverything()
		clipNum -= 1 #undoing the increment of clip num
		if clipNum < -1:
			clipNum = 0
		%pause.text = "Unpause"
	else:
		
		%pause.text = "Pause"
	
	
	pass # Replace with function body.


func _on_module_select_pressed() -> void:
	get_tree().change_scene_to_file(Constants.Paths.moduleSelect)


func _on_prev_pressed() -> void:
	stopEverything()
	
	clipNum -= 2 #clipnum is immediately increased by the main loop
	if clipNum < 0:
		clipNum = module.getClipNum() - 1
	


func _on_next_pressed() -> void:
	#prints("next pressed!",clipNum)
	stopEverything()
	#clipNum += 1
	if clipNum >= module.getClipNum():
		clipNum = 0


func _on_shuffle_pressed() -> void:
	module.references.shuffle()


func _on_settings_pressed() -> void:
	pass # Replace with function body.
