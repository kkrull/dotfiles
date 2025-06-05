# Visual Studio Code

## Gnome3 Interference

Some keybindings on Gnome 3 for workspace management clash with the settings I want to use here, and
they are not visible in the settings UI.

```sh
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-right "['<Super><Shift>Page_Down']"
gsettings set org.gnome.desktop.wm.keybindings move-to-workspace-left "['<Super><Shift>Page_Up']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-left "['<Super>Page_Up']"
gsettings set org.gnome.desktop.wm.keybindings switch-to-workspace-right "['<Super>Page_Down']"
```

## Keyboard shortcuts

See `~/.config/Code/User/keybindings.json`.  These don't always seem to get synchronized with
settings sync.

```json
[
  {
    "command": "-mermaid-editor.preview",
    "key": "ctrl+alt+[",
    "when": "resourceExtname == '.mermaid' || resourceExtname == '.mmd'"
  },
  {
    "command": "-workbench.action.toggleAuxiliaryBar",
    "key": "ctrl+alt+b"
  },
  {
    "command": "-workbench.action.toggleSidebarVisibility",
    "key": "ctrl+b"
  },
  {
    "command": "-mermaid-editor.generate.file",
    "key": "ctrl+alt+]",
    "when": "mermaidPreviewEnabled && resourceExtname == '.mermaid' || mermaidPreviewEnabled && resourceExtname == '.mmd'"
  },
  {
    "command": "workbench.action.toggleSidebarVisibility",
    "key": "ctrl+alt+["
  },
  {
    "command": "workbench.action.toggleAuxiliaryBar",
    "key": "ctrl+alt+]"
  },
  {
    "command": "workbench.action.navigateLeft",
    "key": "ctrl+shift+alt+left"
  },
  {
    "command": "workbench.action.navigateRight",
    "key": "ctrl+shift+alt+right"
  }
]
```
