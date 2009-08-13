require 'test_helper'

class VersionTest < ActiveSupport::TestCase
  test "compare version numbers" do
    version1 = Version.new(:number => 1)
    version2 = Version.new(:number => 2)

    assert_equal -1, version1 <=> version2
    assert version1 != version2
    assert version1 > version2
    assert version2 < version1
  end
end
