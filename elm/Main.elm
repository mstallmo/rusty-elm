port module Main exposing (main)

import Browser
import Element exposing (Element, alignTop, centerY, column, el, html, htmlAttribute, padding, paddingXY, rgb255, row, spacing, text)
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import File exposing (File)
import Html exposing (Html, canvas, input)
import Html.Attributes exposing (height, id, multiple, name, style, type_, width)
import Html.Events exposing (on)
import Http
import Json.Decode exposing (Decoder, field, int, map, map3, map5, string)
import Json.Encode exposing (Value)
import List
import Task


main : Program () Model Msg
main =
    Browser.element { init = \() -> initialModel, view = view, update = update, subscriptions = subscriptions }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    documentUpdated mapActiveDocument



-- PORTS


port openPSDDocument : String -> Cmd a


port documentUpdated : (Json.Decode.Value -> msg) -> Sub msg


port renderLayers : List Json.Encode.Value -> Cmd a



-- MODEL


type alias SelectedFiles =
    List File


type alias Layer =
    { name : String, width : Int, height : Int, image : List Int, layerIdx : Int }


type alias Document =
    { width : Int, height : Int, layers : List Layer }


type alias Model =
    { count : Int, serverResponse : String, selectedFiles : SelectedFiles, selectedFile : String, activeDocument : Document }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { count = 0, serverResponse = "", selectedFiles = [], selectedFile = "", activeDocument = { width = 0, height = 0, layers = [] } }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | SaveImage
    | GotText (Result Http.Error String)
    | SelectedFiles (List File)
    | SelectedFile String
    | ActiveDocument Document


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveImage ->
            ( model
            , Http.post
                { url = "http://localhost:8081/api/v1/saveImage"
                , body =
                    Http.jsonBody
                        (Json.Encode.object
                            [ encodeImage "placeholder string for document"
                            , encodeTitle "Ferris.psd"
                            ]
                        )
                , expect = Http.expectString GotText
                }
            )

        GotText result ->
            case result of
                Ok fullText ->
                    ( { model | serverResponse = fullText }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        SelectedFiles files ->
            ( { model | selectedFiles = files }, List.head files |> extractFile )

        SelectedFile file ->
            ( { model | selectedFile = file }, openPSDDocument file )

        ActiveDocument document ->
            ( { model | activeDocument = document }, renderLayers <| List.map (\layer -> layerEncoder layer) document.layers )

        NoOp ->
            ( model, Cmd.none )


extractFile : Maybe File -> Cmd Msg
extractFile maybeFile =
    case maybeFile of
        Just file ->
            Task.perform SelectedFile <| File.toUrl file

        Nothing ->
            Cmd.none


encodeTitle : String -> ( String, Json.Encode.Value )
encodeTitle value =
    ( "title", Json.Encode.string value )


encodeImage : String -> ( String, Json.Encode.Value )
encodeImage value =
    ( "image", Json.Encode.string value )


filesDecoder : Decoder (List File)
filesDecoder =
    Json.Decode.at [ "target", "files" ] (Json.Decode.list File.decoder)


nameEncoder : String -> ( String, Json.Encode.Value )
nameEncoder name =
    ( "name", Json.Encode.string name )


nameDecoder : Decoder String
nameDecoder =
    field "name" string


widthEncoder : Int -> ( String, Json.Encode.Value )
widthEncoder width =
    ( "width", Json.Encode.int width )


widthDecoder : Decoder Int
widthDecoder =
    field "width" int


heightEncoder : Int -> ( String, Json.Encode.Value )
heightEncoder height =
    ( "height", Json.Encode.int height )


heightDecoder : Decoder Int
heightDecoder =
    field "height" int


imageEncoder : List Int -> ( String, Json.Encode.Value )
imageEncoder image =
    ( "image", Json.Encode.list Json.Encode.int image )


imageDecoder : Decoder (List Int)
imageDecoder =
    field "image" (Json.Decode.list int)


layerIdxEncoder : Int -> ( String, Json.Encode.Value )
layerIdxEncoder layerIdx =
    ( "layerIdx", Json.Encode.int layerIdx )


layerIdxDecoder : Decoder Int
layerIdxDecoder =
    field "layerIdx" int


layerEncoder : Layer -> Json.Encode.Value
layerEncoder layer =
    Json.Encode.object
        [ nameEncoder layer.name
        , widthEncoder layer.width
        , heightEncoder layer.height
        , imageEncoder layer.image
        , layerIdxEncoder layer.layerIdx
        ]


layerDecoder : Decoder Layer
layerDecoder =
    map5 Layer nameDecoder widthDecoder heightDecoder imageDecoder layerIdxDecoder


documentDecoder : Decoder Document
documentDecoder =
    map3 Document widthDecoder heightDecoder (field "layers" (Json.Decode.list layerDecoder))


mapActiveDocument : Json.Decode.Value -> Msg
mapActiveDocument documentJson =
    case decodeDocument documentJson of
        Ok document ->
            ActiveDocument document

        Err errorMessage ->
            let
                _ =
                    Debug.log "Error in mapActiveDocument:" errorMessage
            in
            NoOp


decodeDocument : Json.Decode.Value -> Result Json.Decode.Error Document
decodeDocument activeDocument =
    Json.Decode.decodeValue documentDecoder activeDocument



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ spacing 20 ]
            [ elementRow model
            , row [ padding 20, spacing 20 ]
                [ sidebar
                , imageColumn model
                ]
            ]


elementRow : Model -> Element Msg
elementRow model =
    row [ spacing 20 ]
        [ el []
            (html <|
                input
                    [ type_ "file"
                    , name "image"
                    , multiple False
                    , id "ImageInput"
                    , on "change" (map SelectedFiles filesDecoder)
                    ]
                    []
            )
        , saveElement model
        , el [] (text <| "Width: " ++ String.fromInt model.activeDocument.width ++ " Height: " ++ String.fromInt model.activeDocument.height)
        ]


imageColumn : Model -> Element Msg
imageColumn model =
    column [ spacing 20, htmlAttribute <| style "position" "relative" ]
        (mapCanvasLayers model.activeDocument.layers)


mapCanvasLayers : List Layer -> List (Element Msg)
mapCanvasLayers layers =
    List.map
        (\element ->
            html <|
                canvas
                    [ id element.name
                    , width 500
                    , height 500
                    , style "position" "absolute"
                    , style "z-index" (String.fromInt element.layerIdx)
                    , style "left" "0"
                    , style "top" "0"
                    ]
                    []
        )
        layers


sidebar : Element Msg
sidebar =
    column [ spacing 20, alignTop ]
        [ Input.button [] { onPress = Nothing, label = text "toggle" }
        , Input.button [] { onPress = Nothing, label = text "other toggle" }
        ]


saveElement : Model -> Element Msg
saveElement model =
    row [ spacing 30, paddingXY 0 20 ]
        [ fetchFromServerButton, fetchResultLabel model ]


fetchResultLabel : Model -> Element msg
fetchResultLabel model =
    el [ Region.heading 2 ]
        (text model.serverResponse)


fetchFromServerButton : Element Msg
fetchFromServerButton =
    Input.button
        [ Border.color (rgb255 0 0 0)
        , Border.solid
        , Border.width 2
        , Border.rounded 10
        , padding 5
        , centerY
        ]
        { onPress = Just SaveImage, label = text "Save" }
