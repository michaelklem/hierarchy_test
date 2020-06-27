class AiAccountParent < ApplicationRecord
  self.table_name = "ai_accounts_parents"

  # belongs_to :account, primary_key: :id, foreign_key: :id, class_name: 'AiAccount'
  # belongs_to :parent, primary_key: :parent_id, foreign_key: :id, class_name: 'AiAccount'
  
end
