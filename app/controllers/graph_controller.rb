class GraphController < ApplicationController
  # Find all nodes to a specific depth for a specific root
  def index3
      @edges = AiAccount.get_parent_child_nodes3( '22897', 7 )

      # get unique node ids
      account_ids = @edges.map{|x| x['account_id']}
      parent_ids = @edges.map{|x| x['parent_id']}
      node_ids = (account_ids + parent_ids).uniq.compact
      @nodes = AiAccount.links_for_nodes(node_ids.join(','))
      # @edges = AiAccountParent.all
      
      # n = AiAccount.first
      # @nodes = [[n.id, n.account_type]]
      # @node_ids = []
      # @nodes.map{|x| @node_ids << x[0]}

      # @node_ids = [[22897]]


      
      Rails.logger.info "DONE!"
    end
    
    def index
    @nodes = AiAccount.all_with_links
    @edges = AiAccountParent.all
    


    # @edges = AiAccount.get_parent_child_nodes2( @node_ids.join(',') )
    # @edges = AiAccount.get_parent_child_nodes2( '22897', 2 )
    
    Rails.logger.info "DONE!"
  end

  def node_hierarchy
    @node_id = params[:node_id]
  end

  def node_hierarchy_data
    @nodes = AiAccount.get_parent_child_nodes( params['node_id'], 2, nil)
    # @nodes = AiAccount.get_child_nodes( params['node_id'], 1, nil)
    # Rails.logger.info "NODES: #{@nodes.to_json}"
    uniq_nodes1 = @nodes.map{|x| x['account_id']}.uniq
    uniq_nodes2 = @nodes.map{|x| x['parent_id']}.uniq
    uniq_nodes = uniq_nodes1 + uniq_nodes2
    @edges = AiAccountParent.where(account_id: uniq_nodes)

    # @nodes = AiAccount.all.pluck(:id, :account_type)

    # Rails.logger.info "NODES2: #{@nodes.to_json}"
    # Rails.logger.info "EDGES: #{@edges.to_json}"
    # Rails.logger.info "uniq_nodes: #{uniq_nodes}"
    render :json => {nodes: @nodes, edges: @edges, uniq_nodes: uniq_nodes, node_ids: uniq_nodes1}
  end
end
