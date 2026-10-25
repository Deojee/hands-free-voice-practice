extends Control

var module : Module
var clipNum = 0

enum STATES {REFERENCE,RECORDING,PLAYBACK,NULL}
var state : STATES = STATES.REFERENCE
var paused : bool = false

func _ready() -> void:
	module = Globals.currentModule
	clipNum = -1
	setState(STATES.REFERENCE)
	pass

var timer : float = 0.0
#the amount of time you have to repeat the phrase compared to original duration
var timeMultiplier = 1.5 
func _physics_process(delta: float) -> void:
	
	var currentClip : ReferenceClip = module.references[clipNum]
	var currentClipLength : float = currentClip.getLength()
	
	#Null means it won't change state
	var changeStateTo : STATES = STATES.NULL 
	timer += delta
	
	match state:
		STATES.REFERENCE:
			if !$referencePlayer.playing:
				changeStateTo = STATES.RECORDING
				timer = 0.0
		STATES.RECORDING:
			if timer > currentClipLength * timeMultiplier:
				changeStateTo = STATES.PLAYBACK
		STATES.PLAYBACK:
			if !$recordingPlayback.playing:
				changeStateTo = STATES.REFERENCE
	
	
	if changeStateTo != STATES.NULL:
		setState(changeStateTo)
	

func setState(newState : STATES):
	
	
	match newState:
		STATES.REFERENCE:
			clipNum += 1
			if clipNum > module.getClipNum():
				clipNum = 0
			var reference = module.references[clipNum]
			
			$referencePlayer.stream = reference.sound
			$referencePlayer.play()
			
			$"MarginContainer/VBoxContainer/clip number".text = str(clipNum) + "/" + str(module.getClipNum())
			$MarginContainer/VBoxContainer/stoplight.color = Color.RED
			$MarginContainer/VBoxContainer/transcript.text = reference.transcript
		STATES.RECORDING:
			$MarginContainer/VBoxContainer/stoplight.color = Color.GREEN
			$Recorder.start_capturing()
		STATES.PLAYBACK:
			$Recorder.stop_capturing()
			var recording : AudioStreamWAV24B  = $Recorder.get_recording_as_wav24b()
			
			# Save it to the user folder
			#recording.save_to_wav("user://high_fidelity_capture.wav")
			
			# Play it back immediately
			$recordingPlayback.play_24bit(recording)
	
	state = newState
	

func _on_pause_pressed() -> void:
	paused = !paused
	
	if paused:
		
		pass
	
	
	pass # Replace with function body.
