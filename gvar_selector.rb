require 'csv'
require 'envyable'

Envyable.load('./config/env.yml', 'database')
PREFIX = ENV['PREFIX_DB_NAME']
GVAR_NUMBER = 100

def read_results
  results = {}
  CSV.foreach("results/#{PREFIX}_data_gvar.csv", :headers => true, :header_converters => :symbol, :converters => :all) do |row|
    results[row.fields[0]] = Hash[row.headers[1..-1].zip(row.fields[1..-1])]
  end
  results
end

def select_from project, file, total, num
  gvars = []
  CSV.foreach(file, :headers => true) do |row|
    gvars << [row]
  end

  CSV.open("results/#{PREFIX}_#{project}_gv_selected.csv", "w+") do |row|
    row << ['gv','filename','line','sha','bugcount']
    gvars.shuffle[0..(num-1)].each{|r| row << r[0]}
  end
end

projects = {}
total_gvars = 0

read_results.each do |proj, res|
  # puts "#{PREFIX}_#{proj}_gvar_def.csv"
  # puts res[:bfs]
  total_gvars += res[:bfs]
  projects.merge!({"#{proj}" => {file: "results/#{PREFIX}_#{proj}_gvar_def.csv", total: res[:bfs]}})
end

projects.map do |k, v|
  # total = v[:total]
  puts "-------------------------------------------------"
  puts "#{v[:total]}"
  puts "#{total_gvars.to_f}"
  puts "#{(v[:total] / total_gvars.to_f).ceil}"
  puts "(v[:total] / total_gvars.to_f).ceil * GVAR_NUMBER"
  puts "-------------------------------------------------"
  {k => v.merge!({:select => ((v[:total] / total_gvars.to_f) * GVAR_NUMBER).ceil })}
end

p projects

projects.each do |k,v|
  select_from k, v[:file], v[:total], v[:select]
end
