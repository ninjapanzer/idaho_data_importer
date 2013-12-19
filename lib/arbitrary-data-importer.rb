path = 'arbitrary-data-importer'
files = ['data_file_identifier',
         'data_table',
         'database_loader',
         'encoding_support',
         'exceptions',
         'file_encoding_support',
         'file_naming_support',
         'joiner',
         'logging',
         'reader',
         'strict_csv',
         'strict_tsv',
         'type_conversion_support']
files.each do |f|
  require_relative "#{path}/#{f}"
end