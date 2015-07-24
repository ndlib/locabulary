require_relative '../lib/locabulary'
require 'minitest/autorun'

class LocabularyTest < MiniTest::Test
  def setup
    Locabulary.reset_active_cache!
  end

  def test_it_will_throw_an_exception_if_the_predicate_name_is_missing
    assert_raises(Locabulary::RuntimeError) { Locabulary.filename_for_predicate_name(predicate_name: '__missing__') }
  end

  def test_it_will_dereference_the_filename_to_a_basename
    assert_equal(Locabulary.filename_for_predicate_name(predicate_name: "../test/copyright"), File.join(Locabulary::DATA_DIRECTORY, 'copyright.json'))
  end

  def test_it_will_parse_the_given_data
    result = Locabulary.active_items_for(predicate_name: 'copyright')
    assert_equal(result.first.term_label, 'All rights reserved')
  end

  def test_labels_for
    result = Locabulary.active_labels_for(predicate_name: 'copyright')
    assert_equal(result.first, 'All rights reserved')
  end

  def test_it_will_build_a_cached_data
    Locabulary.active_items_for(predicate_name: 'copyright')
    assert_equal(Locabulary.active_cache.key?('copyright'), true)
  end

  def test_active_label_for_uri_when_uri_is_found
    label = Locabulary.active_label_for_uri(predicate_name: 'copyright', term_uri: 'http://creativecommons.org/licenses/by/3.0/us/')
    assert_equal(label, 'Attribution 3.0 United States')
  end

  def test_active_label_for_uri_when_uri_is_not_found
    label = Locabulary.active_label_for_uri(predicate_name: 'copyright', term_uri: 'Chompy')
    assert_equal(label, 'Chompy')
  end

  def test_active_nested_label_for
    obtained_result = Locabulary.active_nested_labels_for(predicate_name: 'affiliation')
    expected_result = {
      "Faculty research and publications" => ["Faculty research and publications"],
      "Staff research and publications" => ["Staff research and publications"],
      "Graduate research and publications" => ["Graduate research and publications"],
      "Undergraduate research and publications" => ["Undergraduate research and publications"],
      "Other" => ["Other"]
    }
    assert_equal(obtained_result, expected_result)
  end
end

class Locabulary::ItemTest < MiniTest::Test
  def test_sort_with_nil_and_integer
    item_1 = Locabulary::Item.new(default_presentation_sequence: nil, label: 'Hello')
    item_2 = Locabulary::Item.new(default_presentation_sequence: 2, label: 'World')

    assert_equal([item_1,item_2].sort, [item_2, item_1])
  end
end
