#!/usr/bin/env python3
"""Convert user-submitted Blender/USDZ assets to mobile-friendly GLB for Godot 4.3."""
import sys
from pathlib import Path
import bpy

def parse_args():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    if len(args) != 2:
        raise SystemExit("Expected INPUT_DIR OUTPUT_DIR after --")
    return Path(args[0]).resolve(), Path(args[1]).resolve()

def reset_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

def optimise_meshes(max_faces):
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH" and o.visible_get()]
    total = sum(len(o.data.polygons) for o in meshes)
    if total > max_faces:
        ratio = max(0.08, min(1.0, float(max_faces) / float(total)))
        for obj in meshes:
            bpy.context.view_layer.objects.active = obj
            obj.select_set(True)
            modifier = obj.modifiers.new(name="DarkWorld_Mobile_Decimate", type="DECIMATE")
            modifier.ratio = ratio
            try:
                bpy.ops.object.modifier_apply(modifier=modifier.name)
            except Exception as exc:
                print("WARN decimate", obj.name, exc)
            obj.select_set(False)
    return sum(len(o.data.polygons) for o in meshes)

def export_scene(source, destination, max_faces):
    reset_scene()
    if source.suffix.lower() == ".blend":
        bpy.ops.wm.open_mainfile(filepath=str(source))
        maps = source.parent / "maps"
        if maps.is_dir():
            try:
                bpy.ops.file.find_missing_files(directory=str(maps))
            except Exception as exc:
                print("WARN texture relink:", exc)
    elif source.suffix.lower() == ".usdz":
        bpy.ops.wm.usd_import(filepath=str(source))
    else:
        return False
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH" and o.visible_get()]
    if not meshes:
        print("WARN no mesh in", source)
        return False
    bpy.ops.object.select_all(action="DESELECT")
    for obj in bpy.context.scene.objects:
        if obj.type in {"MESH", "EMPTY"} and obj.visible_get():
            obj.select_set(True)
    optimise_meshes(max_faces)
    destination.parent.mkdir(parents=True, exist_ok=True)
    bpy.ops.export_scene.gltf(filepath=str(destination), export_format="GLB",
        use_selection=True, export_apply=True, export_image_format="AUTO",
        export_materials="EXPORT", export_cameras=False, export_lights=False)
    print("EXPORTED", source.name, "->", destination, destination.stat().st_size)
    return destination.exists() and destination.stat().st_size > 1024

def main():
    input_dir, output_dir = parse_args()
    output_dir.mkdir(parents=True, exist_ok=True)
    sources = [p for p in input_dir.rglob("*") if p.is_file()
        and p.suffix.lower() in {".blend", ".usdz"}
        and not p.name.lower().endswith(".blend1")]
    converted = 0
    for source in sorted(sources):
        stem = source.stem.lower().replace(" ", "_").replace("-", "_")
        budget = 250000 if "castle" in stem or "hohenzollern" in stem else 120000
        try:
            if export_scene(source, output_dir / (stem + ".glb"), budget):
                converted += 1
        except Exception as exc:
            print("ERROR converting", source, repr(exc))
    print("CONVERSION_SUMMARY", converted, "of", len(sources))
    if converted == 0:
        raise SystemExit("No GLB assets were converted successfully.")

if __name__ == "__main__":
    main()
