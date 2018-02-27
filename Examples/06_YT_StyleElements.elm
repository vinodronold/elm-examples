module Main exposing (..)

-- import Html.Attributes exposing (..)
-- import Html.Events exposing (onClick, onInput)

import Color exposing (charcoal, darkOrange, rgba)
import Element exposing (Element, button, column, el, empty, image, layout, paragraph, row, text)
import Element.Attributes exposing (center, inlineStyle, maxWidth, padding, paddingXY, percent, px, spacing, spread, verticalCenter, width)
import Element.Events exposing (onClick)
import Element.Input as Input
import Html exposing (Html, program)
import Http
import Json.Decode as Decode
import List
import Style exposing (Style, focus, hover, prop, style, styleSheet)
import Style.Border as Border
import Style.Color as Color
import Style.Font as Font


-- import List


main : Program Never Model Msg
main =
    program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { search : String
    , result : YTResult
    }


type YTResult
    = NotAsked
    | Loading
    | Failure String
    | Success YTItems


type alias YTItems =
    List YTItem


type alias YTItem =
    { id : String
    , imgUrl : String
    , title : String
    , description : String
    }


type Msg
    = SearchText String
    | FetchResult
    | FetchResultComplete (Result Http.Error YTItems)



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model "" NotAsked, Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchText text ->
            ( { model | search = text }, Cmd.none )

        FetchResult ->
            ( { model | result = Loading }, fetchYTResult model.search )

        FetchResultComplete (Ok ytSearchResult) ->
            ( { model | result = Success ytSearchResult }, Cmd.none )

        FetchResultComplete (Err _) ->
            ( { model | result = Failure "Oops.. Something went wrong.." }, Cmd.none )



-- Decoders


fetchYTResult : String -> Cmd Msg
fetchYTResult searchText =
    let
        ytApiKey =
            "AIzaSyDt03O45GRK2doERZICfzCgUbeXVFtLpiY"

        ytApiUrl =
            "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&type=video&q=" ++ searchText ++ "&key=" ++ ytApiKey

        request =
            Http.get ytApiUrl decodeYTUrl
    in
    Http.send FetchResultComplete request


decodeYTUrl : Decode.Decoder (List YTItem)
decodeYTUrl =
    decodeYTItem
        |> Decode.list
        |> Decode.field "items"


decodeYTItem : Decode.Decoder YTItem
decodeYTItem =
    Decode.map4 YTItem
        (Decode.at [ "id", "videoId" ] Decode.string)
        (Decode.at [ "snippet", "thumbnails", "default", "url" ] Decode.string)
        (Decode.at [ "snippet", "title" ] Decode.string)
        (Decode.at [ "snippet", "description" ] Decode.string)


view : Model -> Html Msg
view model =
    layout stylesheet <|
        el Container
            [ padding 10 ]
            (column
                None
                [ padding 10, spacing 10 ]
                [ el Title [ center ] (text "YouTube Search")
                , Input.text SearchInput
                    [ center, width (percent 75) ]
                    { onChange = SearchText
                    , value = model.search
                    , label = Input.hiddenLabel ""
                    , options = []
                    }
                , el None [ center ] (button SearchButton [ paddingXY 10 5, onClick FetchResult ] (text "Search"))
                , el None [ center ] (displayResult model)
                ]
            )


displayResult : Model -> Element Styles variation msg
displayResult model =
    case model.result of
        NotAsked ->
            el None [ center ] (text "No Search Ran")

        Loading ->
            el None [ center ] (text "Loading . . . ")

        Success results ->
            case results of
                [] ->
                    el None [ center ] (text "Nothing is found")

                xs ->
                    column None [ width (percent 75), spacing 15 ] (displayYTItems xs)

        Failure err ->
            el None [ center ] (text err)


displayYTItems : YTItems -> List (Element Styles variation msg)
displayYTItems =
    List.map displayYTItem


displayYTItem : YTItem -> Element Styles variation msg
displayYTItem item =
    row None
        [ spacing 10 ]
        [ image None [] { src = item.imgUrl, caption = item.title }
        , column None
            [ spacing 5, verticalCenter ]
            [ el None [] (text item.title)
            , paragraph None [] <| el None [] (text item.description) :: []
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- STYLESHEETS


type Styles
    = None
    | Container
    | SearchInput
    | SearchButton
    | Title


stylesheet : Style.StyleSheet Styles variation
stylesheet =
    styleSheet
        [ style None []
        , style Container []
        , style SearchInput
            [ Border.bottom 3
            , Border.solid
            , Color.border darkOrange
            , Font.size 32
            , Color.text charcoal
            , focus [ prop "box-shadow" "none" ]
            ]
        , style SearchButton
            [ Color.border darkOrange
            , Color.background (rgba 0 0 0 0)
            , Color.text charcoal
            , Border.all 2
            , Border.rounded 5
            , hover [ Color.text darkOrange ]
            ]
        , style Title
            [ Font.size 48
            , Color.text charcoal
            ]
        ]
