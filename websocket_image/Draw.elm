module Draw exposing (drawBody)


import Config exposing (..)
import Frame exposing (..)
import Html exposing (..)
import Svg exposing (..)
import Svg.Attributes exposing (..)


drawBody : Body -> Config -> List (Svg msg)
drawBody body config =
    let
        object = case List.head (List.filter (predicate body) config) of
            Nothing -> Object "" []
            Just val -> val
        args = (body.position.x, body.position.y, body.color)
    in
        List.map (flip prepare args) object.parts


predicate : Body -> Object -> Bool
predicate body object =
    body.kind == object.name


prepare : Part -> ( Int, Int, String ) -> Svg msg
prepare part =
    case part.kind of
        "r" -> prepareR part
        "c" -> prepareC part
        "p" -> prepareP part
        _   -> (\(x_val, y_val, color) -> rect [ x (toString x_val), y (toString y_val), width "10", height "10", fill color ] [])


prepareR : Part -> ( Int, Int, String ) -> Svg msg
prepareR part =
    let
        (x_move, y_move, half_width, half_height) = case part.value of
            [a, b, c, d] -> (a, b, c, d)
            _ -> (0, 0, 0, 0)
        full_width = toString (half_width * 2)
        full_height = toString (half_height * 2)
        x_fun = \x_val -> toString (x_val + x_move - half_width)
        y_fun = \y_val -> toString (y_val + y_move - half_height)
    in
        (\(x_val, y_val, color) -> rect [ x (x_fun x_val), y (y_fun y_val), width full_width, height full_height, fill color ] [])


prepareC : Part -> ( Int, Int, String ) -> Svg msg
prepareC part =
    let
        (x_move, y_move, radius) = case part.value of
            [a, b, c] -> (a, b, c)
            _ -> (0, 0, 0)
        r_val = toString radius
        x_fun = \x_val -> toString (x_val + x_move)
        y_fun = \y_val -> toString (y_val + y_move)
    in
        (\(x_val, y_val, color) -> circle [ cx (x_fun x_val), cy (y_fun y_val), r r_val, fill color ] [])


prepareP : Part -> ( Int, Int, String ) -> Svg msg
prepareP part =
    let
        points_fun = \(x_val, y_val) ->
            let
                (str, _, _, _) = List.foldl foldler ("", 1, x_val, y_val) part.value
            in
                str
    in
        (\(x_val, y_val, color) -> polyline [ fill color, stroke color, points (points_fun (x_val, y_val)) ] [])


foldler : Int -> (String, Int, Int, Int) -> (String, Int, Int, Int)
foldler val acc =
    let
        (str, i, x_val, y_val) = acc
        part = case i % 2 of
            0 -> toString (y_val + val) ++ " "
            1 -> toString (x_val + val) ++ ","
            _ -> ""
    in
        (str ++ part, i + 1, x_val, y_val)
