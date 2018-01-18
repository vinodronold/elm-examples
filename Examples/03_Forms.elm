module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput)


main : Program Never Model Msg
main =
    Html.beginnerProgram { model = model, view = view, update = update }



-- MODEL


type alias Model =
    { name : String
    , password : String
    , passwordAgain : String
    }


model : Model
model =
    Model "" "" ""



-- UPDATE


type Msg
    = Name String
    | Password String
    | PasswordAgain String


update : Msg -> Model -> Model
update msg model =
    case msg of
        Name name ->
            { model | name = name }

        Password password ->
            { model | password = password }

        PasswordAgain passwordAgain ->
            { model | passwordAgain = passwordAgain }



-- VIEW


view : Model -> Html Msg
view model =
    div [ style [ ( "padding", "10px" ) ] ]
        [ div [ style [ ( "display", "flex" ), ( "flex-direction", "column" ) ] ]
            [ getInput "text" "Name" Name
            , getInput "password" "Enter Password" Password
            , getInput "password" "Enter Password Again" PasswordAgain
            ]
        , viewValidation model
        ]


viewValidation : Model -> Html Msg
viewValidation model =
    let
        ( color, message ) =
            if model.password == model.passwordAgain then
                ( "green", "OK" )
            else
                ( "red", "Password entered do not match" )
    in
    div [ style [ ( "color", color ), ( "text-align", "center" ), ( "padding", "10px 0" ) ] ] [ text message ]



-- INPUT


getInput : String -> String -> (String -> Msg) -> Html Msg
getInput inputType inputPlaceholder updateMsg =
    input [ type_ inputType, placeholder inputPlaceholder, onInput updateMsg, style inputStyle ] []



-- STYLES


inputStyle : List ( String, String )
inputStyle =
    [ ( "padding", "10px" ), ( "margin", "5px" ), ( "text-align", "center" ) ]
