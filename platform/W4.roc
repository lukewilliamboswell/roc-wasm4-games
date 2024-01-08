interface W4
    exposes [
        Palette,
        Mouse,
        Gamepad,
        Netplay,
        Player,
        text,
        setPalette,
        getPalette,
        setDrawColors,
        getDrawColors,
        setPrimaryColor,
        setTextColors,
        setShapeColors,
        readGamepad,
        readMouse,
        readNetplay,
        rect,
        oval,
        line,
        hline,
        vline,
        screenWidth,
        screenHeight,
        rand,
        randRangeLessThan,
        trace,
        saveToDisk,
        loadFromDisk,
        perserveFrameBuffer,
        clearFrameBufferEachUpdate,
        hideGamepadOverlay,
        showGamepadOverlay,
    ]
    imports [Task.{ Task }, Effect.{ Effect }]

Palette : [None, Color1, Color2, Color3, Color4]

DrawColors : {
    primary : Palette,
    secondary : Palette,
    tertiary : Palette,
    quaternary : Palette,
}

Gamepad : {
    button1 : Bool,
    button2 : Bool,
    left : Bool,
    right : Bool,
    up : Bool,
    down : Bool,
}

Mouse : {
    x : I16,
    y : I16,
    left : Bool,
    right : Bool,
    middle : Bool,
}

Netplay : [
    Enabled Player,
    Disabled,
]

Player : [Player1, Player2, Player3, Player4]

screenWidth = 160
screenHeight = 160

setPalette : { color1 : U32, color2 : U32, color3 : U32, color4 : U32 } -> Task {} []
setPalette = \{ color1, color2, color3, color4 } ->
    Effect.setPalette color1 color2 color3 color4
    |> Effect.map Ok
    |> Task.fromEffect

getPalette : Task { color1 : U32, color2 : U32, color3 : U32, color4 : U32 } []
getPalette =
    Effect.getPalette
    |> Effect.map Ok
    |> Task.fromEffect

setDrawColors : DrawColors -> Task {} []
setDrawColors = \colors ->
    colors
    |> toColorFlags
    |> Effect.setDrawColors
    |> Effect.map Ok
    |> Task.fromEffect

getDrawColors : Task DrawColors []
getDrawColors =
    Effect.getDrawColors
    |> Effect.map fromColorFlags
    |> Effect.map Ok
    |> Task.fromEffect

## Draw text to the screen.
##
## ```
## W4.text "Hello, World" {x: 0, y: 0}
## ```
##
## Text color is the Primary draw color
## Background color is the Secondary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/guides/text)
text : Str, { x : I32, y : I32 } -> Task {} []
text = \str, { x, y } ->
    Effect.text str x y
    |> Effect.map Ok
    |> Task.fromEffect

## Helper for colors when drawing text
setTextColors : { fg : Palette, bg : Palette } -> Task {} []
setTextColors = \{ fg, bg } ->
    setDrawColors {
        primary: fg,
        secondary: bg,
        tertiary: None,
        quaternary: None,
    }

# TODO: maybe change the follow functions to either take a {x: I32, y: I32} or (I32, I32) just to cleary group points and width/height

## Draw a rectangle to the screen.
##
## ```
## W4.rect x y width height
## ```
##
## Fill color is the Primary draw color
## Border color is the Secondary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/reference/functions#rect-x-y-width-height)
rect : I32, I32, U32, U32 -> Task {} []
rect = \x, y, width, height ->
    Effect.rect x y width height
    |> Effect.map Ok
    |> Task.fromEffect

## Draw an oval to the screen.
##
## ```
## W4.oval x y width height
## ```
##
## Fill color is the Primary draw color
## Border color is the Secondary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/reference/functions#oval-x-y-width-height)
oval : I32, I32, U32, U32 -> Task {} []
oval = \x, y, width, height ->
    Effect.oval x y width height
    |> Effect.map Ok
    |> Task.fromEffect

## Draw an line between two points to the screen.
##
## ```
## W4.line x1 y1 x2 y2
## ```
##
## Line color is the Primary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/reference/functions#line-x1-y1-x2-y2)
line : I32, I32, I32, I32 -> Task {} []
line = \x1, y1, x2, y2 ->
    Effect.line x1 y1 x2 y2
    |> Effect.map Ok
    |> Task.fromEffect

