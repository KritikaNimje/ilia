/**
 * plugin.vala — A dummy plugin (compiled into greeting-plugin.so)
 *
 * Implements DialogPage from the shared SDK.
 * Exports one function: register_ilia_plugin().
 */

/** Entry point — host calls this after dlopen */
public Type register_ilia_plugin (Module module) {
    return typeof (GreetingPage);
}

/** A trivial DialogPage implementation */
public class GreetingPage : Ilia.DialogPage, GLib.Object {

    public string get_name () { return "hello world"; }
    public string get_icon () { return "face-smile"; }

    public void activate (string query) {
        string[] greetings = { "Hello!", "Namaste!", "Bonjour!", "Hola!", "Ciao!" };
        print ("  Results for '%s':\n", query);
        foreach (var g in greetings) {
            if (query.length == 0 || g.down ().contains (query.down ()))
                print ("    → %s\n", g);
        }
    }
}
