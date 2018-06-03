module Main exposing (..)

import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (cx, cy, fill, height, points, r, stroke, viewBox, width, x, y)
import Html.Events exposing (..)
import WebSocket
import Json.Decode exposing (..)
import Frame exposing (..)
import Config exposing (..)
import Draw exposing (..)


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
    , config : Config
    , width : Int
    , height : Int
    }


init : ( Model, Cmd Msg )
init =
    (
        { frame = { bodies = [] }
        , config = []
        , width = 0
        , height = 0
        }
    , Cmd.none
    )


-- UPDATE

type Msg = Message String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Message message ->
       let
           m = case decodeString frameDecoder message of
               Ok frame -> Model frame model.config model.width model.height
               Err msg -> case decodeString configurationDecoder message of
                   Ok configuration -> Model model.frame configuration.config configuration.width configuration.height
                   Err msg -> model
       in
          (m, Cmd.none)


-- SUBSCRIPTIONS

subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://localhost:8765" Message


-- VIEW

view : Model -> Html Msg
view model =
    let
        w = toString model.width
        h = toString model.height
    in
    svg [ viewBox ("0 0 " ++ w ++ " " ++ h), width w ]
        (rect [ cx "0", cy "0", width w, height h, fill "#5" ] []
            :: List.foldr (++) [] (List.map (flip drawBody model.config) model.frame.bodies)
        )
