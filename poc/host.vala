/**
 * host.vala — Minimal host that discovers and loads a plugin
 *
 * Demonstrates the full lifecycle:
 *   1. Scan a directory for .so files (discovery — no dlopen yet)
 *   2. Load one plugin on demand (dlopen + symbol lookup)
 *   3. Verify the returned GType implements DialogPage
 *   4. Instantiate and call methods on it
 *
 * Usage: ./host <plugin-dir> [query]
 * Example: ./host . hello
 */

/** Plugin registration function signature */
[CCode (has_target = false)]
delegate Type PluginRegisterFunc (Module module);

int main (string[] args) {
    if (args.length < 2) {
        printerr ("Usage: %s <plugin-dir> [query]\n", args[0]);
        return 1;
    }

    string plugin_dir = args[1];
    string query = args.length > 2 ? args[2] : "";

    // Phase 1: Discovery (cheap — just list files, no dlopen)
    var timer = new Timer ();
    timer.start ();

    string[] found_plugins = {};
    try {
        var dir = Dir.open (plugin_dir);
        string? name;
        while ((name = dir.read_name ()) != null) {
            if (name.has_suffix (".so")) {
                found_plugins += Path.build_filename (plugin_dir, name);
            }
        }
    } catch (Error e) {
        printerr ("Cannot scan '%s': %s\n", plugin_dir, e.message);
        return 1;
    }

    double discover_ms = timer.elapsed () * 1000;
    print ("Discovery: found %d plugin(s) in %.2f ms\n\n",
           found_plugins.length, discover_ms);

    if (found_plugins.length == 0) {
        print ("No .so files in '%s'.\n", plugin_dir);
        return 0;
    }

    //Phase 2: Load one plugin on demand
    timer.start ();

    string so_path = found_plugins[0];
    var module = Module.open (so_path, ModuleFlags.BIND_LAZY);
    if (module == null) {
        printerr ("dlopen failed: %s\n", Module.error ());
        return 1;
    }
    print ("Loaded: %s\n", so_path);

    // Look up the registration function
    void* sym;
    if (!module.symbol ("register_ilia_plugin", out sym)) {
        printerr ("Symbol 'register_ilia_plugin' not found\n");
        return 1;
    }

        // Call it to get the plugin's GType
    unowned PluginRegisterFunc register_fn = (PluginRegisterFunc) sym;
    Type page_type = register_fn (module);

        // Instantiate once so the output can show plugin label next to type name
        var page = (Ilia.DialogPage) Object.new (page_type);

    double load_ms = timer.elapsed () * 1000;
        print ("Registered type: %s (%s) (GType=%lu) in %.2f ms\n\n",
            page_type.name (), page.get_name (), (ulong) page_type, load_ms);

    //Phase 3: Verify type safety
    if (!page_type.is_a (typeof (Ilia.DialogPage))) {
        printerr ("ERROR: %s does not implement DialogPage!\n", page_type.name ());
        return 1;
    }
    print ("Type check passed: %s implements DialogPage\n\n",
           page_type.name ());

    //Phase 4: Instantiate and use (query is optional)
    if (query.length > 0) {
        page.activate (query);
    }

    // Prove single GType — the host's DialogPage GType must match
    print ("GType Verification\n");
    print ("Host's  DialogPage GType: %lu\n", (ulong) typeof (Ilia.DialogPage));
    print ("Plugin's parent GType:    %lu\n", (ulong) page_type.parent ());
    print ("this is how it works (no segfault)\n");

    // Keep module resident (GTypes can't be unregistered)
    module.make_resident ();
    return 0;
}
