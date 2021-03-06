%%% @author Mateusz Korszun <mkorszun@gmail.com> 
%%% @copyright (C) 2012, GameCloud 
%%% @doc
%%% Register developer API
%%% @end
%%% Created : 20 Jun 2012 by Mateusz Korszun <mkorszun@gmail.com>

-module(register_developer_api).
-export([out/1]).

%% ###############################################################
%% INCLUDES
%% ###############################################################

-include("api.hrl").

%% ###############################################################
%% CALLBACK FUNCTION
%% ###############################################################

out(A) ->
    Args = yaws_api:parse_post(A),
    {ok, DBName} = application:get_env(?APP, ?DB),
    {ok, DB} = database:open(DBName),
    Register = fun() -> developer:register(DB, Args) end,
    case request:execute(validate(), Args, Register) of
        {ok, _} ->
            [{status, 200}, {content, "application/json", response:to_json("ok")}];
        {error, developer_already_exists} ->
            [{status, 400}, {content, "appllication/json", response:to_json("Developer already exists")}];
        {error, {missing_param, Code, Message}} ->
            [{status, Code}, {content, "appllication/json", response:to_json(Message)}];
        {error, _Error} ->
            [{status, 500}, {content, "application/json", response:to_json("Internal error")}]
    end.

%% ###############################################################
%% VALIDATE PARAMS
%% ###############################################################

validate() ->
    [
        {"developer_id", undefined, 400, "Missing developer id"},
        {"developer_id", [], 400, "Empty developer id"},
        {"password", undefined, 400, "Missing developer password"},
        {"password", [], 400, "Empty developer password"},
        {"email", undefined, 400, "Missing email"},
        {"email", [], 400, "Empty email"}
    ].

%% ###############################################################
%% ###############################################################
%% ###############################################################
