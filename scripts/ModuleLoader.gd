extends Node
class_name ModuleLoader

const tempExtractPath = "user://temp/extracts"
const audioFileFolderName = "audioFiles"

const metaDataFileName = "metadata.json"
const exportPath : String = "user://exports"

#this is a tempory location where files are loaded before they get zipped
const tempExportPath : String = "user://temp/exports"
const exportFolderExtension : String = ".module"


static func getModuleFromPath(path : String) -> Module:
	
	extract_all_from_zip(path)
	
	var module : Module = createWorkingModuleFromDir(tempExtractPath)
	
	for file in DirAccess.get_files_at(tempExtractPath):
		DirAccess.remove_absolute(tempExtractPath.path_join(file))
	var audioFilesPath = tempExtractPath.path_join(audioFileFolderName)
	for file in DirAccess.get_files_at(audioFilesPath):
		DirAccess.remove_absolute(audioFilesPath.path_join(file))
	
	
	return module


# Extract all files from a ZIP archive, preserving the directories within.
# This acts like the "Extract all" functionality from most archive managers.
static func extract_all_from_zip(path: String):
	var reader = ZIPReader.new()
	reader.open(path)
	
	# Destination directory for the extracted files (this folder must exist before extraction).
	# Not all ZIP archives put everything in a single root folder,
	# which means several files/folders may be created in `root_dir` after extraction.
	DirAccess.make_dir_recursive_absolute(tempExtractPath)
	var root_dir = DirAccess.open(tempExtractPath)
	
	var files = reader.get_files()
	for file_path in files:
		# If the current entry is a directory.
		if file_path.ends_with("/"):
			root_dir.make_dir_recursive(file_path)
			continue
	
		# Write file contents, creating folders automatically when needed.
		# Not all ZIP archives are strictly ordered, so we need to do this in case
		# the file entry comes before the folder entry.
		root_dir.make_dir_recursive(root_dir.get_current_dir().path_join(file_path).get_base_dir())
		var file = FileAccess.open(root_dir.get_current_dir().path_join(file_path), FileAccess.WRITE)
		var buffer = reader.read_file(file_path)
		file.store_buffer(buffer)

static func createWorkingModuleFromDir(dir : String) -> Module:
	print("folder selected!")
	var metaDataFile = FileAccess.open(dir.path_join(metaDataFileName), FileAccess.READ)
	
	var workingModule : Module = Module.new()
	var json_string = metaDataFile.get_line() #this is the first line
	var json = JSON.new()
	
	# Check if there is any error while parsing the JSON string, skip in case of failure.
	var parse_result = json.parse(json_string)
	if not parse_result == OK:
		print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
		return
	
	# Get the data from the JSON object.
	var node_data = json.data
	
	# Now we set the values of the module itself
	for key in node_data.keys():
		workingModule.set(key, node_data[key])
	
	
	while metaDataFile.get_position() < metaDataFile.get_length():
		
		var currentReferenceClip : ReferenceClip = ReferenceClip.new()
		
		json_string = metaDataFile.get_line() #this is the first line
		json = JSON.new()
		
		# Check if there is any error while parsing the JSON string, skip in case of failure.
		parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			return
		
		# Get the data from the JSON object.
		node_data = json.data
		
		# Now we set the remaining variables.
		for key in node_data.keys():
			
			currentReferenceClip.set(key, node_data[key])
		
		currentReferenceClip.audioStreamLocation = (dir.path_join(audioFileFolderName))
		currentReferenceClip.getAudioStream()
		
		workingModule.references.append(currentReferenceClip)
	
	return workingModule
	
