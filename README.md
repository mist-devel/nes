# NES
This is a port of Luddes NES core to the MIST. See his FPGANES blog at http://fpganes.blogspot.de for details. The original source code can be found at https://github.com/strigeus/fpganes.
Many changes ported from https://github.com/MiSTer-devel/NES_MiSTer.

## Zapper
It's possible to connect NES/Famicom Zapper (Lightgun) to MIST and use with this core.
Zapper is connected instead second joystick to DB9 port, and you should enable it within OSD menu.
Note that Light signal is sensitive and may (and will) cause accidental B-button presses in OSD, which is quite expected. To avoid this just cover light sensor with some dark piece.

### 15-pin Famicom zapper wiring:
```
               MIST DB9 port
        (male connector outside view)
              +-------------+
             1 \ x x x x x / 5
             6  \ x x x x /  9
                 +|-|-|-|+
                  | | | |
          Trigger | | | | Light
                  | | | |
      +-----------|-+ +-|---+
      |           |     |   |
      |           | +---+   |
  +5V |           | |       | GND
      |           +-|-+     |
      |             | |     |
      |    +--------|-|-----|--+
      |   8 \ o o o o o o o o / 1
      |  15  \ o o o o o o o /  9
      |       +|------------+
      |        |
      +--------+
               Zapper port
      (female connector outside view)
```

### 7-pin NES zapper wiring
```
               MIST DB9 port
        (male connector outside view)
              +-------------+
             1 \ x x x x x / 5
             6  \ x x x x /  9
                 +|-|-|-|+
                  | | | |
          Trigger | | | | Light
                  | | | +------+
                  | | |        |
         +--------|-+ +-+      |
         |        |     |      |
     +5V | +------+     | GND  |
         | |            |      |
         | |    +-------|--+   |
         | |  4 | o o o o / 1  |
         | |  7 | o o o  /  5  |
         | |    +-|-|-|-+      |
         | |      | | |        |
         | +------+ +-|--------+
         |            |
         +------------+
               Zapper port
      (female connector outside view)
```
