class AiAccount < ApplicationRecord
  has_many :parents, primary_key: 'id',  foreign_key: 'parent_id', class_name: 'AiAccountParent'
  has_many :children, primary_key: 'id',  foreign_key: 'account_id', class_name: 'AiAccountParent'


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
      where depth > -3
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
        where depth < 3
    )

    SELECT  depth, cte.account_id, cte.parent_id, a.account_type, cte.path FROM cte
    join ai_accounts a on a.id = cte.account_id
    left join ai_accounts p on p.id = cte.parent_id

    )b"


    Rails.logger.info "FFFFF #{sql}"
    v = self.connection.select_all(sql)
  end
end
