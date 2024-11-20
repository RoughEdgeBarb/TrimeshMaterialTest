extends RayCast3D


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test"):
		var collision_material = get_collision_material()
		if collision_material:
			print(collision_material, " ", collision_material.resource_name)


func get_collision_material() -> Material:
	if !is_colliding():
		print("Not colliding")
		return null
	
	var face_index:int = get_collision_face_index()
	if face_index == -1:
		# convex shape, handle separately
		return null
	
	# find mesh
	var collider_parent = get_collider().get_parent()
	var mesh_instance:MeshInstance3D = collider_parent
	# Assuming static body is child of mesh for testing purposes
	if !mesh_instance:
		push_warning("No valid mesh as parent of physics body")
		return null
	
	var mesh:Mesh = mesh_instance.mesh as Mesh
	if !mesh:
		push_warning("No valid mesh on mesh instance")
		return null
	
	# if mesh.get_surface_count() == 1 then just use that one
	# check for surface material override on geometry instance
	# not added for testing purposes
	
	var collider:ConcavePolygonShape3D = get_collider().get_child(get_collider_shape()).shape
	# probably bad assumption, fine for testing
	if !collider:
		push_warning("no collider found")
		return null
	elif collider.get_faces().size() != mesh.get_faces().size():
		push_warning("Mesh is not identical to concave collider")
		return null
	
	var surface_count:int = mesh.get_surface_count()
	var surface_face_count:int = 0
	for i in surface_count:
		var surface_arrays:Array = mesh.surface_get_arrays(i)
		var surface_index_array:Array = surface_arrays[Mesh.ArrayType.ARRAY_INDEX]
		# ARRAY_INDEX contains the winding order for all verts, like 132 is a tri using vert 1, 3, then 2
		# So we can get the number of faces in this surface using size()/3
		var index_array_size:int = surface_index_array.size()
		@warning_ignore("integer_division")
		surface_face_count += index_array_size/3
		if face_index <= surface_face_count:
			return mesh.surface_get_material(i)
	
	return null
