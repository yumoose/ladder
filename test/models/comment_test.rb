require "test_helper"

describe Comment do
  before do
    @comment = Comment.new(
      user: create(:user),
      commentable: create(:game)
    )
  end

  it "must be valid" do
    @comment.valid?.must_equal true
  end
end
