extends Resource
class_name ReferenceClip

var transcript : String
var sound : AudioStream

var audioStreamPath : String

var noRepeat = false

func getAudioStream():
	sound = load(audioStreamPath)


func getLength() -> float:
	if !sound:
		return 0
	return sound.get_length()

#clears the audio stream from memory so it doesn't take up ram.
func clearAudioStream():
	sound = null
