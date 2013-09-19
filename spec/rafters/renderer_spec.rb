require 'spec_helper'

describe Rafters::Renderer do
  let(:view_context) { double("ViewContext", render: true).as_null_object }
  let(:controller) { double("Controller", content_tag: true).as_null_object }

  describe "when initialized" do
    before do
      Rafters.stub(:view_paths).and_return(["/path/to/views"])
    end

    it "should add the view paths for all components to the controller" do
      controller.should_receive(:prepend_view_path).with("/path/to/views")
      Rafters::Renderer.new(controller, view_context)
    end
  end

  describe "#render" do
    subject { Rafters::Renderer.new(controller, view_context) }

    let(:component) do 
      double("Component", {
        identifier: "foo-1",
        options: Hashie::Mash.new({ wrapper: true, view_name: "foo" }), 
        locals: Hashie::Mash.new({ foo: "bar" })
      }).as_null_object
    end

    before do
      component.stub(:attributes).and_return({ title: "Foo" })
      component.stub(:template_name).and_return("template")
    end

    it "renders the component template with it's settings and attributes" do
      view_context.should_receive(:render).with(file: "/foo", locals: Hashie::Mash.new({ foo: "bar" }))
      subject.render(component)
    end

    context "with before_render callbacks defined on the component" do
      it "calls the before_render methods before rendering the component" do
        component.should_receive(:execute_callbacks!).with(:before_render_callbacks)
        subject.should_receive(:render_without_wrapper).ordered
        subject.render(component)
      end
    end

    context "with after_render callbacks defined on the component" do
      it "calls the after_render methods before rendering the component" do
        subject.should_receive(:render_without_wrapper).ordered
        component.should_receive(:execute_callbacks!).with(:after_render_callbacks).ordered
        subject.render(component)
      end
    end
  end
end
