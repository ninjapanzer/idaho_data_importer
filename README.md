Idaho Data Import Tools
-----------------------
[![Code Climate](https://codeclimate.com/repos/528a92aac7f3a33c120b0eba/badges/7ffce90cc152a530f8e7/gpa.png)](https://codeclimate.com/repos/528a92aac7f3a33c120b0eba/feed)

This is a prototype for processing and joining arbitrary numbers of structured text files.

#### Use this when you…

- have TSV, CSV, or a mix of files
- have common columns within files you would like to join on
- what a standard object to relate to those mixed structured text files
- want to move those structured files to a sql interface
- want to store tables and rows in Redis

#### Available Tools

- **DataTables** - Inspired from the datatable class within the CSV module. It keeps track of headers and rows while providing an in memore or Redis storage option for access.
  - Redis support allows for items in the same redis store to be interfaced between applications using a hash idenfitifer
  - In memory support is for testing and situations when redis is not available
  - While redis does not support types this class with maintain numerics when loading
- **Reader** - Is a catchall for reading structured text files. Capable of idenfitying file encoding on linux even if Ruby missidentifies the file encoding. (often the case when data is obtained from Micro$oft environments)
  - This class can also identify the structure of text data when reading mixed data
- **StrictTSV** - Implements a stand alone reader for the tab seperated format and returns a DataTable object
- **StrictCSV** - Wrapped the defactor CSV module to return a DataTable Object
- **Joiner** - Implements key joins on sets of data.
  - This class organizes object that contain the shared key and then merges them based on matching keys
  - Supports a standalone in memory join that does not retain duplicate relations when merging and sql integration with Postgres and SQLite3 that supports traditional joins which will auto alias duplicates.
  - SQLite3 support is in memory
  - Postgres uses a configuration hash and is persisted between runs


#### Use

Checkout the driver.rb to see a sample application that uses redis and sqlite3 to read and join data. These files are output so you can check them out.

General features should be implemented in this order

    
    #Datatable configuration
    DataTable.config do |c|
      c.redis = true
      c.redis_port = 6381
      #c.flushall #Intermediate table records in redis expire by themselves. The results of a merge do not so use this during testing
    end

    redis = Redis.new(:port => 6381) #get on that redis
    
    #Read and ensure valid encoding on structured data files
    files = Dir.glob('data/*.*').map do |file|
      FileEncodingSupport.new(file).file_with_encoding
    end
    
    #Read files into DataTable objects
    reader = Reader.new(files).read_all
    data = reader.data
    
    #Ready the db loader so you can do SQL joins (better)
    db_loader = DatabaseLoader.new data
    
    #Start joining
    joiner = Joiner.build_with_data([:school_code, :staff_code, :student_code], data)
    joiner.run_with_sql db_loader.connection
    
    #Get rid of the in memory DB because result tables are stored in Redis
    db_loader.connection.disconnect
    
    #Inspect the Join and why not get em as CSVs
    done = joiner.done_strategies
    to_do = done.map{ |d| d.last.table_id}
    to_do.each do |d|
      csv_string = CSV.generate do |csv|
        data = DataTable.new([],[], d)
        csv << data.headers
        data.rows.each do |r|
          csv << r.values
        end
      end
      IO.write('out/'+d+'.csv', csv_string)
    end    
    
    
 Some caveats to this are make sure Redis is running before you start and that you have install SQLite3 on your system.
 
#### Test

    bundle
    rspec
