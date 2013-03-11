namespace :db do
  desc 'Create YAML test fixtures from data in an existing database.  
  Defaults to development database. Set Rails.env to override.'

  task :extract_fixtures => :environment do
    sql = 
    
    if ENV['IDS'] 
      sql = "SELECT * FROM %s WHERE id IN (#{ENV['IDS']})"  
    elsif ENV['WHERE']
      sql = "SELECT * FROM %s WHERE #{ENV['WHERE']}"  
    else
      sql = "SELECT * FROM %s"
    end
    
    skip_tables = ["schema_info", "sessions"]
    ActiveRecord::Base.establish_connection
    tables = ENV['FIXTURES'] ? ENV['FIXTURES'].split(/,/) : ActiveRecord::Base.connection.tables - skip_tables
    tables.each do |table_name|
      i = "000"
      File.open("#{Rails.root}/db/#{table_name}.yml", 'w') do |file|
        data = ActiveRecord::Base.connection.select_all(sql % table_name)
        file.write data.inject({}) { |hash, record|
          hash["#{table_name}_#{i.succ!}"] = record
          hash
        }.to_yaml
      end
    end
  end
end