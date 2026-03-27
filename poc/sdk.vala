/**
 * sdk.vala — Shared interface (compiled into libilia-sdk.so)
 *
 * This is the FIX for the feat-module segfault:
 * Both host and plugin link against this ONE shared library,
 * so DialogPage gets a single GType ID. No duplicate registration.
 */
namespace Ilia {

    /** Contract that every page (built-in or plugin) must implement. */
    public interface DialogPage : GLib.Object {
        public abstract string get_name ();
        public abstract string get_icon ();
        public abstract void   activate (string query);
    }
}
