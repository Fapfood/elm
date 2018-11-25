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
        args = (body.position.x, body.position.y, body.color, body.rotation)
    in
        List.map (flip prepare args) object.parts


predicate : Body -> Object -> Bool
predicate body object =
    body.kind == object.name


prepare : Part -> ( Int, Int, String, Int ) -> Svg msg
prepare part =
    case part.kind of
        "r" -> prepareR part
        "c" -> prepareC part
        "p" -> prepareP part
        "e" -> prepareE part
        _   -> (\(x_val, y_val, color, angle) -> rect [ x (toString x_val), y (toString y_val), width "10", height "10", fill color ] [])


prepareR : Part -> ( Int, Int, String, Int ) -> Svg msg
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
        (\(x_val, y_val, color, angle) -> rect [ x (x_fun x_val), y (y_fun y_val), width full_width, height full_height, fill color, transform (rotator angle x_val y_val) ] [])


prepareC : Part -> ( Int, Int, String, Int ) -> Svg msg
prepareC part =
    let
        (x_move, y_move, radius) = case part.value of
            [a, b, c] -> (a, b, c)
            _ -> (0, 0, 0)
        r_val = toString radius
        x_fun = \x_val -> toString (x_val + x_move)
        y_fun = \y_val -> toString (y_val + y_move)
    in
        (\(x_val, y_val, color, angle) -> circle [ cx (x_fun x_val), cy (y_fun y_val), r r_val, fill color, transform (rotator angle x_val y_val) ] [])


prepareE : Part -> ( Int, Int, String, Int ) -> Svg msg
prepareE part =
    let
        (x_move, y_move, x_radius, y_radius) = case part.value of
            [a, b, c, d] -> (a, b, c, d)
            _ -> (0, 0, 0, 0)
        r_x_val = toString x_radius
        r_y_val = toString y_radius
        x_fun = \x_val -> toString (x_val + x_move)
        y_fun = \y_val -> toString (y_val + y_move)
    in
        (\(x_val, y_val, color, angle) -> ellipse [ cx (x_fun x_val), cy (y_fun y_val), rx r_x_val, ry r_y_val, fill color, transform (rotator angle x_val y_val) ] [])


prepareP : Part -> ( Int, Int, String, Int ) -> Svg msg
prepareP part =
    let
        points_fun = \(x_val, y_val) ->
            let
                (str, _, _, _) = List.foldl foldler ("", 1, x_val, y_val) part.value
            in
                str
    in
        (\(x_val, y_val, color, angle) -> polyline [ fill color, stroke color, points (points_fun (x_val, y_val)), transform (rotator angle x_val y_val) ] [])


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

rotator: Int -> Int -> Int -> String
rotator rot x y =
    "rotate(" ++ toString rot ++ "," ++ toString x ++ "," ++ toString y ++ ")"