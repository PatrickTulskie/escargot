require 'test_helper'

class AdminIndexTest < Test::Unit::TestCase
  load_schema

  class User < ActiveRecord::Base
    elastic_index
  end

  def test_prune_index
    index = User.index_name
    3.times.each do
      Escargot::LocalIndexing.create_index_for_model(User)
    end
    User.refresh_index
    sleep(1)
    assert Escargot.connection.index_versions(index).size > 1
    assert Escargot.connection.index_versions(index).include? Escargot.connection.current_index_version(index)
    Escargot.connection.prune_index_versions(index)
    assert Escargot.connection.index_versions(index).size == 1
  end

  def teardown
    User.delete_index
  end
end
