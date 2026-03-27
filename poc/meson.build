project('ilia-plugin-poc', 'vala', 'c', version: '0.1')

glib_dep = dependency('glib-2.0')
gobject_dep = dependency('gobject-2.0')
gmodule_dep = dependency('gmodule-2.0')
gio_dep = dependency('gio-2.0')

#Shared library: types registered ONCE
sdk = shared_library('ilia-sdk', 'sdk.vala',
    dependencies: [glib_dep, gobject_dep, gio_dep],
    vala_header: 'ilia-sdk.h',
    vala_vapi: 'ilia-sdk.vapi',
    install: false,
)

sdk_dep = declare_dependency(
    link_with: sdk,
    include_directories: include_directories('.'),
)

#Host binary: discovers + loads plugins 
executable('host', 'host.vala',
    dependencies: [glib_dep, gobject_dep, gmodule_dep, gio_dep, sdk_dep],
    install: false,
)

#Dummy plugin: separate .so 
shared_library('greeting-plugin', 'plugin.vala',
    dependencies: [glib_dep, gobject_dep, gmodule_dep, sdk_dep],
    name_prefix: '',  # output: greeting-plugin.so (no 'lib' prefix)
    install: false,
)
