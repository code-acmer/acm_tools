%%%------------------------------------------------	
%%% File    : db_base_combat_skill_upgrade.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_COMBAT_SKILL_UPGRADE_HRL).	
-define(DB_BASE_COMBAT_SKILL_UPGRADE_HRL, true).	
	
%% 	
%% base_combat_skill_upgrade ==> base_combat_skill_upgrade 	
-record(base_combat_skill_upgrade, {	
      id,                                     %% 技能id	
      next_id = 0,                            %% 升级后的技能id	
      req_lv = 0,                             %% 等级需求	
      req_coin = 0,                           %% 金钱需求	
      req_gold = 0                            %% 元宝消耗	
    }).	
	
-endif.	
