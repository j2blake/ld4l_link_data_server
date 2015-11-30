# What did you ask for?
class UserInputError < StandardError
end

USAGE_TEXT = 'Usage: ld4l_run_link_data_server <target_dir> <report_file> <pairtree_prefix> [namespace] [REPLACE]'

def process_arguments(args)
  replace_report = args.delete('REPLACE')

  raise UserInputError.new(USAGE_TEXT) unless args && (3..4).include?(args.size)

  pair_tree_base = File.expand_path(args[0])
  raise UserInputError.new("Target directory doesn't exist: #{pair_tree_base}") unless Dir.exist?(pair_tree_base)

  raise UserInputError.new("#{args[1]} already exists -- specify REPLACE") if File.exist?(args[1]) unless replace_report
  raise UserInputError.new("Can't create #{args[1]}: no parent directory.") unless Dir.exist?(File.dirname(args[1]))

  $files = Pairtree.at(pair_tree_base, :prefix => args[2])
  $report = File.open(File.expand_path(args[1]), 'w')
  $namespace = args[3]
end

begin
process_arguments(ARGV)
rescue UserInputError
  puts
  puts "ERROR: #{$!}"
  puts
  exit
end

