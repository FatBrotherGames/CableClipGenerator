@tool
extends Node3D

#CLEAN UP THIS. THIS IS NOW FEATURE COMPLETE

# Rotation for exported stl files. Used to correctly rotate the parts for the 3d printer  
@export var export_rotation: Vector3 = Vector3(0,90,0)
# Space between parts. millimeter
@export_range(0.0, 100.0, 0.05) var space_between: float = 1.25

#UI
@export var item_list_selectable_parts: ItemList
@export var item_list_current_build: ItemList
@export var check_box_automated_export_name: CheckBox
@export var part_parent: Node3D
@export var spin_box: SpinBox
@export var merge_mi : MeshInstance3D

# Array of all selected parts to generate
var part_list : Array[ClipDataDict] = []
# Contains all arraymeshes from the .stl files
var preloaded_stl_data: Array[ClipDataDict]
# For save path location. Once selected, the next time will use the path given
var used_path : String = ""
# The arraymesh of the merged part to get converted to a .stl file for export
var export_mesh: ArrayMesh

#region EditorDebugButtons
var baked_mesh: ArrayMesh
@export_group("Debug Functions")
@export var debug_clips_list: Array[Gc.PARTS] = []

@export var preload_debug_meshes : bool = false : 
	set(value):
		if value:
			load_debug_meshes = false
			preload_all_meshes()

@export var load_debug_meshes : bool = false : 
	set(value):
		if value:
			load_debug_meshes = false
			for n in part_parent.get_children():
				n.queue_free()
			part_list = []
			merge_mi.mesh = Mesh.new()
			
			for i in debug_clips_list.size():
				var clip: ClipDataDict = ClipDataDict.new()
				clip.part_id = debug_clips_list[i]
				var new_mesh = get_preloaded_array_mesh(clip.part_id)
				clip.arraymesh = new_mesh#rotate_arraymesh(new_mesh, Vector3(deg_to_rad(0), deg_to_rad(0), deg_to_rad(0)))
				part_list.append(clip)

@export var generate_debug_meshes : bool = false : 
	set(value):
		if value:
			generate_debug_meshes = false
			generate_mi_mesh()

@export var merge_multile_into_one : bool = false : 
	set(value):
		if value:
			merge_multile_into_one = false
			var instances : Array[MeshInstance3D] = []
			for n in part_parent.get_children():
				instances.append(n as MeshInstance3D)
			merge_mi.mesh = merge_meshinstances(instances).mesh

@export var convert_merged_instance : bool = false : 
	set(value):
		if value:
			convert_merged_instance = false
			baked_mesh = meshinstance_to_arraymesh(merge_mi)
			
@export var export_merged_instance : bool = false : 
	set(value):
		if value:
			export_merged_instance = false
			# Rotates the final stl to the preferred print rotation. 
			baked_mesh = rotate_arraymesh(baked_mesh, Vector3(deg_to_rad(export_rotation.x),deg_to_rad(export_rotation.y),deg_to_rad(export_rotation.z)))
			STLIO.Exporter.SaveToPath(baked_mesh, 'res://default_clips/baked29.stl')
@export_group("")
#endregion

func _ready() -> void:
	preload_all_meshes()
	populate_item_list()
	spin_box.value = space_between

func preload_all_meshes() -> void: 
	for part in Gc.get_parts_list():
		var clip_data = ClipDataDict.new()
		var path : String = Gc.get_part_path(part)
		var new_mesh = STLIO.Importer.LoadFromPath(path)
		clip_data.part_id = part
		clip_data.arraymesh = new_mesh
		preloaded_stl_data.append(clip_data)
		print("Preloaded: " + path)

func populate_item_list() -> void: 
	item_list_selectable_parts.clear()
	for part in Gc.get_parts_list():
		item_list_selectable_parts.add_item(Gc.get_part_name(part))

func add_clip_part(part_id: Gc.PARTS=Gc.PARTS.SPACER)-> void:
	var clip_data: ClipDataDict = ClipDataDict.new()
	clip_data.part_id = part_id
	var new_mesh : ArrayMesh = get_preloaded_array_mesh(clip_data.part_id)
	clip_data.arraymesh = new_mesh
	part_list.append(clip_data)
	item_list_current_build.add_item(Gc.get_part_name(part_id))
	generate_mi_mesh()

func remove_clip_part(index:int=-1)->void:
	if index == -1:
		index = part_list.size()-1
		part_list.pop_back()
	else:
		part_list.pop_at(index)
	
	generate_mi_mesh()
	item_list_current_build.remove_item(index)

