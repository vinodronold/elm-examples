module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import List
import Random exposing (..)


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions =
            subscriptions
        }



-- MODEL


type alias Model =
    { dieFace : Int
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model 1, Cmd.none )


type Msg
    = Roll
    | NewFace Int



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model, Random.generate NewFace (Random.int 1 6) )

        NewFace newFace ->
            ( { model | dieFace = newFace }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ style
            [ ( "display", "flex" )
            , ( "flex-direction", "column" )
            , ( "justify-content", "center" )
            , ( "align-items", "center" )
            ]
        ]
        [ div
            [ style
                [ ( "font-size", "64px" )
                , ( "border", "solid 2px #222" )
                , ( "margin", "10px" )
                , ( "width", "100px" )
                , ( "height", "100px" )
                , ( "border-radius", "5px" )
                , ( "display", "flex" )
                , ( "justify-content", "center" )
                , ( "align-items", "center" )
                , ( "flex-wrap", "wrap" )
                ]
            ]
            (face model.dieFace)
        , button
            [ style
                [ ( "background", "transparent" )
                , ( "border", "solid 2px orange" )
                , ( "border-radius", "5px" )
                , ( "padding", "5px 10px" )
                ]
            , onClick Roll
            ]
            [ text "Roll" ]
        ]


face : Int -> List (Html Msg)
face dieFace =
    List.map (dots dieFace) (List.range 1 9)


dots : Int -> Int -> Html Msg
dots dieFace n =
    div
        [ style
            [ ( "height", "20px" )
            , ( "width", "20px" )
            , ( "margin", "5px" )
            , ( "border-radius", "50%" )
            , ( "background-color", dot dieFace n )
            ]
        ]
        []


dot : Int -> Int -> String
dot dieFace n =
    let
        dark =
            "#222"

        light =
            "#fff"
    in
    if n == 1 then
        if dieFace == 4 || dieFace == 5 || dieFace == 6 then
            dark
        else
            light
    else if n == 2 then
        if dieFace == 6 then
            dark
        else
            light
    else if n == 3 then
        if dieFace == 4 || dieFace == 5 || dieFace == 6 then
            dark
        else
            light
    else if n == 4 then
        if dieFace == 2 || dieFace == 3 then
            dark
        else
            light
    else if n == 5 then
        if dieFace == 1 || dieFace == 3 || dieFace == 5 then
            dark
        else
            light
    else if n == 6 then
        if dieFace == 2 || dieFace == 3 then
            dark
        else
            light
    else if n == 7 then
        if dieFace == 4 || dieFace == 5 || dieFace == 6 then
            dark
        else
            light
    else if n == 8 then
        if dieFace == 6 then
            dark
        else
            light
    else if n == 9 then
        if dieFace == 4 || dieFace == 5 || dieFace == 6 then
            dark
        else
            light
    else
        light



-- subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none
