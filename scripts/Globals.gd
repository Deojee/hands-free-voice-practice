extends Object

class_name Globals

static var currentModule : Module


class Settings:
	
	#volume, playback volume, indicator sound volume, silenceBeforeCutoff record cutoff multiplier, delay after recording playback, ambient noise, 
	
	static var referenceVolume : float = 5 #0 being not changing it
	static var recordingVolume : float = 5
	static var indicatorVolume : float = 5 #the volume of the helpful sounds
	
	static var secondsOfSilenceBeforeCutoff : float = 1.0
	static var minVolumeToRecord : float = -30
	static var recordingTimeMultiplier : float = 1.5
	
	static var shortDelayLength : float = 0.1
	static var longDelayLength : float = 1.0
	
	const SETTINGS_LOCATION : String = "user://settingsSave.save"
	
	
	func saveSettings():
		var save_file = FileAccess.open(SETTINGS_LOCATION, FileAccess.WRITE)
		
		var data = {
			"referenceVolume" : referenceVolume,
			"recordingVolume" : recordingVolume,
			"indicatorVolume" : indicatorVolume,
			"secondsOfSilenceBeforeCutoff" : secondsOfSilenceBeforeCutoff,
			"minVolumeToRecord" : minVolumeToRecord,
			"recordingTimeMultiplier" : recordingTimeMultiplier,
			"shortDelayLength" : shortDelayLength,
			"longDelayLength" : longDelayLength,
		}
		
		# JSON provides a static method to serialized JSON string.
		var json_string = JSON.stringify(data)
		
		# Store the save dictionary as a new line in the save file.
		save_file.store_line(json_string)
	
	static func loadSettings():
		if not FileAccess.file_exists(SETTINGS_LOCATION):
			return # Error! We don't have a save to load.
		
		
		# Load the file line by line and process that dictionary to restore
		# the object it represents.
		var save_file = FileAccess.open(SETTINGS_LOCATION, FileAccess.READ)
		
		var json_string = save_file.get_line()
		
		# Creates the helper class to interact with JSON.
		var json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		
		# Get the data from the JSON object.
		var node_data = json.data
		
		# Now we set the remaining variables.
		for i in node_data.keys():
			
			Globals.Settings.staticSet(i, node_data[i])
			
	
	static func staticSet(name : String, value : Variant):
		match name:
			"referenceVolume":
				referenceVolume = value
			"recordingVolume":
				recordingVolume = value
			"indicatorVolume":
				indicatorVolume = value
			"secondsOfSilenceBeforeCutoff":
				secondsOfSilenceBeforeCutoff = value
			"minVolumeToRecord":
				minVolumeToRecord = value
			"recordingTimeMultiplier":
				recordingTimeMultiplier = value
			"shortDelayLength":
				shortDelayLength = value
			"longDelayLength":
				longDelayLength = value
			_:
				print("Attempt to static set nonexistant property")
			
	
	
	
