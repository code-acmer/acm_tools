%%%------------------------------------------------	
%%% File    : db_base_store_product.hrl	
%%% Description: 从mysql表生成的record	
%%% Warning:  由程序自动生成，请不要随意修改！	
%%%------------------------------------------------    	
	
-ifndef(DB_BASE_STORE_PRODUCT_HRL).	
-define(DB_BASE_STORE_PRODUCT_HRL, true).	
	
%% 	
%% base_store_product ==> base_store_product 	
-record(base_store_product, {	
      id,                                     %% 	
      product_id,                             %% app store配置的product_id，Android不用填	
      gold,                                   %% 充值获得的金钱	
      money,                                  %% 所需要的人民币	
      icon,                                   %% 	
      type                                    %% 渠道类型1是android 2是App免费 3是App收费	
    }).	
	
-endif.	
