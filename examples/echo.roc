app "minimal"
    packages {
        w4: "../platform/main.roc",
    }
    imports [
        w4.Task.{ Task },
    ]
    provides [main, Model] to w4

Program : {
    init : Task Model [],
    update : Model -> Task Model [],
}

Model : Str

main : Program
main = { init, update }

init : Task Model []
init =

    {} <- setColorPallet |> Task.await
    {} <- setDrawColors |> Task.await

    Task.ok "Test123"

update : Model -> Task Model []
update = \model ->
    next = Str.concat model "1."

    # Read gamepad
    { button1, button2, left, right, up, down } <- Task.readGamepad Player1 |> Task.await

    # Draw the gamepad state
    {} <- Task.textColor { fg: red, bg: green } |> Task.await
    {} <- "X: \(Inspect.toStr button1)" |> Task.text { x: 0, y: 0 } |> Task.await

    {} <- Task.textColor { fg: blue, bg: white } |> Task.await
    {} <- "Z: \(Inspect.toStr button2)" |> Task.text { x: 0, y: 8 } |> Task.await
    {} <- "L: \(Inspect.toStr left)" |> Task.text { x: 0, y: 16 } |> Task.await
    {} <- "R: \(Inspect.toStr right)" |> Task.text { x: 0, y: 24 } |> Task.await
    {} <- "U: \(Inspect.toStr up)" |> Task.text { x: 0, y: 32 } |> Task.await
    {} <- "D: \(Inspect.toStr down)" |> Task.text { x: 0, y: 40 } |> Task.await

    {} <- Task.textColor { fg: None, bg: None } |> Task.await
    {} <- "THIS IS TRASPARENT" |> Task.text { x: 0, y: 48 } |> Task.await

    Task.ok next

# Set the color pallet
white = Color1
red = Color2
green = Color3
blue = Color4

setColorPallet : Task {} []
setColorPallet =
    Task.setPallet {
        color1: 0xffffff,
        color2: 0xff0000,
        color3: 0x000ff00,
        color4: 0x0000ff,
    }

setDrawColors : Task {} []
setDrawColors =
    Task.setDrawColors {
        primary: white,
        secondary: red,
        tertiary: green,
        quaternary: blue,
    }
