module Main exposing (..)

import Char
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import List
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
        validations =
            [ ( String.length model.password >= 8, "password must have atleast 8 characters" )
            , ( String.any Char.isUpper model.password, "password must atleast contain 1 upper character" )
            , ( String.any Char.isLower model.password, "password must atleast contain 1 lower character" )
            , ( String.any Char.isDigit model.password, "password must atleast contain 1 numeric character" )
            , ( passwordNotMatch model, "Password entered do not match" )
            ]
    in
    div [ style [ ( "padding", "10px 0" ) ] ]
        (List.map validationMessage validations)


passwordNotMatch : Model -> Bool
passwordNotMatch model =
    (model.password == model.passwordAgain) && not (String.isEmpty model.password)


validationMessage : ( Bool, String ) -> Html Msg
validationMessage ( isValid, displayMessage ) =
    div
        [ style
            [ ( "color", getColor isValid )
            , ( "padding", "10px 0" )
            ]
        ]
        [ text displayMessage ]


getColor : Bool -> String
getColor isValid =
    if isValid then
        "green"
    else
        "red"



-- INPUT


getInput : String -> String -> (String -> Msg) -> Html Msg
getInput inputType inputPlaceholder updateMsg =
    input [ type_ inputType, placeholder inputPlaceholder, onInput updateMsg, style inputStyle ] []



-- STYLES


inputStyle : List ( String, String )
inputStyle =
    [ ( "padding", "10px" ), ( "margin", "5px" ), ( "text-align", "center" ) ]
