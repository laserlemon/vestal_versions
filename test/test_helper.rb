$: << File.join(File.dirname(__FILE__), '..', 'lib')
$: << File.dirname(__FILE__)

require 'rubygems'
require 'test/unit'
require 'activerecord'
require 'shoulda'
require 'vestal_versions'
require 'schema'
begin; require 'redgreen'; rescue LoadError; end
