//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <keyboard_invoker/keyboard_invoker_plugin_c_api.h>
#include <keypress_simulator/keypress_simulator_plugin.h>
#include <screen_retriever/screen_retriever_plugin.h>
#include <system_tray/system_tray_plugin.h>
#include <window_manager/window_manager_plugin.h>

void RegisterPlugins(flutter::PluginRegistry* registry) {
  KeyboardInvokerPluginCApiRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("KeyboardInvokerPluginCApi"));
  KeypressSimulatorPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("KeypressSimulatorPlugin"));
  ScreenRetrieverPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("ScreenRetrieverPlugin"));
  SystemTrayPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("SystemTrayPlugin"));
  WindowManagerPluginRegisterWithRegistrar(
      registry->GetRegistrarForPlugin("WindowManagerPlugin"));
}
