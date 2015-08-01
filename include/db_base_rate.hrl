%%%------------------------------------------------	
%%% File    : db_base_rate.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_RATE_HRL).	
-define(DB_BASE_RATE_HRL, true).	
	
%% 	
%% base_rate ==> base_rate 	
-record(base_rate, {	
      id,                                     %% 	
      key,                                    %%  对应活动概率的key	
      value                                   %% [{星级，概率}，...]	
    }).	
	
-endif.	
