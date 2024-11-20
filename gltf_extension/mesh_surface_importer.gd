@tool
class_name MeshSurfaceImporter extends GLTFDocumentExtension

func _import_preflight(_state, _extensions):
	return OK

func _import_node(_state:GLTFState, _gltf_node:GLTFNode, _json:Dictionary, node:Node):
	if node is ImporterMeshInstance3D:
		var mesh:ImporterMesh = node.mesh
		var surface_face_count:Array[int] = []
		var surface_count:int = mesh.get_surface_count()
		for i in surface_count:
			@warning_ignore("integer_division")
			surface_face_count.append(mesh.get_surface_arrays(i)[Mesh.ArrayType.ARRAY_INDEX].size()/3)
		node.set_meta(&"surface_face_count", surface_face_count)
	return OK
