app "basic"
    packages {
        w4: "../platform/main.roc",
    }
    imports [
        w4.Task.{ Task },
        w4.W4,
    ]
    provides [main, Model] to w4

Program : {
    init : Task Model [],
    update : Model -> Task Model [],
}

Model : {}

main : Program
main = { init, update }

init : Task Model []
init =

    {} <- setColorPalette |> Task.await
    {} <- setDrawColors |> Task.await

    palette <- W4.getPalette |> Task.await
    {} <- Inspect.toStr palette |> W4.trace |> Task.await

    Task.ok {}

update : Model -> Task Model []
update = \model ->

    # Read gamepad
    { button1, button2, left, right, up, down } <- W4.readGamepad Player1 |> Task.await

    # Draw the gamepad state
    {} <- W4.setTextColors { fg: red, bg: green } |> Task.await
    {} <- "X: \(Inspect.toStr button1)" |> W4.text { x: 0, y: 0 } |> Task.await

    {} <- W4.setTextColors { fg: blue, bg: white } |> Task.await
    {} <- "Z: \(Inspect.toStr button2)" |> W4.text { x: 0, y: 8 } |> Task.await
    {} <- "L: \(Inspect.toStr left)" |> W4.text { x: 0, y: 16 } |> Task.await
    {} <- "R: \(Inspect.toStr right)" |> W4.text { x: 0, y: 24 } |> Task.await
    {} <- "U: \(Inspect.toStr up)" |> W4.text { x: 0, y: 32 } |> Task.await
    {} <- "D: \(Inspect.toStr down)" |> W4.text { x: 0, y: 40 } |> Task.await

    {} <- W4.setTextColors { fg: None, bg: None } |> Task.await
    {} <- "THIS IS TRASPARENT" |> W4.text { x: 0, y: 48 } |> Task.await

    # Return the model for next frame
    Task.ok model

# Set the color pallet
white = Color1
red = Color2
green = Color3
blue = Color4

setColorPalette : Task {} []
setColorPalette =
    W4.setPalette {
        color1: 0xffffff,
        color2: 0xff0000,
        color3: 0x000ff00,
        color4: 0x0000ff,
    }

setDrawColors : Task {} []
setDrawColors =
    W4.setDrawColors {
        primary: white,
        secondary: red,
        tertiary: green,
        quaternary: blue,
    }
