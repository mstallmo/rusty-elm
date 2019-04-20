port module Main exposing (main)

import Browser
import Html exposing (Html, br, button, div, text)
import Html.Events exposing (onClick)


main : Program () Model Msg
main =
    Browser.element { init = \() -> initialModel, view = view, update = update, subscriptions = subscriptions }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Model =
    { count : Int }


initialModel : ( Model, Cmd Msg )
initialModel =
    ( { count = 0 }, Cmd.none )


type Msg
    = Increment
    | Decrement
    | SayHello


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Increment ->
            ( { model | count = model.count + 1 }, Cmd.none )

        Decrement ->
            ( { model | count = model.count - 1 }, Cmd.none )

        SayHello ->
            ( model, hello () )


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Increment ] [ text "+" ]
        , div [] [ text <| String.fromInt model.count ]
        , button [ onClick Decrement ] [ text "-" ]
        , br [] []
        , br [] []
        , button [ onClick SayHello ] [ text "Say Hello!" ]
        ]


port hello : () -> Cmd a