## Draw a horizontal line starting at (x, y) with len to the screen.
##
## ```
## W4.hline x y len
## ```
##
## Line color is the Primary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/reference/functions#line-x1-y1-x2-y2)
hline : I32, I32, U32 -> Task {} []
hline = \x, y, len ->
    Effect.hline x y len
    |> Effect.map Ok
    |> Task.fromEffect

## Draw a vertical line starting at (x, y) with len to the screen.
##
## ```
## W4.vline x y len
## ```
##
## Line color is the Primary draw color
##
## [Refer w4 docs for more information](https://wasm4.org/docs/reference/functions#line-x1-y1-x2-y2)
vline : I32, I32, U32 -> Task {} []
vline = \x, y, len ->
    Effect.vline x y len
    |> Effect.map Ok
    |> Task.fromEffect

## Helper for colors when drawing a shape
setShapeColors : { border : W4.Palette, fill : W4.Palette } -> Task {} []
setShapeColors = \{ border, fill } ->
    setDrawColors {
        primary: fill,
        secondary: border,
        tertiary: None,
        quaternary: None,
    }

## Helper for primary drawing color
setPrimaryColor : W4.Palette -> Task {} []
setPrimaryColor = \primary ->
    setDrawColors {
        primary,
        secondary: None,
        tertiary: None,
        quaternary: None,
    }

## Read the controls for a Gamepad
readGamepad : Player -> Task Gamepad []
readGamepad = \player ->

    gamepadNumber =
        when player is
            Player1 -> 1
            Player2 -> 2
            Player3 -> 3
            Player4 -> 4

    Effect.readGamepad gamepadNumber
    |> Effect.map \flags ->
        Ok {
            # 1 BUTTON_1
            button1: Num.bitwiseAnd 0b0000_0001 flags > 0,
            # 2 BUTTON_2
            button2: Num.bitwiseAnd 0b0000_0010 flags > 0,
            # 16 BUTTON_LEFT
            left: Num.bitwiseAnd 0b0001_0000 flags > 0,
            # 32 BUTTON_RIGHT
            right: Num.bitwiseAnd 0b0010_0000 flags > 0,
            # 64 BUTTON_UP
            up: Num.bitwiseAnd 0b0100_0000 flags > 0,
            # 128 BUTTON_DOWN
            down: Num.bitwiseAnd 0b1000_0000 flags > 0,
        }
    |> Task.fromEffect

## Read the mouse input
readMouse : Task Mouse []
readMouse =
    Effect.readMouse
    |> Effect.map \{ x, y, buttons } ->
        Ok {
            x: x,
            y: y,
            # 1 MOUSE_LEFT
            left: Num.bitwiseAnd 0b0000_0001 buttons > 0,
            # 2 MOUSE_RIGHT
            right: Num.bitwiseAnd 0b0000_0010 buttons > 0,
            # 4 MOUSE_MIDDLE
            middle: Num.bitwiseAnd 0b0000_0100 buttons > 0,
        }
    |> Task.fromEffect

## Read the netplay status
readNetplay : Task Netplay []
readNetplay =
    Effect.readNetplay
    |> Effect.map \flags ->
        enabled = Num.bitwiseAnd 0b0000_0100 flags > 0
        if enabled then
            player =
                when Num.bitwiseAnd 0b0000_0011 flags is
                    0 -> Player1
                    1 -> Player2
                    2 -> Player3
                    3 -> Player4
                    _ -> crash "It is impossible for this value to be greater than 3"
            Ok (Enabled player)
        else
            Ok Disabled
    |> Task.fromEffect

## Generate a psuedo-random number
rand : Task I32 []
rand =
    Effect.rand
    |> Effect.map Ok
    |> Task.fromEffect

## Generate a psuedo-random number in specified range
## The range has an inclusive start and exclusive end
randRangeLessThan : I32, I32 -> Task I32 []
randRangeLessThan = \start, end ->
    Effect.randRangeLessThan start end
    |> Effect.map Ok
    |> Task.fromEffect

## Prints a message to the debug console.
##
## ```
## W4.trace "Hello, World"
## ```
##
## [Refer w4 docs for more information](https://wasm4.org/docs/guides/trace)
trace : Str -> Task {} []
trace = \str ->
    Effect.trace str
    |> Effect.map Ok
    |> Task.fromEffect

