module Frame exposing (Frame, Bodies, Body, Point, frameDecoder)


import Json.Decode exposing (field, int, list, map, map2, map4, string)


type alias Frame =
    { bodies : Bodies
    }

type alias Bodies = List Body

type alias Body =
    { position : Point
    , color : String
    , kind : String
    , rotation: Int
    }

type alias Point =
    { x : Int
    , y : Int
    }


pointDecoder = map2 Point (field "x" int) (field "y" int)

bodyDecoder = map4 Body (field "position" pointDecoder) (field "color" string) (field "kind" string) (field "rotation" int)

bodiesDecoder = list bodyDecoder

frameDecoder = map Frame (field "bodies" bodiesDecoder)
