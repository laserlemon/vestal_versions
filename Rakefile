require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('vestal_versions', '0.4.0') do |g|
  g.description = %(Keep a DRY history of your ActiveRecord models' changes)
  g.url = 'http://github.com/laserlemon/vestal_versions'
  g.author = 'Steve Richert'
  g.email = 'steve@laserlemon.com'
  g.ignore_pattern = %w(tmp/* script/*)
  g.development_dependencies = []
end

Dir["#{File.dirname(__FILE__)}/tasks/*.rake"].sort.each{|t| load t }