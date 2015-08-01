-module(data_module).

-export([start/0, %% may be for test only, data_module_ctl always transfers options
         start/2,
         tables/0]).

-export([
         default_db_host/0,
         default_db_port/0,
         default_db_user/0,
         default_db_password/0,
         default_db_base/0,
         default_generate_dir/0,
         default_jobs/0
        ]).

-export([fprof/0]).

-export([
         get_fields/1 %% not public 内部接口 获取字段
        ]).
%% for apply(?MODULE, Fun, [])
-export([
         base_combat_skill_upgrade/0,
         base_activity/0,
         base_activity_twist_egg/0,
         base_combat_skill/0,
         base_dungeon/0,
         base_equipment/0,
         base_equipment_property/0,
         base_equipment_upgrade/0,
         base_fashion/0,
         base_function_open/0,
         base_login_reward/0,
         base_mon/0,
         base_player/0,
         base_protocol/0,
         base_rate/0,
         base_store_product/0,
         base_twist_egg/0
        ]).

-include("define_data_generate.hrl").

%% data header file
-include("db_base_store_product.hrl").
-include("db_base_function_open.hrl").
-include("define_dungeon.hrl").
-include("db_base_activity_twist_egg.hrl").
-include("db_base_login_reward.hrl").
-include("db_base_combat_skill_upgrade.hrl").
-include("db_base_activity.hrl").
-include("db_base_combat_skill.hrl").
-include("db_base_equipment.hrl").
-include("db_base_equipment_property.hrl").
-include("db_base_equipment_upgrade.hrl").
-include("db_base_fashion.hrl").
-include("db_base_mon.hrl").
-include("db_base_player.hrl").
-include("db_base_protocol.hrl").
-include("db_base_rate.hrl").
-include("db_base_twist_egg.hrl").

-define(DATA_TABLE_LIST, [base_combat_skill_upgrade, 
                          base_activity,                 
                          base_activity_twist_egg,
                          base_combat_skill,
                          base_dungeon,
                          base_equipment,
                          base_equipment_property,
                          base_equipment_upgrade,
                          base_fashion,
                          base_function_open,
                          base_login_reward,
                          base_mon,
                          base_player,
                          base_protocol,
                          base_rate,
                          base_store_product,
                          base_twist_egg
                         ]).

-define(DEFAULT_OPTIONS, [
                          {db_host, "192.168.1.149"},
                          {db_port, 3306},
                          {db_user, "mroot"}, 
                          {db_password, "mroot"},
                          {db_base, "p02_base"},
                          {generate_dir, "/tmp/"},
                          {jobs, 2}
                          ]).


-define(GET_FIELDS_FUN(TableName), get_fields(TableName) -> ?RECORD_FIELDS(TableName)).
%% 根据record名字获取其字段，被data_generate模块使用
%% 警告：出于性能考虑，业务模块不准这么用。
?GET_FIELDS_FUN(base_function_open);
?GET_FIELDS_FUN(base_store_product);
?GET_FIELDS_FUN(data_dungeon);
?GET_FIELDS_FUN(base_activity_twist_egg);
?GET_FIELDS_FUN(base_login_reward);
?GET_FIELDS_FUN(base_combat_skill_upgrade);
?GET_FIELDS_FUN(data_base_activity);
?GET_FIELDS_FUN(base_combat_skill);
?GET_FIELDS_FUN(ets_base_equipment);
?GET_FIELDS_FUN(ets_base_equipment_property);
?GET_FIELDS_FUN(ets_base_equipment_upgrade);
?GET_FIELDS_FUN(data_base_fashion);
?GET_FIELDS_FUN(ets_base_mon);
?GET_FIELDS_FUN(ets_base_player);
?GET_FIELDS_FUN(ets_base_protocol);
?GET_FIELDS_FUN(base_rate);
?GET_FIELDS_FUN(base_twist_egg);
get_fields(Record) ->
    throw({not_fields, Record}).



fprof() ->
    fprof:trace(start),
    start(),
    fprof:trace(stop),
    fprof:profile(),
    fprof:analyse({dest, "data_module.txt"}).

%% 优化：多进程生成
mul_process(AllTables, Options) ->
    GenerateDir = generate_dir(Options),
    Jobs = jobs(Options),
    GenerateFun =
        fun(TableName) ->
                apply(data_generate, data_generate, [GenerateDir|?MODULE:TableName()])
        end,
    PidMRefs = [spawn_monitor(fun () -> 
                                      [GenerateFun(Table) || Table <- Tables]
                              end) ||
                   Tables <- list_split(AllTables, Jobs)],
    [receive
         {'DOWN', MRef, process, _, normal} -> ok;
         {'DOWN', MRef, process, _, Reason} -> exit(Reason)
     end || {_Pid, MRef} <- PidMRefs],
    ok.

