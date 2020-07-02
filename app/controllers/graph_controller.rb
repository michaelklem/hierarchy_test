class GraphController < ApplicationController
  def index
    @nodes = AiAccount.all_with_links
    # @nodes = AiAccount.all.pluck(:id, :account_type)
    @edges = AiAccountParent.all
  end

  def node_hierarchy
  end

  def node_hierarchy_data
    @nodes = AiAccount.get_parent_child_nodes( params['node_id'], 4, nil)
    Rails.logger.info "NODES: #{@nodes.to_json}"
    uniq_nodes1 = @nodes.map{|x| x['account_id']}.uniq
    uniq_nodes2 = @nodes.map{|x| x['parent_id']}.uniq
    uniq_nodes = uniq_nodes1 + uniq_nodes2
    @edges = AiAccountParent.where(account_id: uniq_nodes)

    # @nodes = AiAccount.all.pluck(:id, :account_type)

    Rails.logger.info "NODES2: #{@nodes.to_json}"
    Rails.logger.info "EDGES: #{@edges.to_json}"
    Rails.logger.info "uniq_nodes: #{uniq_nodes}"
    render :json => {nodes: @nodes, edges: @edges, uniq_nodes: uniq_nodes, node_ids: uniq_nodes1}
  end
end
