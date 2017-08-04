# This is a sample RSpec file against which to test a custom fold expression.
# The expected foldlevels of each line are listed on one line at the end of the file.

require 'spec_helper'
require 'set'

RSpec.describe "something" do
  it "does something" do
  end
end

RSpec.describe "something" do
  context "in one context" do
    it "does one thing" do
    end
  end

  context "in another context" do
    it "does another thing" do
    end
  end
end

RSpec.shared_examples "some example" do |parameter|
  \# Same behavior is triggered also with either `def something; 'some value'; end`
  \# or `define_method(:something) { 'some value' }`
  let(:something) { parameter }
  xit "uses the given parameter" do
    expect(something).to eq(parameter)
  end
end

RSpec.xdescribe SomeClass do
  include_examples "some example", "parameter1"
  include_examples "some example", "parameter2"
end

RSpec.shared_examples "a collection" do
  let(:collection) { described_class.new([7, 2, 4]) }

  context "initialized with 3 items" do
    it "says it has three items" do
      expect(collection.size).to eq(3)
    end
  end

  fdescribe "#include?" do
    context "with an item that is in the collection" do
      it "returns true" do
        expect(collection.include?(7)).to be_truthy
      end
    end

    xcontext "with an item that is not in the collection" do
      it "returns false" do
        expect(collection.include?(9)).to be_falsey
      end
    end
  end
end

RSpec.describe Array do
  it_behaves_like "a collection"
end

RSpec.describe Set do
  it_behaves_like "a collection"
end

RSpec.shared_examples "a collection object" do
  describe "<<" do
    it "adds objects to the end of the collection" do
      collection << 1
      collection << 2
      expect(collection.to_a).to match_array([1, 2])
    end
  end
end

RSpec.describe Array do
  it_behaves_like "a collection object" do
    let(:collection) { Array.new }
  end
end

RSpec.describe Set do
  it_behaves_like "a collection object" do
    let(:collection) { Set.new }
  end
end

RSpec.describe Array, "with 3 items" do
  subject { [1, 2, 3] }
  it_should_behave_like "a measurable object", 3, [:size, :length]
end

RSpec.describe String, "of 6 characters" do
  subject { "FooBar" }
  it_should_behave_like "a measurable object", 6, [:size, :length]
end

feature "Signing in" do
  background do
    User.make(email: 'user@example.com', password: 'caplin')
  end

  scenario "Signing in with correct credentials" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Email', with: 'user@example.com'
      fill_in 'Password', with: 'caplin'
    end
    click_button 'Sign in'
    expect(page).to have_content 'Success'
  end

  given(:other_user) { User.make(email: 'other@example.com', password: 'rous') }

  scenario "Signing in as another user" do
    visit '/sessions/new'
    within("#session") do
      fill_in 'Email', with: other_user.email
      fill_in 'Password', with: other_user.password
    end
    click_button 'Sign in'
    expect(page).to have_content 'Invalid email or password'
  end
end

0 0 0 0 0 0 >1 >2 2 1 1 >1 >2 >3 3 2 2 >2 >3 3 2 1 1 >1 1 1 1 >2 2 2 1 1 >1 1 1 1 1 >1 1 1 >2 >3 3 3 2 2 >2 >3 >4 4 4 3 3 >3 >4 4 4 3 2 1 1 >1 1 1 1 >1 1 1 1 >1 >2 >3 3 3 3 3 2 1 1 >1 >2 2 2 1 1 >1 >2 2 2 1 1 >1 1 1 1 1 >1 1 1 1 1 >1 >2 2 2 2 >2 2 2 2 2 2 2 2 2 2 >2 2 >2 2 2 2 2 2 2 2 2 1 1
