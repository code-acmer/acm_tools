%%%------------------------------------------------	
%%% File    : db_base_login_reward.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_LOGIN_REWARD_HRL).	
-define(DB_BASE_LOGIN_REWARD_HRL, true).	
	
%% 	
%% base_login_reward ==> base_login_reward 	
-record(base_login_reward, {	
      id,                                     %% 	
      day_info = <<"1">>,                     %% 哪些天, eg: 1 or {begin, end} 	
      reward = [],                            %% 奖励	
      desc = <<"""">>                         %% 描述	
    }).	
	
-endif.	
