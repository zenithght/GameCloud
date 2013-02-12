%%% @author Mateusz Korszun <mkorszun@gmail.com>
%%% @copyright (C) 2012, GameCloud
%%% @doc
%%% Developer collection resource
%%% @end
%%% Created : 20 Jun 2012 by Mateusz Korszun <mkorszun@gmail.com>

-module(game_cloud_developer_collection).

-compile([{parse_transform, lager_transform}]).

-export([init/1, allowed_methods/2, content_types_accepted/2]).
-export([process_post/2]).

%% ###############################################################
%% INCLUDE
%% ###############################################################

-include("logger.hrl").
-include_lib("webmachine/include/webmachine.hrl").

%% ###############################################################
%% CONTROL
%% ###############################################################

init([]) ->
    {ok, []}.

allowed_methods(ReqData, Context) ->
    {['POST'], ReqData, Context}.

content_types_accepted(ReqData, Context) ->
   {[{"application/json", process_post}], ReqData, Context}.

%% ###############################################################
%% REQUEST
%% ###############################################################

%% ###############################################################
%% CREATE
%% ###############################################################

process_post(ReqData, State) ->
    try game_cloud_api_utils:request_body(ReqData) of
        {struct, Developer} ->
            case developer:create(Developer) of
                {ok, Doc} ->
                    {true, game_cloud_api_utils:set_location(
                        document:get_id(Doc), ReqData), State};
                {error, conflict} ->
                    ?ERR("Failed to create developer: already exists." ++
                        " Request data: ~p", [Developer]),
                    {{halt, 409}, ReqData, State};
                {error, {bad_data, Reason}} ->
                    ?ERR("Failed to create developer, bad data: ~p." ++
                        " Request data: ~p", [Reason, Developer]),
                    {{halt, 400}, ReqData, State};
                {error, Error} ->
                    ?ERR("Failed to create developer: ~p. Request data: ~p",
                        [Error, Developer]),
                    {{halt, 500}, ReqData, State}
            end
    catch
        _:Reason ->
            ?ERR("Failed to create developer, bad data: ~p", [Reason]),
            {{halt, 400}, ReqData, State}
    end.

%% ###############################################################
%% ###############################################################
%% ###############################################################