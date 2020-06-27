class AiAccount < ApplicationRecord
  has_many :parents, primary_key: 'id',  foreign_key: 'parent_id', class_name: 'AiAccountParent'
  has_many :children, primary_key: 'id',  foreign_key: 'account_id', class_name: 'AiAccountParent'
end