## Writes the passed in data to persistant storage.
## Any previously saved data on the disk is replaced.
## Returns `Err SaveFailed` on failure.
##
## ```
## W4.saveToDisk [0x10]
## ```
##
## Games can persist up to 1024 bytes of data.
## [Refer w4 docs for more information](https://wasm4.org/docs/guides/diskw)
saveToDisk : List U8 -> Task {} [SaveFailed]
saveToDisk = \data ->
    Effect.diskw data
    |> Effect.map \succeeded ->
        if succeeded then
            Ok {}
        else
            Err SaveFailed
    |> Task.fromEffect

## Reads all saved data from persistant storage.
##
## ```
## data <- W4.loadFromDisk |> Task.await
## ```
##
## Games can persist up to 1024 bytes of data.
## [Refer w4 docs for more information](https://wasm4.org/docs/guides/diskw)
loadFromDisk : Task (List U8) []
loadFromDisk =
    Effect.diskr
    |> Effect.map Ok
    |> Task.fromEffect

perserveFrameBuffer : Task {} []
perserveFrameBuffer =
    Effect.setPerserveFrameBuffer Bool.true
    |> Effect.map Ok
    |> Task.fromEffect

clearFrameBufferEachUpdate : Task {} []
clearFrameBufferEachUpdate =
    Effect.setPerserveFrameBuffer Bool.false
    |> Effect.map Ok
    |> Task.fromEffect

hideGamepadOverlay : Task {} []
hideGamepadOverlay =
    Effect.setHideGamepadOverlay Bool.true
    |> Effect.map Ok
    |> Task.fromEffect

showGamepadOverlay : Task {} []
showGamepadOverlay =
    Effect.setHideGamepadOverlay Bool.false
    |> Effect.map Ok
    |> Task.fromEffect

# HELPERS ------

toColorFlags : DrawColors -> U16
toColorFlags = \{ primary, secondary, tertiary, quaternary } ->

    pos1 =
        when primary is
            None -> 0x0
            Color1 -> 0x1
            Color2 -> 0x2
            Color3 -> 0x3
            Color4 -> 0x4

    pos2 =
        when secondary is
            None -> 0x00
            Color1 -> 0x10
            Color2 -> 0x20
            Color3 -> 0x30
            Color4 -> 0x40

    pos3 =
        when tertiary is
            None -> 0x000
            Color1 -> 0x100
            Color2 -> 0x200
            Color3 -> 0x300
            Color4 -> 0x400

    pos4 =
        when quaternary is
            None -> 0x0000
            Color1 -> 0x1000
            Color2 -> 0x2000
            Color3 -> 0x3000
            Color4 -> 0x4000

    0
    |> Num.bitwiseOr pos1
    |> Num.bitwiseOr pos2
    |> Num.bitwiseOr pos3
    |> Num.bitwiseOr pos4

expect toColorFlags { primary: Color2, secondary: Color4, tertiary: None, quaternary: None } == 0x0042
expect toColorFlags { primary: Color1, secondary: Color2, tertiary: Color3, quaternary: Color4 } == 0x4321

fromColorFlags : U16 -> DrawColors
fromColorFlags = \flags ->
    pos1 = Num.bitwiseAnd 0x000F flags
    pos2 = Num.bitwiseAnd 0x00F0 flags |> Num.shiftRightZfBy 4
    pos3 = Num.bitwiseAnd 0x0F00 flags |> Num.shiftRightZfBy 8
    pos4 = Num.bitwiseAnd 0xF000 flags |> Num.shiftRightZfBy 12

    extractColor = \pos ->
        when pos is
            0x0 -> None
            0x1 -> Color1
            0x2 -> Color2
            0x3 -> Color3
            0x4 -> Color4
            _ -> crash "got invalid draw color from the host"

    primary = extractColor pos1
    secondary = extractColor pos2
    tertiary = extractColor pos3
    quaternary = extractColor pos4

    { primary, secondary, tertiary, quaternary }

expect
    res = fromColorFlags 0x0042
    res == { primary: Color2, secondary: Color4, tertiary: None, quaternary: None }
expect fromColorFlags 0x4321 == { primary: Color1, secondary: Color2, tertiary: Color3, quaternary: Color4 }

