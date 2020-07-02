class AiAccountParent < ApplicationRecord
  self.table_name = "ai_accounts_parents"

  # belongs_to :account, primary_key: :id, foreign_key: :id, class_name: 'AiAccount'
  # belongs_to :parent, primary_key: :parent_id, foreign_key: :id, class_name: 'AiAccount'
  def self.get_root_nodes
    sql = "select a.id from ai_accounts a 
	     	      join ai_accounts_parents aap2 on aap2.parent_id = a.id

	     where a.id not in
	     (
	     select distinct aap.parent_id from  ai_accounts_parents aap 
	      join ai_accounts_parents aap2 on aap2.account_id = aap.parent_id
	      )"
    v = self.connection.select_values(sql)   
  end
end
