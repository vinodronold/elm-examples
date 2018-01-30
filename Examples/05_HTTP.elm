module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode as Decode


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = ChangeTopic String
    | NewGif (Result Http.Error String)
    | GetNewGif



-- MODEL


type alias Model =
    { topic : String
    , gifUrl : Maybe String
    , displayText : Maybe String
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model "cats" Nothing Nothing, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ChangeTopic topic ->
            ( { model | topic = topic, gifUrl = Nothing, displayText = Nothing }, Cmd.none )

        NewGif (Ok url) ->
            ( { model | gifUrl = Just url }, Cmd.none )

        NewGif (Err _) ->
            ( model, Cmd.none )

        GetNewGif ->
            ( { model | gifUrl = Nothing, displayText = Just "Loading . . ." }, getRandomGif model.topic )


getRandomGif : String -> Cmd Msg
getRandomGif topic =
    let
        httpUrl =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic

        request =
            Http.get httpUrl decodeGifUrl
    in
    Http.send NewGif request


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
    Decode.at [ "data", "image_url" ] Decode.string



-- VIEW


view : Model -> Html Msg
view model =
    wrapperElement
        (div []
            [ wrapperElement
                (input
                    [ style
                        [ ( "padding", "10px" )
                        , ( "width", "75%" )
                        , ( "text-align", "center" )
                        , ( "font-size", "32px" )
                        , ( "border", "none" )
                        , ( "border-bottom", "solid 3px #222" )
                        ]
                    , value model.topic
                    , onInput ChangeTopic
                    ]
                    []
                )
            , wrapperElement
                (div
                    [ style
                        [ ( "height", "300px" )
                        , ( "width", "auto" )
                        , ( "display", "flex" )
                        , ( "align-item", "center" )
                        , ( "justify-content", "center" )
                        ]
                    ]
                    [ displayImage model ]
                )
            , wrapperElement
                (button
                    [ style
                        [ ( "background", "transparent" )
                        , ( "border", "solid 2px orange" )
                        , ( "border-radius", "5px" )
                        , ( "padding", "5px 10px" )
                        , ( "cursor", "pointer" )
                        ]
                    , onClick GetNewGif
                    ]
                    [ text "Get New Gif" ]
                )
            ]
        )


wrapperElement : Html Msg -> Html Msg
wrapperElement child =
    div
        [ style
            [ ( "text-align", "center" )
            , ( "padding", "20px" )
            ]
        ]
        [ child ]


displayImage : Model -> Html Msg
displayImage model =
    case model.gifUrl of
        Nothing ->
            case model.displayText of
                Nothing ->
                    text "Click the Get New Gif Button"

                Just str ->
                    text str

        Just url ->
            img
                [ src url
                , style
                    [ ( "max-width", "100%" )
                    , ( "max-height", "100%" )
                    ]
                ]
                []



-- SUB


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
