%%%------------------------------------------------	
%%% File    : db_base_sys_acm.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_SYS_ACM_HRL).	
-define(DB_BASE_SYS_ACM_HRL, true).	
	
%% 	
%% base_sys_acm ==> ets_base_sys_acm 	
-record(ets_base_sys_acm, {	
      id = 0,                                 %% 系统公告id	
      type = 0,                               %% 系统公告类型	
      trigger_1 = 0,                          %% 触发器1	
      trigger_2 = 0,                          %% 触发器1	
      trigger_3 = 0,                          %% 触发器1	
      trigger_4 = 0,                          %% 触发器1	
      trigger_5 = 0,                          %% 触发器1	
      sys_acm = ""                            %% 系统公告内容%name%,%rank%...	
    }).	
	
-endif.	
