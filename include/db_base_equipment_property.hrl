%%%------------------------------------------------	
%%% File    : db_base_equipment_property.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_EQUIPMENT_PROPERTY_HRL).	
-define(DB_BASE_EQUIPMENT_PROPERTY_HRL, true).	
	
%% 	
%% base_equipment_property ==> ets_base_equipment_property 	
-record(ets_base_equipment_property, {	
      id,                                     %% 唯一id	
      hp = 0,                                 %% 血量	
      attack = 0,                             %% 攻击力	
      def = 0,                                %% 防御力	
      hp_up = 0,                              %% 血量成长	
      attack_up = 0,                          %% 攻击成长	
      def_up = 0,                             %% 防御成长	
      exp = 0,                                %% 经验	
      exp_ab = 0,                             %% 被吸收时的经验系数（10000为基数）	
      memo                                    %% 	
    }).	
	
-endif.	
