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
import Json.Decode as Json
import Json.Encode as Encode exposing (Value)
import Task


main : Program () Model Msg
main =
    Browser.element { init = \() -> initialModel, view = view, update = update, subscriptions = subscriptions }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- PORTS


port renderImage : String -> Cmd a



-- MODEL


type alias SelectedFiles =
    List File


type alias Model =
    { count : Int, serverResponse : String, selectedFiles : SelectedFiles, selectedFile : String }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { count = 0, serverResponse = "", selectedFiles = [], selectedFile = "" }, Cmd.none )



-- UPDATE


type Msg
    = SaveImage
    | GotText (Result Http.Error String)
    | SelectedFiles (List File)
    | SelectedFile String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SaveImage ->
            ( model
            , Http.post
                { url = "http://localhost:8081/api/v1/saveImage"
                , body = Http.jsonBody (Encode.object [ data model.selectedFile ])
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
            ( { model | selectedFile = file }, renderImage file )


extractFile : Maybe File -> Cmd Msg
extractFile maybeFile =
    case maybeFile of
        Just file ->
            Task.perform SelectedFile <| File.toUrl file

        Nothing ->
            Cmd.none


data : String -> ( String, Encode.Value )
data value =
    ( "data", Encode.string value )



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
                    , on "change" (Json.map SelectedFiles filesDecoder)
                    ]
                    []
            )
        , fetchRow model
        ]


imageColumn : Element Msg
imageColumn =
    column [ Background.color (rgb255 128 128 128) ]
        [ el [] (html <| canvas [ id "canvas", width 1920, height 1080 ] [])
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


filesDecoder : Json.Decoder (List File)
filesDecoder =
    Json.at [ "target", "files" ] (Json.list File.decoder)
