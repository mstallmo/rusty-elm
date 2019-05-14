port module Main exposing (main)

import Browser
import Element exposing (Element, alignTop, centerY, column, el, html, htmlAttribute, padding, paddingXY, rgb255, row, spacing, text)
import Element.Background as Background
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import File exposing (File)
import Html exposing (Html, canvas, input)
import Html.Attributes exposing (height, id, multiple, name, style, type_, width)
import Html.Events exposing (on)
import Http
import Json.Decode exposing (Decoder, bool, field, int, map, map3, map6, string)
import Json.Encode exposing (Value)
import List
import Task


main : Program Flags Model Msg
main =
    Browser.element { init = initialModel, view = view, update = update, subscriptions = subscriptions }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch [ documentUpdated mapActiveDocument, addNewLayer mapNewLayer ]



-- PORTS


port openFile : String -> Cmd a


port documentUpdated : (Json.Decode.Value -> msg) -> Sub msg


port renderLayers : List Json.Encode.Value -> Cmd a


port addNewLayer : (Json.Decode.Value -> msg) -> Sub msg



-- MODEL


type alias SelectedFiles =
    List File


type alias Layer =
    { name : String, width : Int, height : Int, image : List Int, layerIdx : Int, visible : Bool }


type alias Document =
    { width : Int, height : Int, layers : List Layer }


type alias Model =
    { apiUrl : String, count : Int, serverResponse : String, selectedFiles : SelectedFiles, selectedFile : String, activeDocument : Document }


type alias Flags =
    String


initialModel : Flags -> ( Model, Cmd Msg )
initialModel flags =
    ( { apiUrl = flags, count = 0, serverResponse = "", selectedFiles = [], selectedFile = "", activeDocument = { width = 0, height = 0, layers = [] } }, Cmd.none )



-- UPDATE


type Msg
    = NoOp
    | SaveImage
    | GotText (Result Http.Error String)
    | SelectedFiles (List File)
    | SelectedFile String
    | ActiveDocument Document
    | ToggleVisibility ( Int, Bool )
    | NewLayer Layer


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveImage ->
            ( model
            , Http.post
                { url = model.apiUrl ++ "/api/v1/saveImage"
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
            ( { model | selectedFile = file }, openFile file )

        ActiveDocument document ->
            ( { model | activeDocument = document }, encodeAndRenderLayers document.layers )

        ToggleVisibility ( index, visible ) ->
            let
                activeDocument =
                    model.activeDocument

                updatedLayers =
                    List.map
                        (\layer ->
                            if index == layer.layerIdx then
                                { layer | visible = visible }

                            else
                                layer
                        )
                        activeDocument.layers

                newActiveDocument =
                    { activeDocument | layers = updatedLayers }
            in
            ( { model | activeDocument = newActiveDocument }, encodeAndRenderLayers newActiveDocument.layers )

        NewLayer layer ->
            let
                activeDocument =
                    model.activeDocument

                updatedLayers =
                    activeDocument.layers ++ List.singleton layer

                newActiveDocument =
                    { activeDocument | layers = updatedLayers }
            in
            ( { model | activeDocument = newActiveDocument }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


extractFile : Maybe File -> Cmd Msg
extractFile maybeFile =
    case maybeFile of
        Just file ->
            Task.perform SelectedFile <| File.toUrl file

        Nothing ->
            Cmd.none



-- JSON Encoder/Decoder


encodeAndRenderLayers : List Layer -> Cmd Msg
encodeAndRenderLayers layers =
    List.map (\layer -> layerEncoder layer) layers |> renderLayers


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


visibilityEncoder : Bool -> ( String, Json.Encode.Value )
visibilityEncoder visible =
    ( "visible", Json.Encode.bool visible )


visibilityDecoder : Decoder Bool
visibilityDecoder =
    field "visible" bool


layerEncoder : Layer -> Json.Encode.Value
layerEncoder layer =
    Json.Encode.object
        [ nameEncoder layer.name
        , widthEncoder layer.width
        , heightEncoder layer.height
        , imageEncoder layer.image
        , layerIdxEncoder layer.layerIdx
        , visibilityEncoder layer.visible
        ]


layerDecoder : Decoder Layer
layerDecoder =
    map6 Layer nameDecoder widthDecoder heightDecoder imageDecoder layerIdxDecoder visibilityDecoder


documentDecoder : Decoder Document
documentDecoder =
    map3 Document widthDecoder heightDecoder (field "layers" (Json.Decode.list layerDecoder))


mapActiveDocument : Json.Decode.Value -> Msg
mapActiveDocument documentJson =
    case decodeDocument documentJson of
        Ok document ->
            ActiveDocument document

        Err _ ->
            NoOp


decodeDocument : Json.Decode.Value -> Result Json.Decode.Error Document
decodeDocument activeDocument =
    Json.Decode.decodeValue documentDecoder activeDocument


mapNewLayer : Json.Decode.Value -> Msg
mapNewLayer layerJson =
    case decodeLayer layerJson of
        Ok layer ->
            NewLayer layer

        Err _ ->
            NoOp


decodeLayer : Json.Decode.Value -> Result Json.Decode.Error Layer
decodeLayer newLayer =
    Json.Decode.decodeValue layerDecoder newLayer



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ spacing 20 ]
            [ elementRow model
            , row [ spacing 20, padding 20 ]
                [ toolbar
                , el
                    [ Background.color (rgb255 128 128 128)
                    , Element.width (Element.px 1280)
                    , Element.height (Element.px 720)
                    ]
                    (imageColumn model)
                , layerVisibilityColumn model
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


toolbar : Element Msg
toolbar =
    column [ spacing 20, alignTop ]
        [ Input.button [] { onPress = Nothing, label = text "First Tool" }
        , Input.button [] { onPress = Nothing, label = text "Second Tool" }
        ]


imageColumn : Model -> Element Msg
imageColumn model =
    column
        [ htmlAttribute <| style "position" "relative" ]
        (splitLayers model.activeDocument.layers)


splitLayers : List Layer -> List (Element Msg)
splitLayers layers =
    case layers of
        first :: rest ->
            List.append [ html <| canvas [ id first.name, width first.width, height first.height ] [] ] (mapCanvasLayers rest)

        _ ->
            mapCanvasLayers layers


mapCanvasLayers : List Layer -> List (Element Msg)
mapCanvasLayers layers =
    List.map
        (\element ->
            html <|
                canvas
                    [ id element.name
                    , width 1280
                    , height 720
                    , style "position" "absolute"
                    , style "z-index" (String.fromInt element.layerIdx)
                    , style "left" "0"
                    , style "top" "0"
                    ]
                    []
        )
        layers


layerVisibilityColumn : Model -> Element Msg
layerVisibilityColumn model =
    column [ spacing 20, alignTop ] (layerVisibilityToggle model.activeDocument.layers)


layerVisibilityToggle : List Layer -> List (Element Msg)
layerVisibilityToggle layers =
    List.map
        (\layer ->
            Input.checkbox []
                { onChange = \new -> ToggleVisibility ( layer.layerIdx, new )
                , checked = layer.visible
                , icon = Input.defaultCheckbox
                , label = Input.labelRight [] (text layer.name)
                }
        )
        layers


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
