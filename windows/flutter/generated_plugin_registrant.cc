//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <fast_rsa/fast_rsa_plugin.h>
#include <flutter_udid/flutter_udid_plugin_c_api.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  FastRsaPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FastRsaPlugin"));
  FlutterUdidPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("FlutterUdidPluginCApi"));
}
