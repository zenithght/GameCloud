%%% @author Mateusz Korszun <mkorszun@gmail.com>
%%% @copyright (C) 2012, SaveCloud
%%% @doc
%%% Database helper functions
%%% @end
%%% Created : 20 Jun 2012 by Mateusz Korszun <mkorszun@gmail.com>

-module(database).
-export([open/1, save_doc/2, save_doc/3, read_doc/2]).

open(DBName) ->
    Conn = couchbeam:server_connection(),
    couchbeam:open_db(Conn, DBName).

save_doc(DB, Doc) ->
    couchbeam:save_doc(DB, Doc).

save_doc(DB, Doc, Attachments) ->
    Doc1 = set_attachments(Doc, Attachments),
    couchbeam:save_doc(DB, Doc1).

read_doc(DB, DocId) when is_binary(DocId) ->
    couchbeam:open_doc(DB, DocId);
read_doc(DB, DocId) when is_list(DocId) ->
    read_doc(DB, list_to_binary(DocId));
read_doc(_, _) -> {error, wrong_id}.

set_attachments(Doc, [{F, C, B} | T]) ->
    Doc1 = couchbeam_attachments:add_inline(Doc, B, F, C),
    set_attachments(Doc1, T); 
set_attachments(Doc, []) ->
    Doc.

%% ###############################################################
%% ###############################################################
%% ############################################################### 