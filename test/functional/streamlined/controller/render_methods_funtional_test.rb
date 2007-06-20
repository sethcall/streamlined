require File.join(File.dirname(__FILE__), '../../../test_functional_helper')
require 'streamlined/controller/render_methods'

class RenderMethodsFunctionalTest < Test::Unit::TestCase
  def setup
    @controller = PeopleController.new
    # Took a while to find this, setting layout=false was not good enough
    class <<@controller
      def active_layout
        false
      end
    end
    @controller.logger = RAILS_DEFAULT_LOGGER
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
    @controller.send :initialize_template_class, @response
    @controller.assign_shortcuts(@request, @response)
    class <<@controller
      public :render_tabs, :render_partials, :render_a_tab_to_string
    end
  end

  def test_render_partials
    assert_equal 'content1', @controller.render_partials('file1')
    assert_equal 'content1content2', @controller.render_partials('file1', 'file2')
  end

  def test_render_tabs
    response = @controller.render_tabs({:name => 'tab1', :partial => 'file1' }, {:name => 'tab2', :partial => 'file2'})
    #doc = REXML::Document.new(response)
    # assert_equal "tabber", doc.root.elements["/div[1]/@class"].value

    assert response =~ /tab1/
    assert response =~ /tab2/
    assert response =~ /<div class='tabber'>/
    assert response =~ /<div class='tabbertab'/
  end

  def test_render_tabs_in_order
    response = @controller.render_tabs({:name => 'tab1', :partial => "file1"}, 
                                       {:name => 'tab2', :partial => "file2"})
    assert response =~ /id='tab1'.*id='tab2'/
  end

  def test_render_tabs_with_missing_args
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:name => 'tab1'})
    }
    assert_equal 'render args are required', results.message
    results = assert_raise(ArgumentError) {
      response = @controller.render_tabs({:partial => 'shared/foo'})
    }
    assert_equal ':name is required', results.message
  end

  def test_render_tabs_with_shared_partial
    response = @controller.render_tabs({:name => 'tab1', :partial => 'shared/foo'})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
  end
  
  def test_render_partials
   response = @controller.render_partials('shared/foo')
   assert response =~ /^content3/
  end
  
  def test_render_tabs_with_partial_and_locals
    response = @controller.render_tabs({:name => 'tab1', :partial => 'shared/foo', :locals => {:something=>'something'}})

    assert response =~ /tab1/
    assert response =~ /tabber/
    assert response =~ /tabbertab/
    assert response =~ /content3/
    
    assert @locals = 'something'
  end
  
  def test_render_a_tab_to_string
    assert_equal "<div class='tabbertab' title='Firsts' id='First'>content1</div>", 
                 @controller.render_a_tab_to_string(:name=>"First", :partial=>"file1")
  end
  
end