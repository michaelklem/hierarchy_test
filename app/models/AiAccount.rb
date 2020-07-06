class AiAccount < ApplicationRecord
  has_many :parents, primary_key: 'id',  foreign_key: 'parent_id', class_name: 'AiAccountParent'
  has_many :children, primary_key: 'id',  foreign_key: 'account_id', class_name: 'AiAccountParent'

  def self.links_for_nodes(node_ids)
    sql = "select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap2 on aap2.account_id = a.id
       where a.id in (#{node_ids})
       "
    
    # My hierachy generator currently does not insert all root nodes
    # in the ai_accounts_parents table so I use this query logic to 
    # find all nodes. Basically if the account id exists in either 
    # column, it is a node that should be displayed. Some nodes
    # are generated as orphans so we want to exclude those. 
    sql5 = "
	select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap on aap.parent_id = a.id
	union
	select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap2 on aap2.account_id = a.id
	    "

    sql4 = "select distinct a.id, a.account_type from ai_accounts a
	    left join ai_accounts_parents aap on aap.parent_id = a.id
	    left join ai_accounts_parents aap2 on aap2.account_id = a.id
      "
    sql3 = "select distinct a.id, a.account_type from ai_accounts a
	    join ai_accounts_parents aap on aap.parent_id = a.id"

    sql2 = "SELECT
	 a2.id, a2.account_type
FROM
	classicmodels.ai_accounts_parents a1
	join ai_accounts a2 on a2.id = a1.parent_id"
    v = self.connection.select_rows(sql)
    v
  end


  def self.all_with_links
    sql = "select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap2 on aap2.account_id = a.id"
    
    # My hierachy generator currently does not insert all root nodes
    # in the ai_accounts_parents table so I use this query logic to 
    # find all nodes. Basically if the account id exists in either 
    # column, it is a node that should be displayed. Some nodes
    # are generated as orphans so we want to exclude those. 
    sql5 = "
	select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap on aap.parent_id = a.id
	union
	select distinct a.id, a.account_type from ai_accounts a
	     join ai_accounts_parents aap2 on aap2.account_id = a.id
	    "

    sql4 = "select distinct a.id, a.account_type from ai_accounts a
	    left join ai_accounts_parents aap on aap.parent_id = a.id
	    left join ai_accounts_parents aap2 on aap2.account_id = a.id
      "
    sql3 = "select distinct a.id, a.account_type from ai_accounts a
	    join ai_accounts_parents aap on aap.parent_id = a.id"

    sql2 = "SELECT
	 a2.id, a2.account_type
FROM
	classicmodels.ai_accounts_parents a1
	join ai_accounts a2 on a2.id = a1.parent_id"
    v = self.connection.select_rows(sql)
    v
  end

  def self.get_child_nodes(node_id, depth = 5, type = nil)
    parent_depth = -depth # need a negative value for parents

    sql = "

    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, 0 as depth FROM ai_accounts_parents 
      WHERE parent_id = #{node_id}

      UNION ALL

      SELECT c.account_id, c.parent_id,cte.depth + 1 FROM ai_accounts_parents c 
      JOIN cte ON cte.account_id=c.parent_id
        where depth < #{depth}
    )

    SELECT  depth, cte.account_id, cte.parent_id, a.account_type FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    "


    Rails.logger.info "FFFFF #{sql}"
    v = self.connection.select_all(sql)
  end


  def self.get_parent_child_nodes(node_id, depth = 5, type = nil)
    parent_depth = -depth # need a negative value for parents

    sql = "
    select * from (
    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, -1 as depth, CAST(account_id AS CHAR(200)) as path FROM ai_accounts_parents 
      WHERE account_id  = #{node_id}
      UNION ALL
      SELECT c.account_id, c.parent_id, cte.depth - 1, CONCAT(cte.path, \",\", c.account_id) FROM ai_accounts_parents c 
      JOIN cte ON c.account_id=cte.parent_id
      where depth > -#{depth}
    )
    SELECT  depth, cte.account_id, cte.parent_id, a.account_type, cte.path FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )a

    union all


    select * from (



    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, 0 as depth, CAST(account_id AS CHAR(200)) as path FROM ai_accounts_parents 
      WHERE parent_id = #{node_id}

      UNION ALL

      SELECT c.account_id, c.parent_id,cte.depth + 1, CONCAT(cte.path,\",\", c.account_id) FROM ai_accounts_parents c 
      JOIN cte ON cte.account_id=c.parent_id
        where depth < #{depth}
    )

    SELECT  depth, cte.account_id, cte.parent_id, a.account_type, cte.path FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )b"


    Rails.logger.info "FFFFF #{sql}"
    v = self.connection.select_all(sql)
  end


  def self.get_parent_child_nodes2(node_ids, depth = 1, type = nil)
    parent_depth = -depth # need a negative value for parents

    sql = "
    select * from (
    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, -1 as depth, CAST(account_id AS CHAR(200)) as path FROM ai_accounts_parents 
      WHERE account_id  in (#{node_ids})
      UNION ALL
      SELECT c.account_id, c.parent_id, cte.depth - 1, CONCAT(cte.path, \",\", c.account_id) FROM ai_accounts_parents c 
      JOIN cte ON c.account_id=cte.parent_id
      where depth > -#{depth}
    )
    SELECT  depth, cte.account_id, cte.parent_id, a.account_type, cte.path FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )a

    union all


    select * from (



    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, 0 as depth, CAST(account_id AS CHAR(200)) as path FROM ai_accounts_parents 
      WHERE parent_id in (#{node_ids})

      UNION ALL

      SELECT c.account_id, c.parent_id,cte.depth + 1, CONCAT(cte.path,\",\", c.account_id) FROM ai_accounts_parents c 
      JOIN cte ON cte.account_id=c.parent_id
        where depth < #{depth}
    )

    SELECT  depth, cte.account_id, cte.parent_id, a.account_type, cte.path FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )b"


    Rails.logger.info "FFFFF #{sql}"
    v = self.connection.select_all(sql)
  end

 def self.get_parent_child_nodes3(node_ids, depth = 1, type = nil)
    parent_depth = -depth # need a negative value for parents

    sql = "
    select * from (
    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, -1 as depth FROM ai_accounts_parents 
      WHERE account_id  in (#{node_ids})
      UNION ALL
      SELECT c.account_id, c.parent_id, cte.depth - 1 FROM ai_accounts_parents c 
      JOIN cte ON c.account_id=cte.parent_id
      where depth > -#{depth}
    )
    SELECT  depth, cte.account_id, cte.parent_id, a.account_type FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )a

    union all


    select * from (



    WITH RECURSIVE cte AS
    (
      SELECT account_id, parent_id, 0 as depth FROM ai_accounts_parents 
      WHERE parent_id in (#{node_ids})

      UNION ALL

      SELECT c.account_id, c.parent_id,cte.depth + 1 FROM ai_accounts_parents c 
      JOIN cte ON cte.account_id=c.parent_id
        where depth < #{depth}
    )

    SELECT  depth, cte.account_id, cte.parent_id, a.account_type FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )b"


    Rails.logger.info "FFFFF #{sql}"
    v = self.connection.select_all(sql)
  end
end
