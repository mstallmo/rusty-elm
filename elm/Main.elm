port module Main exposing (main)

import Browser
import Element exposing (Element, centerX, centerY, column, el, html, padding, paddingXY, rgb255, row, spacing, text)
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import Html exposing (Html, canvas)
import Http


main : Program () Model Msg
main =
    Browser.element { init = \() -> initialModel, view = view, update = update, subscriptions = subscriptions }



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- PORTS


port hello : () -> Cmd a



-- MODEL


type alias Model =
    { count : Int, serverResponse : String }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { count = 0, serverResponse = "" }, Cmd.none )



-- UPDATE


type Msg
    = Increment
    | Decrement
    | SayHello
    | FetchSomething
    | GotText (Result Http.Error String)


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
            ( model, Http.get { url = "http://localhost:8080/api/hello", expect = Http.expectString GotText } )

        GotText result ->
            case result of
                Ok fullText ->
                    ( { model | serverResponse = fullText }, Cmd.none )

                Err _ ->
                    ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    Element.layout [] <|
        elementRow model


elementRow : Model -> Element Msg
elementRow model =
    row [ spacing 40, centerX, paddingXY 0 40 ]
        [ counterColumn model
        , fetchColumn model
        , Input.button [] { onPress = Just SayHello, label = text "Say Hello" }
        , el [] (html <| canvas [] [])
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



--    el []
--        [ button [ onClick Increment ] [ text "+" ]
--        , div [] [ text <| String.fromInt model.count ]
--        , button [ onClick Decrement ] [ text "-" ]
--        , br [] []
--        , br [] []
--        , button [ onClick SayHello ] [ text "Say Hello!" ]
--        , h1 [] [ text "Hiiii" ]
--        , p [] [ text "Hellooo there I'm a <p> tag written in Elm" ]
--        , button [ onClick FetchSomething ] [ text "Get Some Shit From The Server" ]
--        , h2 [] [ text model.serverResponse ]
--        , h2 [] [ text "I just want to write some Elm!" ]
--        ]
