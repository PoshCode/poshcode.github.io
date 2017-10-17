import sublime, sublime_plugin, subprocess

# { "keys": ["f5"], "command": "run_script" }
class RunScriptCommand(sublime_plugin.TextCommand):
   def run(self, edit):
      # duplicate ISE behavior:          
      if self.view.file_name():
         if self.view.is_dirty():
            self.view.run_command("save")

         script = self.view.file_name()
      else:
         script = self.view.substr(sublime.Region(0, self.view.size()))

      subprocess.call(["C:\\Program Files\\DevTools\\ConEmu\\ConEmu\\ConEmuC64.exe", "-GUIMACRO:0", "PASTE", "2", script + "\n"])

# { "keys": ["f8"], "command": "run_selection" }
class RunSelectionCommand(sublime_plugin.TextCommand):
   def run(self, edit):
      for region in self.view.sel():
         if region.empty():
            ## If we wanted to duplicate ISE's bad behavior, we could:
            # view.run_command("expand_selection", args={"to":"line"})
            ## Instead, we'll just get the line contents without selected them:
            line_contents = self.view.substr(self.view.line(region)) + "\n"
         else:
            line_contents = self.view.substr(region) + "\n"

         subprocess.call(["C:\\Program Files\\DevTools\\ConEmu\\ConEmu\\ConEmuC64.exe", "-GUIMACRO:0", "PASTE", "2", line_contents])
      
