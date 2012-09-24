require 'spec_helper'

describe 'Type inference: class' do
	it "types Const#new" do
		input = parse "class Foo; end; Foo.new"
		mod = infer_type input
		input.last.type.should eq(mod.types['Foo'])
	end

	it "types Const#new" do
		input = parse "class Foo; def coco; 1; end; end; Foo.new.coco"
		mod = infer_type input
		input.last.type.should eq(mod.int)
	end

	it "types instance variable" do
		input = parse %(
			class Foo
				def set
					@coco = 2
				end
			end

			f = Foo.new
			f.set
		)
		mod = infer_type input
		input[1].type.should eq(ObjectType.new("Foo").with_var("@coco", mod.int))
	end

	it "types instance variable" do
		input = parse %(
			class Foo
				def set(value)
					@coco = value
				end
			end

			f = Foo.new
			f.set 2

			g = Foo.new
			g.set 2.5
		)
		mod = infer_type input
		input[1].type.should eq(ObjectType.new("Foo").with_var("@coco", mod.int))
		input[3].type.should eq(ObjectType.new("Foo").with_var("@coco", mod.float))
	end

	it "types instance variable on getter" do
		input = parse %(
			class Foo
				def set(value)
					@coco = value
				end

				def get
					@coco
				end
			end

			f = Foo.new
			f.set 2
			f.get
		)
		mod = infer_type input
		input.last.type.should eq(mod.int)
	end
end
