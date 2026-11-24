#!/usr/bin/env python3
"""Convert user-submitted 3D assets to mobile-conscious GLB for Godot 4.3."""
import hashlib
import json
import sys
from pathlib import Path
import bpy

SUPPORTED = {".blend", ".usdz", ".fbx", ".obj"}

def parse_args():
    args = sys.argv[sys.argv.index("--") + 1:] if "--" in sys.argv else []
    if len(args) != 2:
        raise SystemExit("Expected INPUT_DIR OUTPUT_DIR after --")
    return Path(args[0]).resolve(), Path(args[1]).resolve()

def clear_scene():
    bpy.ops.object.select_all(action="SELECT")
    bpy.ops.object.delete(use_global=False)

def import_asset(source):
    ext = source.suffix.lower()
    if ext == ".blend":
        bpy.ops.wm.open_mainfile(filepath=str(source))
        for folder in (source.parent / "maps", source.parent / "textures", source.parent):
            if folder.is_dir():
                try:
                    bpy.ops.file.find_missing_files(directory=str(folder))
                except Exception as exc:
                    print("WARN relink", folder, repr(exc))
    elif ext == ".usdz":
        bpy.ops.wm.usd_import(filepath=str(source))
    elif ext == ".fbx":
        bpy.ops.import_scene.fbx(filepath=str(source), automatic_bone_orientation=True)
    elif ext == ".obj":
        if hasattr(bpy.ops.wm, "obj_import"):
            bpy.ops.wm.obj_import(filepath=str(source))
        else:
            bpy.ops.import_scene.obj(filepath=str(source))
    else:
        return False
    return True

def optimise_meshes(max_faces=140000):
    meshes = [o for o in bpy.context.scene.objects if o.type == "MESH" and o.visible_get()]
    total = sum(len(o.data.polygons) for o in meshes)
    if total > max_faces:
        ratio = max(0.06, min(1.0, max_faces / float(total)))
        for obj in meshes:
            bpy.context.view_layer.objects.active = obj
            obj.select_set(True)
            modifier = obj.modifiers.new(name="DarkWorld_Mobile_Decimate", type="DECIMATE")
            modifier.ratio = ratio
            try:
                bpy.ops.object.modifier_apply(modifier=modifier.name)
            except Exception as exc:
                print("WARN decimate", obj.name, repr(exc))
            obj.select_set(False)
    return sum(len(o.data.polygons) for o in meshes)

def safe_stem(source):
    base = "".join(c.lower() if c.isalnum() else "_" for c in source.stem).strip("_")[:48]
    digest = hashlib.sha1(str(source).encode()).hexdigest()[:8]
    return f"{base or 'model'}_{digest}"

def main():
    input_dir, output_dir = parse_args()
    output_dir.mkdir(parents=True, exist_ok=True)
    sources = sorted(p for p in input_dir.rglob("*") if p.is_file()
                     and p.suffix.lower() in SUPPORTED
                     and not p.name.lower().endswith(".blend1"))
    manifest = []
    for source in sources:
        try:
            clear_scene()
            import_asset(source)
            meshes = [o for o in bpy.context.scene.objects if o.type == "MESH" and o.visible_get()]
            if not meshes:
                print("SKIP no mesh", source)
                continue
            bpy.ops.object.select_all(action="DESELECT")
            for obj in bpy.context.scene.objects:
                if obj.type in {"MESH", "EMPTY"} and obj.visible_get():
                    obj.select_set(True)
            faces = optimise_meshes()
            destination = output_dir / (safe_stem(source) + ".glb")
            bpy.ops.export_scene.gltf(filepath=str(destination), export_format="GLB",
                use_selection=True, export_apply=True, export_image_format="AUTO",
                export_materials="EXPORT", export_cameras=False, export_lights=False)
            if destination.exists() and destination.stat().st_size > 1024:
                entry = {"source": source.name, "output": destination.name,
                         "bytes": destination.stat().st_size, "faces_after_optimise": faces}
                manifest.append(entry)
                print("EXPORTED", json.dumps(entry))
            else:
                print("SKIP invalid export", source)
        except Exception as exc:
            print("ERROR converting", source, repr(exc))
    (output_dir / "ASSET-MANIFEST.json").write_text(json.dumps(manifest, indent=2))
    print("CONVERSION_SUMMARY", len(manifest), "of", len(sources))
    if not manifest:
        raise SystemExit("No 3D models converted successfully.")

if __name__ == "__main__":
    main()
