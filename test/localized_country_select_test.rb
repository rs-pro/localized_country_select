# coding: utf-8
$KCODE = 'u'

require 'test/unit'

require 'rubygems'
require 'active_support'
require 'action_controller'
require 'action_view'
require 'action_view/helpers'
require 'action_view/helpers/tag_helper'
require 'i18n'

begin
  require 'redgreen'
rescue LoadError
  puts "[!] Install redgreen gem for better test output ($ sudo gem install redgreen)"
end unless ENV["TM_FILEPATH"]

require 'localized_country_select'

class LocalizedCountrySelectTest < Test::Unit::TestCase

  include ActionView::Helpers::TagHelper
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::FormTagHelper

  def test_action_view_should_include_helper_for_object
    assert ActionView::Helpers::FormBuilder.instance_methods.include?('country_select') # WTF not working with 1.9
    assert ActionView::Helpers::FormOptionsHelper.instance_methods.include?('country_select')
  end

  def test_action_view_should_include_helper_tag
    assert ActionView::Helpers::FormOptionsHelper.instance_methods.include?('country_select_tag') # WTF not working with 1.9
  end

  def test_should_return_select_tag_with_proper_name_for_object
    # puts country_select(:user, :country)
    assert country_select(:user, :country) =~
              Regexp.new(Regexp.escape('<select id="user_country" name="user[country]">')),
              "Should have proper name for object"
  end

  def test_should_return_select_tag_with_proper_name
    # puts country_select_tag( "competition_submission[data][citizenship]", nil)
    assert country_select_tag( "competition_submission[data][citizenship]", nil) =~
              Regexp.new(
              Regexp.escape('<select id="competition_submission_data_citizenship" name="competition_submission[data][citizenship]">') ),
              "Should have proper name"
  end

  def test_should_return_option_tags
    assert country_select(:user, :country) =~ Regexp.new(Regexp.escape('<option value="ES">Spain</option>'))
  end

  def test_should_return_localized_option_tags
    I18n.locale = 'ru'
    assert country_select(:user, :country) =~ Regexp.new(Regexp.escape('<option value="ES">Испания</option>'))
  end

  def test_should_return_priority_countries_first
    assert country_options_for_select(nil, [:ES, :CZ]) =~ Regexp.new(
      Regexp.escape("<option value=\"ES\">Spain</option>\n<option value=\"CZ\">Czech Republic</option><option value=\"\" disabled=\"disabled\">-------------</option>\n<option value=\"AF\">Afghanistan</option>\n"))
  end

  def test_i18n_should_know_about_countries
    assert_equal 'Spain', I18n.t('ES', :scope => 'countries')
    I18n.locale = 'ru'
    assert_equal 'Испания', I18n.t('ES', :scope => 'countries')
  end

  def test_localized_countries_array_returns_correctly
    assert_nothing_raised { LocalizedCountrySelect::localized_countries_array() }
    # puts LocalizedCountrySelect::localized_countries_array.inspect
    I18n.locale = 'en'
    assert_equal 243, LocalizedCountrySelect::localized_countries_array.size
    assert_equal 'Afghanistan', LocalizedCountrySelect::localized_countries_array.first[0]
    I18n.locale = 'ru'
    assert_equal 243, LocalizedCountrySelect::localized_countries_array.size
    assert_equal 'Австралия', LocalizedCountrySelect::localized_countries_array.first[0]
  end

  def test_priority_countries_returns_correctly_and_in_correct_order
    assert_nothing_raised { LocalizedCountrySelect::priority_countries_array([:TW, :CN]) }
    I18n.locale = 'en'
    assert_equal [ ['Taiwan', 'TW'], ['China', 'CN'] ], LocalizedCountrySelect::priority_countries_array([:TW, :CN])
  end

  def test_priority_countries_allows_passing_either_symbol_or_string
    I18n.locale = 'en'
    assert_equal [ ['United States', 'US'], ['Canada', 'CA'] ], LocalizedCountrySelect::priority_countries_array(['US', 'CA'])
  end

  def test_priority_countries_allows_passing_upcase_or_lowercase
    I18n.locale = 'en'
    assert_equal [ ['United States', 'US'], ['Canada', 'CA'] ], LocalizedCountrySelect::priority_countries_array(['us', 'ca'])
    assert_equal [ ['United States', 'US'], ['Canada', 'CA'] ], LocalizedCountrySelect::priority_countries_array([:us, :ca])
  end

  def test_should_list_countries_with_accented_names_in_correct_order
    I18n.locale = 'ru'
    assert_match Regexp.new(Regexp.escape(%Q{<option value="BT">Бутан</option>\n<option value="VU">Вануату</option>})), country_select(:user, :country)
  end

  # private

  def setup
    ['ru', 'en'].each do |locale|
      # I18n.load_translations( File.join(File.dirname(__FILE__), '..', 'locale', "#{locale}.rb")  )  # <-- Old style! :)
      I18n.load_path += Dir[ File.join(File.dirname(__FILE__), '..', 'locale', "#{locale}.rb") ]
    end
    # I18n.locale = I18n.default_locale
    I18n.locale = 'en'
  end

end
