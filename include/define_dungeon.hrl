-ifndef(DEFINE_DUNGEON_HRL).
-define(DEFINE_DUNGEON_HRL,true).

%-include("define_goods.hrl").
%-include("db_base_dungeon.hrl").
%-include("db_player_dungeon.hrl").

%%%------------------------------------------------
%%% File    : common.hrl
%%% Created : 2010-09-15
%%% Description: 公共定义
%%%------------------------------------------------

%% -define(MON_ID_BEGIN, 1).

%% 基础_副本信息
-define(ETS_BASE_DUNGEON, ets_base_dungeon).
-define(ETS_PLAYER_DUMGEON, player_dungeon).

%% 定义副本类型
-define(SINGLE_DUNGEON, 1). %% 单人副本
-define(SINGLE_ELITE_DUNGEON, 2).   %% 精英副本
-define(GUARD_DUNGEON, 3).  %% 守关副本

%% 定义杀怪场所
-define(SINGLE_DUNGEON_KILL_MON, 100).
-define(DEVIL_TOWER_KILL_MON, 200).

%% 刷新精英副本最小等级
-define(MIN_VIP_LV_REFRESH_ELITE, 3).

%% 副本最大次数
-define(MAX_GUARD_TIMES, 2).

%% 秒死亡cd所需元宝
-define(GOLD_FOR_DEAD, 2).

%% 秒战斗cd所需元宝
-define(GOLD_FOR_BATTLE, 2).

%% 副本调试宏
-define(GUARD_DEBUG(Msg, Args), 
        %%logger:error_msg(?MODULE,?LINE,"###### 35000:" ++ Msg ++ "=~w~n", Args)
        logger:debug_msg(?MODULE,?LINE,"###### 35000:" ++ Msg ++ "=~w~n", Args)
        ).

%%玩家副本信息 
-record(player_dungeon_now,
        {
          dungeon_unique_id = 0,                  %% 副本唯一id
          dungeon_type      = 1,                  %% 默认为普通单人FB
          dungeon_id = 0,                         %% 场景原始id
          dungeon_reward,                         %% 副本奖励
          dungeon_need_ps   = 5,                  %% 副本需要体力
          all_mons ,    
          out,
          series_id=0,
          ser_order=0,
          ser_scene=0,
          dungeon_evaluate = [],                  %% 副本评价列表
          dungeon_progress = 0                    %%  暂时定为一进入就变为1，然后一杀怪就变+2。
        }). 

%%副本怪物记录
-record(all_mons, {sum,dungeon_mons}).

%%副本进程里面用到的怪物信息记录  {AutoId,MonId,X,Y,MonPid}
-record(mon,
        {
          auto_id,              %%唯一id
          mon_id,               %%怪物类型id
          name,                 %%怪物名称
          x,                        %%配置怪物时候的x
          y,                        %%配置怪物时候的y
          hp,
          hp_lim,
          mp,
          mp_lim,
          lv,
          icon,
          type,
          att_area,
          exp,
          spirit,
          is_pass = false       %%是否可以跳过战斗动画。记得是true或者false
        }).

%%玩家的副本信息
-record(player_dungeon_info,{
                             dungeon_id,        %%副本id
                             evaluate,          %%副本评价
                             enable = 0,        %%是否解锁
                             dungeon_progress   %%副本进度，对应应该触发的剧情
                            }). 

%%副本奖励记录
-record(dungeon_reward,{
                        fixed = [],     %%固定奖励项
                        possible = []   %%随机奖励项
                        }).

%% %%副本奖励的每一项
%% -record(reward_item,{
%%           id     = 0,    %%奖励编号
%%           goods_id   = 3,    %%奖励种类，1为元宝，3为铜钱，6龙魄 ... 80+为普通物品
%%           num        = 100,  %%奖励数目
%%           bind       = ?GOODS_BOUND,     %%奖励的物品id
%%           value1 = 0, %%普通类型0,特殊类型1
%%           value2 = 0   %%第几天
%%          }).

%% 守关副本相关定义

%% 定义守关副本定时器相关常量
%% 使用tick是为了避免某种情况，浪费资源，比如1500ms的一个事件和一个1550ms的事件。不用tick的话就要send两次，用500ms的tick只需统一在一个tick里面操作。并不需要ms级的精确度。
-define(GUARD_TICK_TIME, 1000).             %% 1000毫秒的精确度
-define(MON_BORN_WARN_TICK, 10).            %% 怪物出生前10秒警告
-define(GUARD_START_TICK, 10).              %% 副本10秒后开始

-define(STEP_LENGTH, 2).
-define(GUARD_MOVE_TURNING_POINT, 10).

-define(GUARD_BOSS_MOVE_INTERVAL, 8).                           %% 5秒
-define(GUARD_MON_MOVE_INTERVAL, 6).                            

-define(REMOVE_MON_TICK, 1).            %% 碰到npc，1秒后移除怪

-define(SUCCESS_TICK, 1).               %% 一秒后开始清算胜利奖励

-define(NORMAL_HARM, 1).
-define(BOSS_HARM, 4).

-define(GUARD_REVIVE_TICK, 30).         %% 复活时间30秒
-define(GUARD_REVIVE_SECONDS, 30).      %% 复活时间20秒
-define(MON_BATTLE_TICK, 5).            %% 怪物战斗状态持续时间，5秒
-define(MON_BATTLE_SECONDS, 5).

-define(GUARD_PRO_OVER_TICK, 15).   %% 结束守关进程tick数
-define(SEND_OUT_TICK, 10).         %% 将队员传送出去
%% 守关副本gen_server进程的state
-record(guard_npc, {
                    id=0,
                    nid=0,
                    x=0,
                    y=0,
                    name,
                    hp=0,
                    hp_lim=0
                   }).
