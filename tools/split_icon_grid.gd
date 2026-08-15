extends SceneTree

func _init():
    var args := OS.get_cmdline_args()
    var config_path := ""
    var i := 0
    while i < args.size():
        if args[i] == "--config" and i + 1 < args.size():
            config_path = args[i + 1]
            i += 2
        else:
            i += 1
    if config_path.is_empty():
        print("Usage: --config <jobs.json>")
        quit()
        return
    var file := FileAccess.open(config_path, FileAccess.READ)
    if file == null:
        print("Cannot open config: " + config_path + " error=" + str(FileAccess.get_open_error()))
        quit()
        return
    var text := file.get_as_text()
    file.close()
    var jobs = JSON.parse_string(text)
    if jobs == null or typeof(jobs) != TYPE_ARRAY:
        print("Invalid JSON array in " + config_path)
        quit()
        return
    for job in jobs:
        var source_path := str(job.get("source", ""))
        var rows := int(job.get("rows", 0))
        var cols := int(job.get("cols", 0))
        var out_dir := str(job.get("out_dir", ""))
        var names: Array = job.get("names", [])
        if source_path.is_empty() or rows <= 0 or cols <= 0 or out_dir.is_empty() or names.is_empty():
            print("Skipping bad job: " + str(job))
            continue
        DirAccess.make_dir_recursive_absolute(out_dir)
        var img := Image.load_from_file(source_path)
        if img == null:
            print("Failed to load image: " + source_path)
            continue
        var w := img.get_width() / cols
        var h := img.get_height() / rows
        var idx := 0
        for name_obj in names:
            var name := str(name_obj)
            if name.is_empty():
                idx += 1
                continue
            var cx := idx % cols
            var cy := idx / cols
            var region := img.get_region(Rect2i(cx * w, cy * h, w, h))
            var out_path := out_dir.path_join(name + ".png")
            var err := region.save_png(out_path)
            if err == OK:
                print("Saved " + out_path)
            else:
                print("Error saving " + out_path + " err=" + str(err))
            idx += 1
    quit()
