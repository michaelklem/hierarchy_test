class AiAccountParent < ApplicationRecord
  self.table_name = "ai_accounts_parents"

  has_many :root_paths, primary_key: 'account_id',  foreign_key: 'account_id', class_name: 'AiAccountParentPath'

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

  def self.get_root_nodes
    sql ="select distinct a.id from ai_accounts_parents ap
    join ai_accounts a on a.id = ap.account_id
    where ap.parent_id is null
    "
    v = self.connection.select_values(sql)   
  end

  def self.calc_hierarchy_from_root( account_id )
    sql = "with recursive cte (id, account_id, parent_id, path) as (
      select    id, account_id,
                parent_id,
                CAST(parent_id AS CHAR(200)) as path
      from       ai_accounts_parents
      where      parent_id = #{account_id}
      union all
      select     p.id, p.account_id,
                p.parent_id,
                  CONCAT(cte.path, \",\", cte.account_id) as path
      from       ai_accounts_parents p
      inner join cte
              on p.parent_id = cte.account_id
    )
    select * from cte;"
    puts "sql: #{sql}"
    v = self.connection.select_all(sql)   
  end

  def calc_path_to_root_old(depth=5)
    sql = "WITH RECURSIVE cte AS
      (
        SELECT account_id, parent_id, 0 as depth,  CAST(account_id AS CHAR(200)) as path_ids FROM ai_accounts_parents 
        WHERE account_id  = #{self.account_id}

        UNION ALL

        SELECT c.account_id, c.parent_id, cte.depth + 1,  CONCAT(cte.path_ids, ",", c.account_id)FROM ai_accounts_parents c 
        JOIN cte ON c.parent_id=cte.account_id --  # find children
        where depth < 20
      )

      SELECT  cte.depth,  cte.path_ids, cte.account_id, cte.parent_id FROM cte
      left join ai_accounts p on p.id = cte.parent_id"

    v = self.connection.select_values(sql)   
  end

end
