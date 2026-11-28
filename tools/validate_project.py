from pathlib import Path
import re, sys
ROOT = Path(__file__).resolve().parents[1]
required = ["project.godot", "scenes/main.tscn", "scenes/frontend.tscn", "scripts/frontend_ui.gd", "scripts/online_service.gd", "scripts/ui_illustration.gd", "scripts/world.gd", "scripts/player.gd", "scripts/enemy.gd", "scripts/painter_material.gdshader"]
missing = [x for x in required if not (ROOT / x).is_file()]
if missing:
    print("MISSING:", missing); sys.exit(1)
for rel in ["scripts/world.gd", "scripts/player.gd", "scripts/enemy.gd", "scripts/frontend_ui.gd", "scripts/online_service.gd", "scripts/ui_illustration.gd"]:
    text = (ROOT / rel).read_text(encoding="utf-8")
    if "\t " in text:
        print("WARN mixed tab-space:", rel)
    # Strip strings and comments, then check balanced delimiters.
    clean = re.sub(r'"(?:\\.|[^"\\])*"', '""', text)
    clean = "\n".join(line.split("#", 1)[0] for line in clean.splitlines())
    stack=[]; pairs={")":"(", "]":"[", "}":"{"}
    for n,ch in enumerate(clean):
        if ch in "([{": stack.append((ch,n))
        elif ch in ")]}":
            if not stack or stack[-1][0] != pairs[ch]:
                print("DELIMITER ERROR:", rel, n, ch); sys.exit(1)
            stack.pop()
    if stack:
        print("UNCLOSED DELIMITER:", rel, stack[-1]); sys.exit(1)
    if not re.search(r'^func _ready\(\)', text, re.M) and rel.endswith("world.gd"):
        print("MISSING READY:", rel); sys.exit(1)
print("Static project checks: PASS")
print("Note: this does not compile GDScript or run the Godot scene.")
