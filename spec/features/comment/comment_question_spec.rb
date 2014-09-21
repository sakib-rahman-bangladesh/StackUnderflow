require 'rails_helper'

feature "Questions Commenting", %q{
  In order to clarify something
  As an authenticated user
  I want to comment questions
} do

  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:comment) { build(:comment, user: user) }

  scenario "User comments question" do
    post_comment comment.body

    within(".question") do
      expect(page).to have_content comment.body
    end
  end

  scenario "User comments question with valid data" do
    post_comment ""

    expect(page).to have_content "Ivalid data!"
  end
end

def post_comment comment
    sign_in user
    visit question_path(question)

    within(".question") do
      click_on "Comment"
    end

    fill_in :comment_body, with: comment
    within(".question") do
      click_on "Post comment"
    end
end