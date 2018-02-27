module Main exposing (..)

import Css exposing (..)
import Html
import Html.Styled exposing (..)
import Html.Styled.Attributes exposing (..)
import Html.Styled.Events exposing (onClick, onInput)
import List
import Task
import Time
import WebSocket


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view >> toUnstyled
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { input : String
    , currentDateTime : Time.Time
    , messages : List ( Message, Time.Time )
    }


type Message
    = Received String
    | Sent String


type Msg
    = Input String
    | Send
    | NewMessage String
    | OnTime Msg Time.Time



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model "" 0 [], Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input input ->
            ( { model | input = input }, Cmd.none )

        OnTime prograteTo time ->
            ( { model | currentDateTime = time }, Cmd.none )

        Send ->
            ( { model
                | input = ""
                , messages = ( Received model.input, model.currentDateTime ) :: model.messages
              }
            , WebSocket.send "ws://echo.websocket.org" model.input
            )

        NewMessage newMessage ->
            ( { model
                | input = ""
                , messages = ( Sent newMessage, model.currentDateTime ) :: model.messages
              }
            , Cmd.none
            )



-- COMMANDS
-- SUBSCRIPTION


subscriptions : Model -> Sub Msg
subscriptions model =
    WebSocket.listen "ws://echo.websocket.org" NewMessage



-- VIEW


view : Model -> Html Msg
view model =
    div [ css styleContainer ]
        [ div [ css styleMessages ] <| displayMessages model.messages
        , div []
            [ div [ css [ padding2 (px 10) (px 0) ] ] [ textarea [ css styleTextArea, placeholder "Enter the message", value model.input, onInput Input ] [] ]
            , div [] [ button [ onClick Send ] [ text "Send" ] ]
            ]
        ]


displayMessages : List ( Message, Time.Time ) -> List (Html Msg)
displayMessages messages =
    messages
        -- |> List.reverse
        |> List.map
            (\( message, time ) ->
                case message of
                    Received str ->
                        div [ css styleMessageReceived ] [ text str ]

                    Sent str ->
                        div []
                            [ div [ css styleMessageSent ] [ text str ]
                            , div [ css [ textAlign right, fontSize (px 12) ] ] [ text <| "sent : " ++ toString time ]
                            ]
            )



-- STYLES


styleContainer : List Css.Style
styleContainer =
    [ padding <| px 30
    , backgroundColor <| hex "eee"
    , Css.height <| vh 100
    ]


styleMessages : List Css.Style
styleMessages =
    [ Css.height <| vh 75
    , displayFlex
    , flexDirection column
    ]


styleMessageSent : List Css.Style
styleMessageSent =
    [ padding <| px 5
    , border3 (px 2) solid (hex "26c6da")
    , borderRadius (px 5)
    , textAlign right
    , marginLeft <| pct 30
    , backgroundColor <| hex "26c6da"
    ]


styleMessageReceived : List Css.Style
styleMessageReceived =
    [ margin <| px 5
    , padding <| px 5
    , border3 (px 2) solid (hex "66bb6a")
    , borderRadius (px 5)
    , marginRight <| pct 30
    , backgroundColor <| hex "66bb6a"
    ]


styleTextArea : List Css.Style
styleTextArea =
    [ Css.width <| pct 100
    , padding <| px 10
    ]
