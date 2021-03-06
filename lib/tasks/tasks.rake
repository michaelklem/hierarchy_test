# bundle exec rake generate_accounts
task generate_accounts: :environment do
  rows_to_generate = 20
  rows_to_generate.times do |i|
    generate_nodes(i, 2, 10)
  end

end

def generate_nodes(level, min, max)
  number_to_generate = rand(min..max)
  puts "generating #{number_to_generate} nodes at level #{level}"
  number_to_generate.times do |i|
    AiAccount.create( name: generate_name, level: level, account_type: rand(1..10) )
  end
end

def generate_name
  Faker::Alphanumeric.alpha(number: 10)
end


# bundle exec rake generate_account_relationships
task generate_account_relationships: :environment do 
  rows_to_generate = 12
  (rows_to_generate-1).times do |i|
    generate_links(i, i+1)
  end

  add_nodes_as_roots
end

# bundle exec rake generate_root_paths
task generate_root_paths: :environment do 
  nodes = AiAccountParent.get_root_nodes
  puts "#{nodes.to_json}"
  # puts "#{nodes[0]}"
  nodes.each do |n|
    results = AiAccountParent.calc_hierarchy_from_root( n )
    results.each do |r|
      puts "#{r['id']}, #{r['account_id']}, #{r['parent_id']}, #{r['path']}"
      # a = AiAccountParent.find( r['id'] )
      b = AiAccountParentPath.create( account_id: r['account_id'], root_path: r['path'] )
      # a.root_path = r['path'] 
      # a.save 
    end
  end
end

# We need to go through each node, and add a new row in the parents table
# to indicate the row is a parent.
# Basically, each parent node id should also be found in the table in the account id column with a null parent id.
def add_nodes_as_roots
  puts "in add nodes as roots"
  nodes = AiAccountParent.get_root_nodes
  nodes.each do |id|
    begin
      AiAccountParent.create(account_id: id, parent_id: nil)
    rescue 
    end
  end
end

def generate_links(parent_level, child_level)
  parent_nodes = get_records_at_level(parent_level)
  child_nodes = get_records_at_level(child_level)
  puts "p #{parent_nodes.count} nodes at level: #{parent_level}"
  puts "c #{child_nodes.count} nodes at level: #{child_level}"

  if parent_level == 0
    generate_root_links(parent_nodes, child_nodes)
  else
    generate_non_root_links(parent_nodes, child_nodes)
  end
end

# iterate thru child node and assign each to a random parent
# then iterate thru each parent to assign them to a random child if they have no association yet
def generate_root_links(p, c)
  number_of_p = p.count
  number_of_c = c.count

  puts "  root links p #{number_of_p}"
  puts "  root links c #{number_of_c}"


  c.each do |child|
    rando_index = rand(0..(number_of_p-1))
    random_p = p[ rando_index  ]
    puts "link from child #{child.id} to parent #{random_p.id}"
    begin
      AiAccountParent.create(account_id: child.id, parent_id: random_p.id)
    rescue
    end
  end

  # Add the parent nodes to the ai_account_parent table with null parent
  p.each do |parent|
    puts "link from parent #{parent.id} to null"
    begin
      AiAccountParent.create(account_id: parent.id, parent_id: nil)
    rescue
    end
  end

  p.each do |parent|
    rando_index = rand(0..(number_of_c-1))
    random_c = c[ rando_index ]
    puts "link from parent 2: #{parent.id} to child #{random_c.id}"
    begin
      AiAccountParent.create(account_id: random_c.id, parent_id: parent.id)
    rescue
    end
 
     begin
      AiAccountParent.create(account_id: parent.id, parent_id: nil)
    rescue
    end

  end

end

def generate_non_root_links(p, c)
  number_of_p = p.count
  number_of_c = c.count

  # make 1/3 of the parent accounts NOT to have any links so they become leaves in the tree
  number_of_p_leaves = (number_of_p * 0.3).ceil 
  p_as_leaves = []
  #  pick number_of_p_leaves for becoming leaves
  number_of_p_leaves.times do 
    rando_index = rand(0..(number_of_p-1))
    p_as_leaves << p[ rando_index ]
  end

  puts "  root links p #{number_of_p}"
  puts "  root links c #{number_of_c}"

  c.each do |child|
    rando_index = rand(0..(number_of_p-1))

    random_p = p[ rando_index  ]
    next if p_as_leaves.include? random_p
    puts "link from child #{child.id} to parent #{random_p.id}"
    begin
      AiAccountParent.create(account_id: child.id, parent_id: random_p.id)
    rescue
    end
  end

  p.each do |parent|
    next if p_as_leaves.include? parent
    rando_index = rand(0..(number_of_c-1))
    random_c = c[ rando_index ]
    puts "link from parent 3: #{parent.id} to child #{random_c.id}"
    begin
      AiAccountParent.create(account_id: random_c.id, parent_id: parent.id)
    rescue
    end

    begin
      AiAccountParent.create(account_id: parent.id, parent_id: nil)
    rescue
    end
  end

end

def get_records_at_level(level)
  AiAccount.where(level: level)
end