start() ->
    start(?DATA_TABLE_LIST, ?DEFAULT_OPTIONS).

start(TableName, Options) 
  when is_atom(TableName) ->
    start([TableName], Options);
start(TableNameList, Options) ->
    print_options_info(Options),
    GenerateDir = generate_dir(Options),
    data_generate:load_version_to_ets(GenerateDir),
    AllowTableList = sets:to_list(
                       sets:intersection(
                         sets:from_list(TableNameList), 
                         sets:from_list(?DATA_TABLE_LIST))),

    data_generate:ensure_deps_started(),
    data_generate:ensure_pool_added(Options),
    
    mul_process(AllowTableList, Options),
    case TableNameList -- AllowTableList of
        [] ->
            ignore;
        IllegalTableList ->
            io:format("<<warning>> these tables ~p are not generated. because these are not in ~p~n", 
                      [IllegalTableList, ?DATA_TABLE_LIST])
    end,
    data_generate:record_version_from_ets(GenerateDir),
    ok.
%% -------------------- for data_module_ctl --------------------

tables() ->
    ?DATA_TABLE_LIST.

default_db_host() ->
    proplists:get_value(db_host, ?DEFAULT_OPTIONS).

default_db_port() ->
    proplists:get_value(db_port, ?DEFAULT_OPTIONS).

default_db_user() ->
    proplists:get_value(db_user, ?DEFAULT_OPTIONS).

default_db_password() ->
    proplists:get_value(db_password, ?DEFAULT_OPTIONS).

default_db_base() ->
    proplists:get_value(db_base, ?DEFAULT_OPTIONS).

default_generate_dir() ->
    proplists:get_value(generate_dir, ?DEFAULT_OPTIONS).

default_jobs() ->
    proplists:get_value(jobs, ?DEFAULT_OPTIONS).

%% -------------------- 处理选项 --------------------
   
generate_dir(Options) ->
    proplists:get_value(generate_dir, Options).

jobs(Options) ->
    proplists:get_value(jobs, Options).

print_options_info(Options) ->
    io:format("--------------------选项信息--------------------~n", []),
    io:format("数据库Host ~s~n", [proplists:get_value(db_host, Options)]),
    io:format("数据库端口 ~p~n", [proplists:get_value(db_port, Options)]),
    io:format("数据库用户名 ~s~n", [proplists:get_value(db_user, Options)]),
    io:format("数据库密码 ~s~n", [proplists:get_value(db_password, Options)]),
    io:format("数据库名字 ~s~n", [proplists:get_value(db_base, Options)]),
    io:format("数据的输出目录 ~s~n", [proplists:get_value(generate_dir, Options)]),
    io:format("生成数据的并发进程数 ~p~n", [proplists:get_value(jobs, Options)]),
    io:format("------------------------------------------------~n", []).
%%--------------------每张表的生成函数--------------------

base_combat_skill_upgrade() ->
    [base_combat_skill_upgrade, 
     [default_get_generate_conf(record_info(fields, base_combat_skill_upgrade), 
                                id)]].

base_activity() ->
    Fields = record_info(fields, data_base_activity),
    NewFields = trans_to_term(Fields, [req_time, value, range, key]),
    GetGenerateConf = default_get_generate_conf(NewFields, id,  nil),
    AllGenerateConf = default_all_generate_conf(id),
    [data_base_activity, base_activity, ["db_base_activity.hrl"],
     [GetGenerateConf, AllGenerateConf]].

%% 这是一个坑，同样的结构用了两张表，加下type会死呀。
%% 这个不是数据生成的好例子。
base_twist_egg() ->
    base_twist_egg(base_twist_egg).
base_activity_twist_egg() ->
    base_twist_egg(base_activity_twist_egg).

base_twist_egg(TableName) ->
    BaseGenerateConf = #generate_conf{                          
                          record_conf = all, 
                          handle_args_fun = fun(_RecordData) ->
                                                    null
                                            end, 
                          handle_result_fun = fun(_RecordData) ->
                                                      {tuple, [goods_id, rate]}
                                              end                          
                         },
    FilterDataFun = fun(Type) ->
                            fun(DataList) ->
                                    lists:filter(fun(#base_twist_egg{type=MType}) ->
                                                         MType =:= Type
                                                 end, DataList)
                            end
                    end,
    FilterGetFunData = fun(DataList) ->
                               %% 先过滤下一样的goods_id，然后再按id排回去
                               lists:keysort(#base_twist_egg.id, lists:ukeysort(#base_twist_egg.goods_id, DataList))
                       end,
    [base_twist_egg, TableName, [],
     [#generate_conf{
         fun_name = get,
         record_conf = single, 
         handle_args_fun = fun(_RecordData) ->
                                   goods_id
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {single, att_lv}
                             end,
         filter = FilterGetFunData,
         default = nil
        },
      BaseGenerateConf#generate_conf{
        fun_name = get_gold_twist,
        filter = FilterDataFun(2)
       },
      BaseGenerateConf#generate_conf{
        fun_name = get_friend_val_twist,
        filter = FilterDataFun(1)
       },
      BaseGenerateConf#generate_conf{
        fun_name = get_extra_twist_egg,                                   
        filter = FilterDataFun(3)
       }
     ]].

