extends RayCast3D


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("test"):
		var time:float = Time.get_unix_time_from_system()
		var collision_material = get_collision_material_by_metadata_face_index()
		print("Time " , Time.get_unix_time_from_system() - time)
		if collision_material:
			print(collision_material, " ", collision_material.resource_name)


func get_collision_material_by_metadata_face_index() -> Material:
	if !is_colliding():
		print("Not colliding")
		return null
	
	var face_index:int = get_collision_face_index()
	if face_index == -1:
		# convex shape, handle separately
		print("convex shape, ", get_collider().name)
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
	
	# Test that 
	if !mesh_instance.has_meta(&"surface_face_count"):
		push_warning("No metadata")
		return null
	
	# Check trimesh collider is valid
	var face_counts:Array = mesh_instance.get_meta(&"surface_face_count")
	var total_faces:int = 0
	for count in face_counts:
		total_faces += count
	var collider:ConcavePolygonShape3D = get_collider().get_child(get_collider_shape()).shape
	# probably bad assumption, fine for testing
	if !collider:
		push_warning("no collider found")
		return null
	elif collider.get_faces().size() != total_faces*3: # getting collider face count is sorta expensive, 1ms cost, could also cache on import?
		push_warning("Mesh is not identical to concave collider")
		return null
	
	var surface_face_counts:Array =  mesh_instance.get_meta(&"surface_face_count")
	var surface_face_count:int = 0
	for i in surface_face_counts.size():
		surface_face_count += surface_face_counts[i]
		if face_index <= surface_face_count:
			return mesh.surface_get_material(i)
	return null


func get_collision_material_by_face_index() -> Material:
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
		# ARRAY_INDEX contains the winding order for all verts, like 132 is a tri using vert 1, 3, then 2
		# So we can get the number of faces in this surface using size()/3
		@warning_ignore("integer_division")
		surface_face_count += mesh.surface_get_arrays(i)[Mesh.ArrayType.ARRAY_INDEX].size()/3
		if face_index <= surface_face_count:
			return mesh.surface_get_material(i)
	
	#for i in surface_count:
		#var surface_arrays:Array = mesh.surface_get_arrays(i)
		#var surface_index_array:Array = surface_arrays[Mesh.ArrayType.ARRAY_INDEX]
		## ARRAY_INDEX contains the winding order for all verts, like 132 is a tri using vert 1, 3, then 2
		## So we can get the number of faces in this surface using size()/3
		#var index_array_size:int = surface_index_array.size()
		#@warning_ignore("integer_division")
		#surface_face_count += index_array_size/3
		#if face_index <= surface_face_count:
			#return mesh.surface_get_material(i)
	
	return null


## Just as slow as raycasting basically because of mdt cost
func get_collision_material_by_face_index_mdt() -> Material:
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
	
	#var surface_count:int = mesh.get_surface_count()
	var surface_face_count:int = 0
	
	var mdt_array:Array[MeshDataTool] = []
	for surfaces in range(mesh.get_surface_count()): # add an mdt for each surface in mesh
		var mdt:MeshDataTool = MeshDataTool.new()
		mdt.create_from_surface(mesh, surfaces)
		mdt_array.append(mdt)
	var i = 0
	for mdt in mdt_array:
		surface_face_count += mdt.get_face_count()
		if face_index <= surface_face_count:
			return mesh.surface_get_material(i)
		i += 1
	
	#for i in surface_count:
		## ARRAY_INDEX contains the winding order for all verts, like 132 is a tri using vert 1, 3, then 2
		## So we can get the number of faces in this surface using size()/3
		#@warning_ignore("integer_division")
		#surface_face_count += mesh.surface_get_arrays(i)[Mesh.ArrayType.ARRAY_INDEX].size()/3
		#if face_index <= surface_face_count:
			#return mesh.surface_get_material(i)
	
	return null


const RAY_LENGTH:float = 0.01
@onready var geometry_instance = Geometry3D

func get_collisison_material_by_raycasting() -> Material:
	var collided = get_collider()
	var normal = get_collision_normal()
	var point = get_collision_point()
	
	if collided is CSGShape3D:
		return null
	var geo:MeshInstance3D
	var geo_mesh:Mesh
	
	for i in range(0, collided.get_child_count()): # check children for mesh
		if collided.get_child(i) is MeshInstance3D:
			geo = collided.get_child(i)
			break
	if geo == null: # if there are no direct child meshes check parent
		if collided.get_parent() is MeshInstance3D:
			geo = collided.get_parent()
	
	if geo and geo.get("mesh"):
		geo_mesh = geo.mesh
	
	if geo_mesh:
		if geo_mesh.get_surface_count() == 1: # trivial case
			return geo_mesh.surface_get_material(0) # remove if testing performance
		
		var mdt_array:Array[MeshDataTool] = []
		for surfaces in range(geo_mesh.get_surface_count()): # add an mdt for each surface in mesh
			var mdt:MeshDataTool = MeshDataTool.new()
			mdt.create_from_surface(geo_mesh, surfaces)
			mdt_array.append(mdt)
		
		for mdts in mdt_array: # iterate through all mdts until an intersection is found
			
			# Only check faces that whose normals align, does not work for simplified collisions
			var faces_id:Array[int] = []
			for faces in range(mdts.get_face_count()):
				if mdts.get_face_normal(faces).is_equal_approx(normal):
					faces_id.append(faces)
			
			for faces in faces_id:
				var from_ray:Vector3 = point + normal * RAY_LENGTH
				var ray_dir:Vector3 = normal * -2 * RAY_LENGTH
				var face_vert_ids:Array[int] = [mdts.get_face_vertex(faces, 0), mdts.get_face_vertex(faces, 1), mdts.get_face_vertex(faces, 2)]
				var tri_points_local:Array[Vector3] = [mdts.get_vertex(face_vert_ids[0]), mdts.get_vertex(face_vert_ids[1]), mdts.get_vertex(face_vert_ids[2])]
				var tri_points_global:Array[Vector3] = [geo.to_global(tri_points_local[0]), geo.to_global(tri_points_local[1]), geo.to_global(tri_points_local[2])]
				if geometry_instance.ray_intersects_triangle(from_ray, ray_dir, tri_points_global[0], tri_points_global[1], tri_points_global[2]):
					# Raycast needs origin and direction, and the points of each vert in tri
					return mdts.get_material()
	
	return null
