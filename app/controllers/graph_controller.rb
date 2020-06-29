class GraphController < ApplicationController
  def index
    @nodes = AiAccount.all.pluck(:id, :account_type)
    @edges = AiAccountParent.all
  end
end
