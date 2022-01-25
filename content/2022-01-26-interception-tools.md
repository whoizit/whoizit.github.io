+++
title = "interception-tools и dual-function-keys"
date = 2022-01-26
+++

Когда вы начинаете с Linux, возможно вам повезёт и опытные товарищи вам подскажут, что раскладку клавиатуры лучше переключать одной клавишей. И возможно вы преодолев [синдром утёнка](https://lurkmore.to/%D0%A1%D0%B8%D0%BD%D0%B4%D1%80%D0%BE%D0%BC_%D1%83%D1%82%D1%91%D0%BD%D0%BA%D0%B0) захотите это сделать. Один из популярных вариантов это Caps_Lock. Нажимаем - меняем раскладку, нажимаем через Shift - включается Caps Lock.

*(Если вы до сих пор меняете раскладку двумя клавишами, то вы возможно что-то делаете не так.)*

Позже, когда вы овладели vim или emacs, вам может остро захотеться сделать так, чтобы `Ctrl` был на месте `Caps_Lock` или `Tab` или даже сменить клавиатуру на HHKB, Pok3r или что-то ещё. Но в Linux есть замечательная [interception-tools](https://gitlab.com/interception/linux/tools) с плагином [dual-function-keys](https://gitlab.com/interception/linux/plugins/dual-function-keys), которые позволяют не только сменить Caps на Ctrl, но и добавить действие при удержании клавиши.

Можно например перебиндить клавиши так (как у меня):
- `Caps_Lock` по короткому нажатию это `Esc`, а при удерживании это `L_Ctrl`
- `Tab` по короткому нажатию это `Tab`, а при удерживании это `L_Alt`
- `L_Alt` меняется на `L_Meta`
- `Caps_Lock` переносится на `R_Alt` (Caps Lock остаётся переключателем раскладки)
- `L_Shift` по короткому нажатию это `(`
- `R_Shift` по короткому нажатию это `)`

[Quick start](https://gitlab.com/interception/linux/plugins/dual-function-keys#quick-start)

В конфиге важно не ошибиться с названием клавиатуры (NAME). Посмотреть название клавиатуры можно так (ZSH):
```sh
~ > for x (/dev/input/by-id/*-kbd) sudo uinput -p -d $x | rg NAME                                                   ± master | 25 Jan 09:43:09 (2)
NAME: A4TECH USB Device Keyboard
NAME: SEM HCT Keyboard
```

**/etc/interception/udevmon.yaml:**
```yaml
- JOB: "intercept -g $DEVNODE | dual-function-keys -c /etc/interception/dual-function-keys/mappings.yaml | uinput -d $DEVNODE"
  DEVICE:
    NAME: "SEM HCT Keyboard"
    EVENTS:
      EV_KEY: [KEY_TAB, KEY_CAPSLOCK, KEY_LEFTSHIFT, KEY_LEFTCTRL, KEY_LEFTMETA, KEY_LEFTALT, KEY_RIGHTSHIFT, KEY_RIGHTALT]
```

**/etc/interception/dual-function-keys/mappings.yaml:**
```yaml
MAPPINGS:
  - KEY: KEY_CAPSLOCK
    TAP: KEY_ESC
    HOLD: KEY_LEFTCTRL

  - KEY: KEY_TAB
    TAP: KEY_TAB
    HOLD: KEY_LEFTALT

  - KEY: KEY_LEFTCTRL
    TAP: KEY_UNKNOWN
    HOLD: KEY_UNKNOWN

  - KEY: KEY_LEFTMETA
    TAP: KEY_RIGHTMETA
    HOLD: KEY_LEFTCTRL

  - KEY: KEY_LEFTALT
    TAP: KEY_LEFTMETA
    HOLD: KEY_LEFTMETA

  - KEY: KEY_RIGHTALT
    TAP: KEY_CAPSLOCK
    HOLD: KEY_LEFTCTRL

  - KEY: KEY_LEFTSHIFT
    TAP: [ KEY_LEFTSHIFT, KEY_9, ]
    HOLD: KEY_LEFTSHIFT

  - KEY: KEY_RIGHTSHIFT
    TAP: [ KEY_RIGHTSHIFT, KEY_0, ]
    HOLD: KEY_RIGHTSHIFT
```

`KEY_UNKNOWN` вырубает действие/клавишу

В mappings.yaml я делаю некоторые лишние действия которые я не описал, возможно они вам не понадобятся
