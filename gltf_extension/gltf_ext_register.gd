@tool extends Node

@export var extensions_to_register:Array[GLTFDocumentExtension]


func _ready():
	print("registering extensions")
	for extension in extensions_to_register:
		print(extension)
		GLTFDocument.register_gltf_document_extension(extension)