func get_preloaded_array_mesh(id: Gc.PARTS)->ArrayMesh:
	var array_mesh:ArrayMesh = ArrayMesh.new()
	for i in preloaded_stl_data.size():
		if preloaded_stl_data[i].part_id == id:
			array_mesh = preloaded_stl_data[i].arraymesh
			return array_mesh
	return array_mesh

func generate_mi_mesh() -> void: ## generates all the meshles at once :)
	# Clear the generated meshes to then regenerate the new parts
	for n in part_parent.get_children():
		n.queue_free()

	
	var dis_y:float = 0.0
	# Is needed so the box meshes are colored correctly
	var surface_mat : StandardMaterial3D = StandardMaterial3D.new() 
	
	for index in part_list.size():
		var new_mi = MeshInstance3D.new()
		new_mi.mesh = part_list[index].arraymesh
		var aabb : AABB = new_mi.get_aabb()
		
		new_mi.position.y = dis_y
		dis_y += aabb.size.y
		if space_between != 0 and (index != part_list.size()-1):
			var box : BoxMesh = BoxMesh.new()
			var width:float = 10.0
			var height:float = space_between*1.02
			var depth:float = 2.0
			
			box.size = Vector3(width, height, depth)
			
			var st = SurfaceTool.new()
			st.create_from(box, 0)
			var array_mesh : ArrayMesh = st.commit()
			
			# Bake the offset directly into the mesh vertices
			var offset : Transform3D = Transform3D(Basis(), Vector3(width/2, dis_y + space_between/2, depth/2))
			var baked : ArrayMesh = ArrayMesh.new()
			var arrays : Array = array_mesh.surface_get_arrays(0)
			var verts : PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			for i in verts.size():
				verts[i] = offset * verts[i]
			arrays[Mesh.ARRAY_VERTEX] = verts
			baked.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)
			
			var inbetween_mi : MeshInstance3D = MeshInstance3D.new()
			inbetween_mi.mesh = baked
			inbetween_mi.set_surface_override_material(0, surface_mat)

			part_parent.add_child(inbetween_mi)
			inbetween_mi.owner = get_tree().edited_scene_root
			dis_y += space_between
			

		part_parent.add_child(new_mi)
		new_mi.owner = get_tree().edited_scene_root
	
	part_parent.position.z = dis_y/2

func rotate_arraymesh(mesh: ArrayMesh, _rotation: Vector3) -> ArrayMesh:
	var _basis : Basis = Basis.from_euler(_rotation)
	var result : ArrayMesh = ArrayMesh.new()

	for surf_idx in mesh.get_surface_count():
		var arrays : Array = mesh.surface_get_arrays(surf_idx)

		var verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		for i in verts.size():
			verts[i] = _basis * verts[i]

		var normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		if normals.size() > 0:
			for i in normals.size():
				normals[i] = (_basis * normals[i]).normalized()

		arrays[Mesh.ARRAY_VERTEX] = verts
		arrays[Mesh.ARRAY_NORMAL] = normals

		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, arrays)

		var mat : Material = mesh.surface_get_material(surf_idx)
		if mat:
			result.surface_set_material(surf_idx, mat)

	return result

func merge_meshinstances(instances: Array[MeshInstance3D]) -> MeshInstance3D:
	var merged : ArrayMesh = ArrayMesh.new()

	# Group surfaces by material so we minimize draw calls
	var groups: Dictionary = {}  # Material -> { verts, normals, uvs, indices }

	for mi in instances:
		var mesh = mi.mesh
		var t: Transform3D = mi.global_transform

		for surf_idx in mesh.get_surface_count():
			var mat : Material= mesh.surface_get_material(surf_idx)
			var arrays : Array = mesh.surface_get_arrays(surf_idx)

			var src_verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
			var src_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
			var src_indices: PackedInt32Array = []
			if arrays[Mesh.ARRAY_INDEX]:
				src_indices = arrays[Mesh.ARRAY_INDEX]

			if not groups.has(mat):
				groups[mat] = {
					"verts": PackedVector3Array(),
					"normals": PackedVector3Array(),
					"uvs": PackedVector2Array(),
					"indices": PackedInt32Array(),
					"offset": 0
				}

			var g = groups[mat]
			var flip = sign(t.basis.determinant())

			for v in src_verts:
				g.verts.append(t * v)

			if src_normals.size() > 0:
				for n in src_normals:
					g.normals.append((t.basis * n).normalized() * flip)

			if src_indices.size() > 0:
				for idx in src_indices:
					g.indices.append(idx + g.offset)

			g.offset += src_verts.size()

	# Build one surface per material
	var surf_idx = 0
	for mat in groups:
		var g = groups[mat]
		var new_arrays = []
		new_arrays.resize(Mesh.ARRAY_MAX)
		new_arrays[Mesh.ARRAY_VERTEX] = g.verts
		if g.normals.size() > 0:
			new_arrays[Mesh.ARRAY_NORMAL] = g.normals
		if g.uvs.size() > 0:
			new_arrays[Mesh.ARRAY_TEX_UV] = g.uvs
		if g.indices.size() > 0:
			new_arrays[Mesh.ARRAY_INDEX] = g.indices

		merged.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arrays)
		merged.surface_set_material(surf_idx, mat)
		surf_idx += 1

	var result = MeshInstance3D.new()
	result.mesh = merged
	return result

