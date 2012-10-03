require 'spec_helper'

describe GraphAPI do
  it '#auth_url' do
    GraphAPI.auth_url.should == ""
  end
end