base_combat_skill() ->
    [base_combat_skill, 
     [default_get_generate_conf([id, unique_id, lv, max_lv], 
                                id)]].

base_dungeon() ->
    Fields = record_info(fields, data_dungeon),

    AfterDelFields = del_fields(Fields, [session_pos, goal, extra_goal, icon]), 
    AfterTransTermFields = trans_to_term(AfterDelFields, [req_time,monsters]),
    AfterTransRecordFields = trans_to_record(AfterTransTermFields,
                                             [{reward, common_reward},
                                              {extra_reward, common_reward},
                                              {special_reward, common_reward}]),
    LastFields = AfterTransRecordFields,
    [data_dungeon, base_dungeon, ["define_dungeon.hrl"],
     [#generate_conf{
         fun_name = get_dungeon,
         record_conf = single, 
         handle_args_fun = fun(_RecordData) ->
                                   id
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {record, LastFields}
                             end,
         default = nil
        }, 
      #generate_conf{
         fun_name = get_next_dungeon,
         record_conf = single, 
         handle_args_fun = fun(_RecordData) ->
                                   req_pre_id
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {single, [id]}
                             end,
         filter = fun(DataList) ->
                          lists:filter(fun(#data_dungeon{req_pre_id=ReqPreId}) ->
                                               ReqPreId =/= 0
                                       end, DataList)
                  end,
         default = nil
        }
     ]].
base_equipment() ->
    Fields = record_info(fields, ets_base_equipment),
    AfterDelFields = del_fields(Fields, [nid, desc, extra_goal]), 
    AfterTransTermFields = trans_to_term(AfterDelFields, [master_skills, ext_rate]),
    LastFields = AfterTransTermFields,
    [ets_base_equipment, base_equipment, ["db_base_equipment.hrl"],
     [#generate_conf{
         fun_name = get_base_goods,
         record_conf = single, 
         handle_args_fun = fun(_RecordData) ->
                                   id
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {record, LastFields}
                             end
        }]].

base_equipment_property() ->
    Fields = record_info(fields, ets_base_equipment_property),
    AfterDelFields = del_fields(Fields, [memo]), 
    LastFields = AfterDelFields,
    [ets_base_equipment_property, base_equipment_property, ["db_base_equipment_property.hrl"],
     [default_get_generate_conf(LastFields, id)]].

base_equipment_upgrade() ->
    Fields = record_info(fields, ets_base_equipment_upgrade),
    AfterTransTermFields = trans_to_term(Fields, [next_id]),
    LastFields = AfterTransTermFields,
    [ets_base_equipment_upgrade, base_equipment_upgrade, ["db_base_equipment_upgrade.hrl"],
     [default_get_generate_conf(LastFields, id)]].

base_fashion() ->
    Fields = record_info(fields, data_base_fashion),
    GenerateConf = default_get_generate_conf(Fields, id, nil),    
    [data_base_fashion, base_fashion, ["db_base_fashion.hrl"],
     [#generate_conf{
         fun_name = get_career_fashion, 
         record_conf = {more, career}, 
         handle_result_fun = fun(_RecordData) ->
                                     {single, id}
                             end
        }, GenerateConf]].

base_function_open() ->
    [base_function_open,
     [#generate_conf{
         fun_name = get,
                                                %args_count = 3,
         record_conf = single, 
         handle_args_fun = fun(_RecordData) ->
                                   [type, career, req_lv]
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {record, [type,req_lv,career,{open, to_term}]}
                             end
        }]].
base_login_reward() ->
    [base_login_reward,
     [#generate_conf{
         fun_name = get, 
         record_conf = single, 
         handle_args_fun = fun(#base_login_reward{
                                  day_info = DayInfoStr
                                 }) ->
                                   case bitstring_to_term(DayInfoStr) of
                                       Day when is_integer(Day) ->
                                           lists:concat(["(", Day,") ->\n"]);
                                       {Begin, End} ->
                                           lists:concat(["(Day) when Day >= ", Begin, 
                                                         " andalso Day =< ", End, 
                                                         " ->\n"])
                                   end
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {record, [id, {day_info, to_term}, {reward, to_term}, desc]}
                             end
        }]].

base_mon() ->
    Fields = record_info(fields, ets_base_mon),
    AfterDelFields = del_fields(Fields, [active_skill]), 
    AfterTransRecordFields = trans_to_record(AfterDelFields,
                                             [{mon_drop, common_reward}]),
    LastFields = AfterTransRecordFields,
    [ets_base_mon, base_mon, ["db_base_mon.hrl"],
     [default_get_generate_conf(LastFields, id)]].

