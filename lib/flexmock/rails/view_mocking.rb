require 'flexmock'

class FlexMock
  module MockContainer

    # Declare that the Rails controller under test should render the
    # named view.  If a view template name is given, it will be an
    # error if the named view is not rendered during the execution of
    # the contoller action.  If no template name is given, then the
    # any view may be rendered. If no view is actually rendered, then
    # a assertion failure will occur.
    def should_render_view(template_name=nil)
      view = flexmock("MockView")
       view.should_receive(
         :assigns => {},
         :render_file => true,
         :first_render => "dummy_template"
        )
      if template_name
        view.should_receive(:file_exists?).with(/#{template_name}$/).once.
          and_return(true)
      end
      view.should_receive(:file_exists?).with(any).and_return(true)
      view_class = flexmock("MockViewClasss")
      view_class.should_receive(:new).and_return(view)
      flexmock(@controller.class).should_receive(:view_class).once.
        and_return(view_class)
    end
  end
end
