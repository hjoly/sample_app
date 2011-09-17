require 'spec_helper'

describe "Users" do

  describe "signup" do

    describe "failure:" do

      it "should not make a new user" do
        lambda do
          visit signup_path
          # Can also use CSS id like: "fill_in :user_name ..." (here "user_name" is the CSS id of that field)
	  fill_in "Name",		:with => ""
	  fill_in "Email",		:with => ""
	  fill_in "Password",		:with => ""
	  fill_in "Confirmation",	:with => ""
	  click_button
	  response.should render_template('users/new')
	  response.should have_selector("div#error_explanation")
	end.should_not change(User, :count)
      end 
    end

    describe "success:" do

      it "should make a new user" do
        lambda do
          visit signup_path
          fill_in "Name",         :with => "Example User"
          fill_in "Email",        :with => "user@example.com"
          fill_in "Password",     :with => "foobar"
          fill_in "Confirmation", :with => "foobar"
          click_button
          response.should have_selector("div.flash.success",
                                        :content => "Welcome")
          response.should render_template('users/show')
        end.should change(User, :count).by(1)
      end
    end
  end

  describe "sign in/out" do

    describe "failure:" do
      it "should not sign a user in" do
        visit signin_path
        empty_user = User.new()
        integration_sign_in(empty_user)
        response.should have_selector("div.flash.error", :content => "Invalid")
      end
    end

    describe "success:" do
      it "should sign a user in and out" do
        user = Factory(:user)
        integration_sign_in(user)
        controller.should be_signed_in
        click_link "Sign out"
        controller.should_not be_signed_in
      end
    end
  end

  describe "follow/unfollow a user" do

    before(:each) do
      @user = Factory(:user)
      integration_sign_in(@user)

      @not_followed = Factory(:user, :name => "Not Followed", :email => "another@example.com")

      @followed = Factory(:user, :name => "Followed", :email => "another@example.net")
      @user.follow!(@followed)

      visit users_path
    end

    describe "failure:" do
      it "should not be able to follow/unfollow himself" do
        click_link "#{@user.name}"
        response.should_not have_selector("input", :id => "relationship_submit", :value => "Follow")
        response.should_not have_selector("input", :id => "relationship_submit", :value => "Unfollow")
      end

      it "should not be able to follow a user already followed" do
        click_link "Followed"
        response.should_not have_selector("input", :id => "relationship_submit", :value => "Follow")
      end

      it "should not be able to unfollow a user who is not followed yet" do
        click_link "Not Followed"
        response.should_not have_selector("input", :id => "relationship_submit", :value => "Unfollow")
      end
    end

    describe "success:" do
      it "should follow another user who is not followed yet" do
        visit users_path
        click_link "Not Followed"
        response.should have_selector("input", :id => "relationship_submit", :value => "Follow")
      end

      it "should unfollow another user already followed" do
        click_link "Followed"
        response.should have_selector("input", :id => "relationship_submit", :value => "Unfollow")
      end
    end
  end
end
