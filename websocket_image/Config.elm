module Config exposing (Configuration, Config, Object, Part, configurationDecoder)


import Json.Decode exposing (field, int, list, map2, map3, string)


type alias Configuration =
    { config : Config
    , width: Int
    , height : Int
    }

type alias Config = List Object

type alias Object =
    { name : String
    , parts : List Part
    }

type alias Part =
    { kind : String
    , value : List Int
    }


partDecoder = map2 Part (field "kind" string) (field "value" (list int))

objectDecoder = map2 Object (field "name" string) (field "parts" (list partDecoder))

configDecoder = list objectDecoder

configurationDecoder = map3 Configuration (field "config" configDecoder) (field "width" int) (field "height" int)