func meshinstance_to_arraymesh(mi: MeshInstance3D) -> ArrayMesh:
	var result = ArrayMesh.new()
	var mesh = mi.mesh
	var t: Transform3D = mi.global_transform
	var flip = sign(t.basis.determinant())

	for surf_idx in mesh.get_surface_count():
		var arrays = mesh.surface_get_arrays(surf_idx)

		var src_verts: PackedVector3Array = arrays[Mesh.ARRAY_VERTEX]
		var src_normals: PackedVector3Array = arrays[Mesh.ARRAY_NORMAL]
		var src_indices: PackedInt32Array = []
		if arrays[Mesh.ARRAY_INDEX]:
			src_indices = arrays[Mesh.ARRAY_INDEX]

		var new_verts = PackedVector3Array()
		var new_normals = PackedVector3Array()

		for v in src_verts:
			new_verts.append(t * v * -1)

		if src_normals.size() > 0:
			for n in src_normals:
				new_normals.append((t.basis * n).normalized() * -flip)

		var new_arrays = []
		new_arrays.resize(Mesh.ARRAY_MAX)
		new_arrays[Mesh.ARRAY_VERTEX] = new_verts
		if new_normals.size() > 0:
			new_arrays[Mesh.ARRAY_NORMAL] = new_normals
		if src_indices.size() > 0:
			new_arrays[Mesh.ARRAY_INDEX] = src_indices

		result.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, new_arrays)
		result.surface_set_material(surf_idx, mesh.surface_get_material(surf_idx))

	return result

func start_save_process()->void:
	if part_list.is_empty():
		return
	var instances : Array[MeshInstance3D] = []
	for n in part_parent.get_children():
		instances.append(n as MeshInstance3D)
	merge_mi.mesh = merge_meshinstances(instances).mesh
	export_mesh = meshinstance_to_arraymesh(merge_mi)
	export_mesh = rotate_arraymesh(export_mesh, Vector3(deg_to_rad(export_rotation.x),deg_to_rad(export_rotation.y),deg_to_rad(export_rotation.z)))
	
	var export_name:String = ""
	if check_box_automated_export_name.button_pressed:
		export_name = generate_export_name()

	open_save_dialog(export_name)

func generate_export_name()->String:
	var export_name = ""
	for index in part_list.size():
		var clip:ClipDataDict = part_list[index]
		if index != 0:
			export_name += "_"
		export_name += Gc.get_part_shortcut(clip.part_id)
	
	return export_name

func open_save_dialog(automated_name:String=""):
	var dialog = FileDialog.new()
	dialog.title = "Save Cable Clip Export"
	dialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	dialog.access = FileDialog.ACCESS_FILESYSTEM
	dialog.add_filter("*.stl", "STL Files")
	dialog.file_selected.connect(file_path_selected)

	var export_dir : String = ProjectSettings.globalize_path("res://export")
	if used_path != "":
		export_dir = used_path
	dialog.current_dir = export_dir
	if automated_name == "":
		dialog.current_file = "cable_clip_export.stl"
	else:
		dialog.current_file = automated_name
	
	add_child(dialog)
	dialog.popup_centered_ratio()

func file_path_selected(path:String="")->void:
	used_path = path.get_base_dir()
	STLIO.Exporter.SaveToPath(export_mesh, path)

func _on_item_list_item_activated(index: int) -> void:
	add_clip_part(index)

func _on_item_list_current_build_item_activated(index: int) -> void:
	remove_clip_part(index)

func _on_delete_button_pressed() -> void:
	remove_clip_part()

func _on_spin_box_value_changed(value: float) -> void:
	space_between = value
	generate_mi_mesh()

func _on_add_button_pressed() -> void:
	if item_list_selectable_parts.is_anything_selected():
		add_clip_part(item_list_selectable_parts.get_selected_items()[0])

func _on_button_save_pressed() -> void:
	start_save_process()
