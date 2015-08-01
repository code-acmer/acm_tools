%%%------------------------------------------------	
%%% File    : db_base_params.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_PARAMS_HRL).	
-define(DB_BASE_PARAMS_HRL, true).	
	
%% 	
%% base_params ==> base_params 	
-record(base_params, {	
      id,                                     %% 参数ID	
      name = "",                              %% 参数名	
      value,                                  %% 参数值	
      desc                                    %% 描述	
    }).	
	
-endif.	
