port module Main exposing (main)

import Browser
import Element exposing (Element, centerX, centerY, column, el, html, padding, paddingXY, rgb255, row, spacing, text)
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import File exposing (File)
import Html exposing (Html, canvas, input)
import Html.Attributes exposing (height, id, multiple, name, type_, width)
import Html.Events exposing (on)
import Http
import Json.Decode as Json
import Task


main : Program () Model Msg
main =
    Browser.element { init = \() -> initialModel, view = view, update = update, subscriptions = subscriptions }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- PORTS


port hello : () -> Cmd a


port renderImage : String -> Cmd a



-- MODEL


type alias SelectedFile =
    List File


type alias Model =
    { count : Int, serverResponse : String, selectedFile : SelectedFile }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { count = 0, serverResponse = "", selectedFile = [] }, Cmd.none )



-- UPDATE


type Msg
    = Increment
    | Decrement
    | SayHello
    | FetchSomething
    | GotText (Result Http.Error String)
    | SelectedFile (List File)
    | GotFile String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )

        SayHello ->
            ( model, hello () )

        FetchSomething ->
            ( model, Http.get { url = "http://localhost:8081/api/v1/hello", expect = Http.expectString GotText } )

        GotText result ->
            case result of
                Ok fullText ->
                    ( { model | serverResponse = fullText }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )

        SelectedFile files ->
            ( { model | selectedFile = files }, List.head files |> extractFile )

        GotFile file ->
            ( model, renderImage file )


extractFile : Maybe File -> Cmd Msg
extractFile maybeFile =
    case maybeFile of
        Just file ->
            Task.perform GotFile <| File.toUrl file

        Nothing ->
            Cmd.none



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        column [ spacing 100 ]
            [ elementRow model
            , row [] [ imageColumn ]
            ]


elementRow : Model -> Element Msg
elementRow model =
    row [ spacing 40, centerX, paddingXY 0 40 ]
        [ counterColumn model
        , fetchColumn model
        , Input.button [] { onPress = Just SayHello, label = text "Say Hello" }
        ]


imageColumn : Element Msg
imageColumn =
    column []
        [ el [] (html <| canvas [ id "canvas", width 995, height 585 ] [])
        , el [] (html <| input [ type_ "file", name "image", multiple False, id "ImageInput", on "change" (Json.map SelectedFile filesDecoder) ] [])
        ]


counterColumn : Model -> Element Msg
counterColumn model =
    column [ spacing 30, centerY ]
        [ incrementButton
        , el [ centerX ] (text <| String.fromInt model.count)
        , decrementButton
        ]


incrementButton : Element Msg
incrementButton =
    Input.button
        [ Border.color (rgb255 0 0 0)
        , Border.solid
        , Border.rounded 40
        , Border.width 1
        , padding 10
        , centerX
        ]
        { onPress = Just Increment, label = text "+" }


decrementButton : Element Msg
decrementButton =
    Input.button
        [ Border.color (rgb255 0 0 0)
        , Border.solid
        , Border.rounded 40
        , Border.width 1
        , padding 10
        , centerX
        ]
        { onPress = Just Decrement, label = text "-" }


fetchColumn : Model -> Element Msg
fetchColumn model =
    column [ spacing 30, centerY ]
        [ fetchResultLabel model, fetchFromServerButton ]


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
        { onPress = Just FetchSomething, label = text "Get Some Shit From The Server" }


filesDecoder : Json.Decoder (List File)
filesDecoder =
    Json.at [ "target", "files" ] (Json.list File.decoder)