-record(guard_mon_active, {
                           wave_order=0,
                           unique_key,
                           name=[],
                           mid,
                           x,
                           y,
                           mon_group_hp,
                           exp,
                           experience,
                           type,                            %% 0是普通怪，1是boss
                           road,                            %% 在第几路：1、2、3三条路
                           status,                          %% 0、正常，1、战斗中，2、正在伤害NPC
                           cd_state={0,0}                   %% 两个数据用于获取剩余cd时间。
                          }).           

-record(guard_member,{
                      id,
                      name,
                      sex,
                      career,
                      lv,
                      pid,
                      pid_send,
                      status=0,             %% state，0、正常，2、战斗中，3、死亡。
                      cd_state={0,0},       %% 两个数据用于获取剩余cd时间。前者是开始时间，后者是cd总时间
                      is_online=0,          %% is_online，1、在线，0、离线
                      kill_count=0,         %% 杀怪数统计
                      bat_reports=[],       %% 战报累积
                      total_harm=0
                     }).    

-record(guard_income,{
                      wave_order=0,
                      exp=0,
                      experience=0
                     }).

-record(guard_dungeon_state,{
                             team_id,
                             dungeon_id,
                             name,                          %% 副本名字
                             dungeon_unique_id,
                             npc=#guard_npc{},
                             player_born_point={0,0},
                             mon_born_points=[],                %% 怪物出生点，顺序由列表中的顺序表示
                             ative_mons=[],
                             mons_count=0,
                             team_members=[],
                             income=[],
                             timer_ref,
                             tick_timers=[],                %% 此字段用于标记各timer事件的tick
                             auto_id=0,                     %% 字段用于产生自增唯一id，可用在进程字典中的timer事件的唯一键（对应于tiemr_ticks，每一个tick一个键），也可用在其它地方，用完自增1，在此进程中应该不会有多大的数字，所以不做上限检查
                             guard_reward=[[],[]],          %% 守关副本的奖励，前者固定奖励，后者随机奖励
                             out=[100,20,20],
                             total_time=0,                  %% 副本总时间
                             wave_order=0,                  %% 当前波数
                             total_wave=0,                  %% 总波数
                             status=0                       %% 副本状态，0：正常，1、结束
                             }).

-record(data_dungeon,{
                     id,                          %% 关卡id
                     name,                        %% 关卡名称
                     dungeon_type,                %% 1-主线副本 2-活动副本
                     type,                        %% 1-副本2-关卡(目前不区分，所以类型为0)
                     series_id,                   %% 所属副本系列的id
                     series_name,                 %% 所属副本系列的名字
                     desc,                        %% 关卡描述
                     sessions,                    %% 分场数（用于客户端显示）
                     session_pos,                 %% 分场坐标
                     req_pre_id,                  %% 配置前置关卡ID，当前置的关卡没有成功通关时，该关卡不会在界面显示。
                     req_time,                    %% 时间需求
                     max_times,                   %% 判定玩家ID是否已经进入过某副本退出后。副本关闭，不再开启。
                     req_vigor,                   %% 消耗体力值
                     req_cost_max,                %% 某些副本针对玩家身上每个单件装备的COST的值最高限制。促使玩家去收集相应装备。
                     req_cost_min,                %% 某些副本针对玩家身上每个单件装备的COST的值的最小值。促使玩家去收集相应装备。
                     req_quality_max,             %% 某些副本针对玩家身上每个单件装备的品质（星级）最高品质限制。促使玩家去收集相应装备。
                     req_quality_min,             %% 某些副本针对玩家身上每个单件装备的品质（星级）最低品质限制。促使玩家去收集相应装备。
                     goal,                        %% 副本总时间
                     reward,                      %% 当前波数
                     extra_goal,                  %% 总波数
                     extra_reward,                %% 加成奖励配置同“基本奖励”配置方法。可配置多项。
                     special_reward,              %% 首次通关，奖励充值货币。之后再次通关不再奖励。
                     icon,                        %% 首次通关，奖励充值货币。之后再次通关不再奖励。
                     map_id,                      %% 副本资源id，从base_scene_map获取
                     tilemap_id,                  %% tilemap_id，用于载入对应的tilemap信息
                     monsters                     %% 可掉落的怪物信息，用于服务器的物品掉落计算，格式[id1,id2,id3]
                     }).


-record(dungeon_rewards,{
                         rewards          = [],
                         extra_rewards    = [],
                         monsters_rewards = [],
                         special_reward   = []
                        }).

-define(DUNGEON_MASTER, 1).     %% 主线副本
-define(DUNGEON_ACTIVITY, 2).   %% 活动副本
-define(DUNGEON_SPECIAL, 3).    %% 关卡副本
%% 守关副本gen_server进程的state

%% FB输出
-define(DEBUG_DUN(Format, Args), 
        ?DEBUG("DEBUG_DUN==>> " ++ Format, Args)).

-define(PHYSICAL_STRENGTH_EVERYTIME,  5).
-define(DUNGEON_ID_INTERVAL,          100).
-define(IF_OPENDUNGEON,               1).
-define(DUNGEON_SCENE_BASE,           100000000).
-define(DUNGEON_DAY,                  1).
-define(DUNGEON_DATE,                 2).
-define(DUNGEON_TIME,                 3).
-define(DUNGEON_WEEK,                 4).
-define(DUNGEON_NOT_EXTRA_WREARD,     0).
-define(DUNGEON_IS_EXTRA_WREARD,      1).
-define(DUNGEON_PASS,                 1).
-define(DUNGEON_NOT_PASS,             0).


-endif.

