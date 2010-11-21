$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

require 'rubygems'
require 'test/unit'
require 'active_record'
require 'shoulda'
require 'mocha'
# require 'vestal_versions'
require File.expand_path(File.join(File.dirname(__FILE__), '../lib/vestal_versions'))
require 'schema'
begin; require 'redgreen'; rescue LoadError; end
