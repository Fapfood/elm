import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (viewBox, width, height, x, y, cx, cy, fill)
import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


-- MODEL

type alias Model =
    { frame : Frame
    , height : String
    , width : String
    }

type alias Frame =
    { bodies : List Body
    }

type alias Body =
    { position : Point
    , color : String
    }

type alias Point =
    { x : Float
    , y : Float
    }

pointDecoder = map2 Point (field "x" float) (field "y" float)

bodyDecoder = map2 Body (field "position" pointDecoder) (field "color" string)

frameDecoder = list bodyDecoder


init : ( Model, Cmd Msg )
init =
    ({ frame = { bodies = [] }
    , width = "1300"
    , height = "700"
    }, Cmd.none)


-- UPDATE

type Msg
  = Bodies String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Bodies bodies ->
       let
           frame = case decodeString frameDecoder bodies of
               Ok b -> Frame b
               Err msg -> Frame []
       in
          (Model frame model.height model.width, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:8765" Bodies


-- VIEW

view : Model -> Html Msg
view model =
    svg [ viewBox ("0 0 " ++ model.width ++ " " ++ model.height), width model.width ]
        (rect
            [ cx "0"
            , cy "0"
            , width model.width
            , height model.height
            , fill "#5"
            ]
            []
            :: (model.frame.bodies |> List.map drawBody)
        )


drawBody : Body -> Html Msg
drawBody body =
    let
        ( x_val, y_val ) =
            ( toString body.position.x
            , toString body.position.y
            )
    in
        rect [ x x_val, y y_val, width "10", height "10", fill body.color ] []