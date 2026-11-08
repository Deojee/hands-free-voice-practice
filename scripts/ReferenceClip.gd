extends Resource
class_name ReferenceClip

var transcript : String


var sound : AudioStream

var audioStreamLocation : String = ""
var audioStreamPath : String

## no repeat means that the program should not
##wait for the user to repeat this clip
var noRepeat : float = false
var numRepeat : int = 1


func getAudioStream():
	sound = load(audioStreamLocation.path_join(audioStreamPath))

#clears the audio stream from memory so it doesn't take up ram.
func clearAudioStream():
	sound = null


func getLength() -> float:
	if !sound:
		return 0
	return sound.get_length()

func getDict():
	
	return {
		"transcript" : transcript,
		"audioStreamLocation" : audioStreamLocation,
		"audioStreamPath" : audioStreamPath,
		"noRepeat" : noRepeat,
		"numRepeat" : numRepeat
	}
	
