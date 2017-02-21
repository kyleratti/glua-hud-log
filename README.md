# glua-hud-log
Log messages at the top of the screen like in Star Wars: Jedi Knight Jedi Academy

![Preview](https://i.imgur.com/6UCOulK.jpg)

## Client ConVars
`hudlog_max_messages <0-8>` The maximum number of messages shown on the screen at once

`hudlog_msg_timeout <0-15>` The number of seconds each message will live

## Usage

```lua
hudlog.add(color, text, color, text, ...)
````
