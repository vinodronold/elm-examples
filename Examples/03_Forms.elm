module Main exposing (..)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import String


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { name : String
    , age : String
    , password : String
    , passwordAgain : String
    , submit : Bool
    }


model : Model
model =
    Model "" "" "" "" False



-- UPDATE


type Msg
    = Name String
    | Age String
    | Password String
    | PasswordAgain String
    | Submit


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name, submit = False }

        Age age ->
            { model | age = age, submit = False }

        Password password ->
            { model | password = password, submit = False }

        PasswordAgain passwordAgain ->
            { model | passwordAgain = passwordAgain, submit = False }

        Submit ->
            { model | submit = True }



-- VIEW


view : Model -> Html Msg
view model =
    div [ style [ ( "padding", "10px" ) ] ]
        [ div [ style [ ( "display", "flex" ), ( "flex-direction", "row" ) ] ]
            [ getInput "text" "Name" Name
            , getInput "number" "Age" Age
            , getInput "password" "Enter Password" Password
            , getInput "password" "Enter Password Again" PasswordAgain
            , button
                [ onClick Submit
                , style
                    [ ( "background", "transparent" )
                    , ( "border", "2px solid palevioletred" )
                    , ( "color", "palevioletred" )
                    , ( "border-radius", "3px" )
                    , ( "padding", "0.25em 1em" )
                    , ( "margin", "5px" )
                    ]
                ]
                [ text "Submit" ]
            ]
        , viewValidation model
        ]


viewValidation : Model -> Html Msg
viewValidation model =
    let
        ( color, message ) =
            if String.isEmpty model.name || String.isEmpty model.password || String.isEmpty model.passwordAgain then
                ( "red", "Please enter all values before submitting" )
            else if String.length model.password < 8 then
                ( "red", "password must have atleast 8 characters" )
            else if not (String.any Char.isUpper model.password) then
                ( "red", "password must atleast contain 1 upper character" )
            else if not (String.any Char.isLower model.password) then
                ( "red", "password must atleast contain 1 lower character" )
            else if not (String.any Char.isDigit model.password) then
                ( "red", "password must atleast contain 1 numeric character" )
            else if model.password == model.passwordAgain then
                ( "green", "OK" )
            else
                ( "red", "Password entered do not match" )
    in
    if model.submit then
        div [ style [ ( "color", color ), ( "padding", "10px 0" ) ] ] [ text message ]
    else
        div [] []



-- INPUT


getInput : String -> String -> (String -> Msg) -> Html Msg
getInput inputType inputPlaceholder updateMsg =
    input [ type_ inputType, placeholder inputPlaceholder, onInput updateMsg, style inputStyle ] []



-- STYLES


inputStyle : List ( String, String )
inputStyle =
    [ ( "padding", "10px" ), ( "margin", "5px" ), ( "text-align", "center" ) ]
