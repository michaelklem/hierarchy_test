Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  root to: 'graph#index'
  get "node/:node_id", to: 'graph#node_hierarchy'
  get "node_data/:node_id", to: 'graph#node_hierarchy_data'

end
