%%%------------------------------------------------	
%%% File    : db_base_combat_skill.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_COMBAT_SKILL_HRL).	
-define(DB_BASE_COMBAT_SKILL_HRL, true).	
	
%% 	
%% base_combat_skill ==> base_combat_skill 	
-record(base_combat_skill, {	
      id = 0,                                 %% 主动技能ID 唯一ID值	
      unique_id = 0,                          %% 唯一技能id	
      lv = 1,                                 %% 等级	
      max_lv = 10,                            %% 最大等级	
      name = "",                              %% 	
      desc,                                   %% 技能描述	
      icon = 0,                               %% 图标id	
      bc = 0,                                 %% 战斗值消耗	
      sp = 0,                                 %% 能量值消耗	
      cd = 300000,                            %% 技能冷却时间	
      value,                                  %% {目标，类型，值1，值2}目标：1自己、2敌人类型：1一般伤害、2固定伤害、3BUFF效果、4吸血值1：1伤害比例、2固定伤害比例、3BUFFid、4吸血百分比值2：1伤害固定值、2固定伤害固定值、3（0）、4吸血固定值	
      att_distance = 0,                       %% 攻击距离时间(s)，速度(帧)	
      att_range = 0,                          %% 攻击范围起始X坐标，起始Y坐标#结束X坐标，结束Y坐标	
      action = 0,                             %% 动作资源(8位id)	
      att_freeze,                             %% 攻击硬直（ms）	
      be_att_freeze = 0,                      %% 受击硬直(ms)	
      off_X = 0,                              %% 击退距离（像素）	
      off_Y = 0,                              %% 浮空高度（像素）	
      chant_time = 0                          %% 吟唱时间(ms)	
    }).	
	
-endif.	