base_player() ->
    Fields = record_info(fields, ets_base_player),
    [ets_base_player, base_player, ["db_base_player.hrl"],
     [default_get_generate_conf(Fields, lv)]].

base_protocol() ->
    Fields = record_info(fields, ets_base_protocol),
    LastFields = trans_to_term(Fields, [c2s, s2c]),
    [ets_base_protocol, base_protocol, ["db_base_protocol.hrl"],
     [default_get_generate_conf(LastFields, id)]].

base_rate() ->
    Fields = record_info(fields, base_rate),
    LastFields = trans_to_term(Fields, [key, value]),
    [base_rate,
     [#generate_conf{
         fun_name = get, 
         record_conf = single, 
         handle_args_fun = fun(#base_rate{
                                  key = Key
                                 }) ->
                                   lists:concat(["(", binary_to_list(Key), ") ->\n"])
                           end, 
         handle_result_fun = fun(_RecordData) ->
                                     {single, {value, to_term}}
                             end,
         default = nil
        }]].

base_store_product() ->
    GetGenerateConf = default_get_generate_conf(record_info(fields, base_store_product), id),
    GetByTypeConf = default_more_generate_conf(get_by_type, type, id),
    [base_store_product,
     [GetGenerateConf,
      GetByTypeConf
     ]].


%%-------------------- 内部函数 --------------------

default_get_generate_conf(GetFunFields, Key) ->
    default_get_generate_conf(GetFunFields, Key, []).

default_get_generate_conf(GetFunFields, Key, Default) ->  
    #generate_conf{
       fun_name = get, 
       record_conf = single, 
       handle_args_fun = fun(_RecordData) ->
                                 Key
                         end, 
       handle_result_fun = fun(_RecordData) ->
                                   {record, GetFunFields}
                           end,
       default = Default
      }.

default_all_generate_conf(Key) ->  
    #generate_conf{
       fun_name = all, 
       record_conf = all, 
       handle_args_fun = fun(_RecordData) ->
                                 null
                         end, 
       handle_result_fun = fun(_RecordData) ->
                                   {single, Key}
                           end
      }.
%% FilterKeyInfo can one or more
default_more_generate_conf(FunName, FilterKeyInfo, Id) ->
    #generate_conf{
       fun_name = FunName, 
       record_conf = {more, FilterKeyInfo}, 
       handle_result_fun = fun(_RecordData) ->
                                   {single, Id}
                           end
      }.

%% 加上转term的标志
trans_to_term(Fields, ToTermField) 
  when is_atom(ToTermField) ->
    trans_to_term(Fields, [ToTermField]);
trans_to_term(Fields, ToTermFieldList) ->
    lists:map(fun
                  (Field) when is_atom(Field) ->
                      case lists:member(Field, ToTermFieldList) of
                          true ->
                              {Field, to_term};
                          false ->
                              Field
                      end;
                  (Field) ->
                      Field
              end, Fields).

%% 将一些字段添加上转record标志
trans_to_record(Fields, {ToRecordField, RecordName}) 
  when is_atom(ToRecordField),
       is_atom(RecordName)->
    trans_to_record(Fields, [{ToRecordField, RecordName}]);
trans_to_record(Fields, ToRecordFieldList) ->
    lists:map(fun
                  (Field) when is_atom(Field) ->
                      case lists:keyfind(Field, 1, ToRecordFieldList) of
                          {_, RecordName} ->
                              {Field, to_record, RecordName};
                          false ->
                              Field
                      end;
                  (Field) ->
                      Field
              end, Fields).

%% 去掉一些字段
del_fields(Fields, DelField) 
  when is_atom(DelField)->
    del_fields(Fields, [DelField]);
del_fields(Fields, DelFieldList) ->
    lists:filter(fun
                     (Field) when is_atom(Field) ->
                         not lists:member(Field, DelFieldList);                     
                     (_) ->
                         true 
                 end, Fields).

list_split(L, N) -> 
    list_split0(L, [[] || _ <- lists:seq(1, N)]).

list_split0([], Ls) -> 
    Ls;
list_split0([I | Is], [L | Ls]) -> 
    list_split0(Is, Ls ++ [[I | L]]).


bitstring_to_term(undefined) -> 
    undefined;
bitstring_to_term(BitString) ->
    string_to_term(binary_to_list(BitString)).

string_to_term(String) ->
    case erl_scan:string(String++".") of
        {ok, Tokens, _} ->
            case erl_parse:parse_term(Tokens) of
                {ok, Term} -> 
                    Term;
                Err -> 
                    throw({err_string_to_term, Err})
            end;
        Error ->
            throw({err_string_to_term, Error})
    end.
