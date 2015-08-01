%%%------------------------------------------------	
%%% File    : db_base_player.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_PLAYER_HRL).	
-define(DB_BASE_PLAYER_HRL, true).	
	
%% 	
%% base_player ==> ets_base_player 	
-record(ets_base_player, {	
      lv = 0,                                 %% lv	
      exp_curr = 0,                           %% 当前等级基础经验	
      exp_next = 0,                           %% 升级到下一级所需的经验	
      cost = 0,                               %% 负重值	
      vigor = 0,                              %% 体力值	
      friends = 0,                            %% 基础好友数量上限	
      hp_lim = 0,                             %% 生命上限	
      mana_lim = 0,                           %% 法力上限	
      mana_init = 0,                          %% 魔法初始值	
      hp_rec = 0,                             %% 生命回复力	
      mana_rec = 0,                           %% 魔法回复力	
      water = 0,                              %% 水元素	
      fire = 0,                               %% 火元素	
      wood = 0,                               %% 木元素	
      honly = 0,                              %% 光元素	
      dark = 0,                               %% 暗元素	
      attack = 0,                             %% 初始攻击值	
      def = 0                                 %% 初始防御值	
    }).	
	
-endif.	
