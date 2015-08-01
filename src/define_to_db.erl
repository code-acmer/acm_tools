-module(define_to_db).
-export([start/0]).
-define(TEST_DEFINE_FILE, "/home/roowe/happytree/server_p02/include/define_money_cost.hrl").

start() ->
    ensure_deps_started(),
    ensure_pool_added([]), %% not options, only for test
    {ok, Bin} = file:read_file(?TEST_DEFINE_FILE),
    DefineList = string:tokens(binary_to_list(Bin), "\n"),
    io:format("~p~n", [DefineList]),
    DataList =
        lists:foldl(fun(Define, Acc) ->
                            Data = get_data_from_define(Define),
                            if
                                is_tuple(Data) ->
                                    [Data | Acc];
                                true ->
                                    Acc
                            end
                    end, [], DefineList),
    io:format("----------------------------------------~n", []),
    SQL = insert_base_cost_type_list(DataList),
    Res = emysql:execute(db_base, SQL),
    io:format("~p~n", [Res]),
    ok.
insert_base_cost_type_list(List) ->
    BaseSQL = "INSERT INTO `base_cost_type` (`id`, `define`, `desc`) VALUES ",
    ValFun = fun(Macro, Integer, Comment) ->
                     NewComment = string:strip(Comment, left, $%),
                     lists:concat(["(\"", Integer, "\",\"", Macro , "\",\"", NewComment, "\")"])
             end,
    ValsStr = [ValFun(Macro, Integer, Comment) ||
                  {Macro, Integer, Comment} <- List],
    io_lib:format("~s~n", [[BaseSQL, string:join(ValsStr, ",")]]).

get_data_from_define(Define) ->
    case erl_scan:string(Define, 0, [return_comments]) of
        {ok, [{'-', _},
              {atom, _, define},
              {'(', _},
              {var, _, Macro},
              {',', _},
              {integer, _, Integer},
              {')', _},
              {dot, _},
              {comment, _, Comment}],
         _} ->
            {Macro, Integer, Comment};
        Other ->
            io:format("Other ~w~n", [Other])
    end.


%%-------------------- ensure --------------------
%% 确保deps的App启动
ensure_deps_started() ->
    [ok = ensure_started(App) || App <- [crypto, emysql]].

ensure_started(App) ->
    case application:start(App) of
        ok ->
            ok;
        {error, {already_started, App}} ->
            ok
    end.

ensure_pool_added(Options) ->
    Db = db_base,
    Poolsize = 1,
    User = proplists:get_value(db_user, Options, "root"),
    Password = proplists:get_value(db_password, Options, "root"),
    Host = proplists:get_value(db_host, Options, "127.0.0.1"),
    Port = proplists:get_value(db_port, Options, 3306),
    DataBase = proplists:get_value(db_base, Options, "test"),
    case catch emysql:add_pool(Db, Poolsize, User, Password, Host, Port, DataBase, utf8) of
        {'EXIT', pool_already_exists} ->
            ok;
        Other ->
            Other
    end.
