class GraphController < ApplicationController
  def index
    @nodes = AiAccount.all.pluck(:id)
    @edges = AiAccountParent.all
  end
end
