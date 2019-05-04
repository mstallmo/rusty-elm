port module Main exposing (main)

import Browser
import Element exposing (Element, centerY, column, el, html, padding, paddingXY, rgb255, row, spacing, text)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import File exposing (File)
import Html exposing (Html, canvas, input)
import Html.Attributes exposing (height, id, multiple, name, type_, width)
import Html.Events exposing (on)
import Http
import Json.Decode exposing (Decoder, field, int, map, map3, map4, string)
import Json.Encode as Encode exposing (Value)
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



-- MODEL


type alias SelectedFiles =
    List File


type alias Layer =
    { name : String, width : Int, height : Int, image : List Int }


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
                        (Encode.object
                            [ image "placeholder string for document"
                            , title "Ferris.psd"
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

        ActiveDocument file ->
            ( { model | activeDocument = file }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


extractFile : Maybe File -> Cmd Msg
extractFile maybeFile =
    case maybeFile of
        Just file ->
            Task.perform SelectedFile <| File.toUrl file

        Nothing ->
            Cmd.none


title : String -> ( String, Encode.Value )
title value =
    ( "title", Encode.string value )


image : String -> ( String, Encode.Value )
image value =
    ( "image", Encode.string value )


filesDecoder : Decoder (List File)
filesDecoder =
    Json.Decode.at [ "target", "files" ] (Json.Decode.list File.decoder)


nameDecoder : Decoder String
nameDecoder =
    field "name" string


widthDecoder : Decoder Int
widthDecoder =
    field "width" int


heightDecoder : Decoder Int
heightDecoder =
    field "height" int


imageDecoder : Decoder (List Int)
imageDecoder =
    field "image" (Json.Decode.list int)


layerDecoder : Decoder Layer
layerDecoder =
    map4 Layer nameDecoder widthDecoder heightDecoder imageDecoder


documentDecoder : Decoder Document
documentDecoder =
    map3 Document widthDecoder heightDecoder (Json.Decode.list layerDecoder)


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
            , row [] [ imageColumn ]
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
        , fetchRow model
        ]


imageColumn : Element Msg
imageColumn =
    column [ Background.color (rgb255 128 128 128) ]
        [ el [] (html <| canvas [ id "canvas", width 1920, height 1080 ] [])
        , el [] (html <| canvas [ id "canvas2", width 1920, height 1080 ] [])
        ]


fetchRow : Model -> Element Msg
fetchRow model =
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
