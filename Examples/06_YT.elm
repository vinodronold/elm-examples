module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import List


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


type Msg
    = SearchText String
    | FetchResult
    | FetchResultComplete (Result Http.Error (List YTItem))


type alias YTItem =
    { id : String
    , imgUrl : String
    , title : String
    , description : String
    }


type YTResult
    = Results (List YTItem)
    | Loading



-- MODEL


type alias Model =
    { search : String
    , result : YTResult
    }



-- INIT


init : ( Model, Cmd Msg )
init =
    ( Model "" (Results []), Cmd.none )



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SearchText text ->
            ( { model | search = text }, Cmd.none )

        FetchResult ->
            ( { model | result = Loading }, fetchYTResult model.search )

        FetchResultComplete (Ok ytSearchResult) ->
            ( { model | result = Results ytSearchResult }, Cmd.none )

        FetchResultComplete (Err _) ->
            ( model, Cmd.none )



-- Decoders


fetchYTResult : String -> Cmd Msg
fetchYTResult searchText =
    let
        ytApiUrl =
            "https://www.googleapis.com/youtube/v3/search?part=snippet&maxResults=25&type=video&q=" ++ searchText ++ "&key=AIzaSyDt03O45GRK2doERZICfzCgUbeXVFtLpiY"

        request =
            Http.get ytApiUrl decodeYTUrl
    in
    Http.send FetchResultComplete request


decodeYTUrl : Decode.Decoder (List YTItem)
decodeYTUrl =
    decodeYTItem
        |> Decode.list
        |> Decode.field "items"



-- decodeYTUrl =
--     Decode.field "items"
--         (Decode.maybe
--             (Decode.list
--                 decodeYTItem
--             )
--         )


decodeYTItem : Decode.Decoder YTItem
decodeYTItem =
    Decode.map4 YTItem
        (Decode.at [ "id", "videoId" ] Decode.string)
        (Decode.at [ "snippet", "thumbnails", "default", "url" ] Decode.string)
        (Decode.at [ "snippet", "title" ] Decode.string)
        (Decode.at [ "snippet", "description" ] Decode.string)



-- decodeYTUrl =
--     Decode.field "items"
--         (Decode.maybe
--             (Decode.list
--                 (Decode.map3 YTItem
--                     (Decode.at [ "id", "videoId" ] Decode.string)
--                     (Decode.at [ "snippet", "thumbnails", "default", "url" ] Decode.string)
--                     (Decode.at [ "snippet", "title" ] Decode.string)
--                 )
--             )
--         )
-- decodeYTUrl =
--     Decode.nullable
--         (Decode.field "items"
--             (Decode.list
--                 (Decode.map3 YTItem
--                     (Decode.at [ "id", "videoId" ] Decode.string)
--                     (Decode.at [ "snippet", "thumbnails", "default", "url" ] Decode.string)
--                     (Decode.at [ "snippet", "title" ] Decode.string)
--                 )
--             )
--         )
--         |> Decode.map
--             (Maybe.andThen
--                 (\x ->
--                     if List.length x == 0 then
--                         Nothing
--                     else
--                         Just x
--                 )
--             )


view : Model -> Html Msg
view model =
    div [ style styleContainer ]
        [ h1 [ style styleHeader ] [ text "YouTube Search" ]
        , div
            [ style styleSearch ]
            [ input [ style styleSearchInput, placeholder "Search", value model.search, onInput SearchText ] []
            , button [ style styleButton, onClick FetchResult ] [ text "Search" ]
            ]
        , div [ style [ ( "margin", "0 12.5%" ) ] ] [ displayResult model ]
        ]


displayResult : Model -> Html Msg
displayResult model =
    case model.result of
        Loading ->
            div [] [ text "Loading . . . " ]

        Results results ->
            case results of
                [] ->
                    div [] [ text "Nothing is display" ]

                xs ->
                    ul [ style styleDisplaResultUL ]
                        (List.map displayItem xs)


displayItem : YTItem -> Html Msg
displayItem { id, imgUrl, title, description } =
    li [ style [ ( "padding", "10px" ) ] ]
        [ a
            [ href <| "https://www.youtube.com/watch?v=" ++ id
            , target "_blank"
            , style styleLink
            ]
            [ div [ style [ ( "padding-right", "10px" ) ] ]
                [ img [ src imgUrl ] []
                ]
            , div []
                [ div [ style [ ( "font-size", "24px" ) ] ] [ text title ]
                , div [ style [ ( "font-size", "12px" ) ] ] [ text description ]
                ]
            ]
        ]



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- STYLES


type alias StyleAttributes =
    List ( String, String )


styleHeader : StyleAttributes
styleHeader =
    [ ( "font-size", "48px" )
    , ( "color", "#5b5b5b" )
    ]


styleContainer : StyleAttributes
styleContainer =
    [ ( "text-align", "center" )
    , ( "padding", "20px" )
    ]


styleSearch : StyleAttributes
styleSearch =
    [ ( "display", "flex" )
    , ( "flex-direction", "column" )
    , ( "align-items", "center" )
    ]


styleSearchInput : StyleAttributes
styleSearchInput =
    [ ( "padding", "10px" )
    , ( "width", "75%" )
    , ( "text-align", "center" )
    , ( "font-size", "32px" )
    , ( "border", "none" )
    , ( "border-bottom", "solid 3px tomato" )
    , ( "outline", "none" )
    , ( "color", "#5b5b5b" )
    ]


styleButton : StyleAttributes
styleButton =
    [ ( "max-width", "100px" )
    , ( "padding", "10px 20px" )
    , ( "margin", "20px" )
    , ( "background-color", "transparent" )
    , ( "border", "solid 2px tomato" )
    , ( "border-radius", "3px" )
    , ( "color", "tomato" )
    , ( "cursor", "pointer" )
    ]


styleDisplaResultUL : StyleAttributes
styleDisplaResultUL =
    [ ( "list-style-type", "none" )
    , ( "display", "flex" )
    , ( "flex-direction", "column" )
    , ( "text-align", "left" )
    , ( "margin", "0" )
    , ( "padding", "0" )
    ]


styleLink : StyleAttributes
styleLink =
    [ ( "display", "flex" )
    , ( "align-items", "center" )
    , ( "text-decoration", "none" )
    , ( "color", "#5b5b5b" )
    ]
