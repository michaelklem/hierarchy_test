# bundle exec rake generate_accounts
task generate_accounts: :environment do
  rows_to_generate = 5
  rows_to_generate.times do |i|
    generate_nodes(i, 2, 6)
  end

end

def generate_nodes(level, min, max)
  number_to_generate = rand(min..max)
  puts "generating #{number_to_generate} nodes at level #{level}"
  number_to_generate.times do |i|
    AiAccount.create( name: generate_name, level: level )
  end
end

def generate_name
  Faker::Alphanumeric.alpha(number: 10)
end


# bundle exec rake generate_account_relationships
task generate_account_relationships: :environment do 
  rows_to_generate = 5
  (rows_to_generate-1).times do |i|
    generate_links(i, i+1)
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

  p.each do |parent|
    rando_index = rand(0..(number_of_c-1))
    random_c = c[ rando_index ]
    puts "link from parent #{parent.id} to child #{random_c.id}"
    begin
      AiAccountParent.create(account_id: random_c.id, parent_id: parent.id)
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
    puts "link from parent #{parent.id} to child #{random_c.id}"
    begin
      AiAccountParent.create(account_id: random_c.id, parent_id: parent.id)
    rescue
    end
  end

end

def get_records_at_level(level)
  AiAccount.where(level: level)
end