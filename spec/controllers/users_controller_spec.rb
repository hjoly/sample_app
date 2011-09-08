require 'spec_helper'

describe UsersController do
  
  render_views

  describe "GET 'index'" do

    describe "for non-signed-in users" do
      it "should deny access" do
        get :index
        response.should redirect_to(signin_path)
        flash[:notice].should =~ /sign in/i
      end
    end

    describe "for signed-in users" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        second = Factory(:user, :name => "Bob", :email => "another@example.com")
        third  = Factory(:user, :name => "Ben", :email => "another@example.net")

        @users = [@user, second, third]
        30.times do
          @users << Factory(:user, :email => Factory.next(:email))
        end
      end

      it "should be successful" do
        get :index
        response.should be_success
      end

      it "should have the right title" do
        get :index
        response.should have_selector("title", :content => "All users")
      end

      it "should have an element for each user" do
        get :index
        @users.each do |user|
          response.should have_selector("li", :content => user.name)
        end
      end

      it "should paginate users" do
        get :index
        response.should have_selector("div.pagination")
        response.should have_selector("span.disabled", :content => "Previous")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "2")
        response.should have_selector("a", :href => "/users?page=2",
                                           :content => "Next")
      end

      it "shouldn't show 'delete' link for non-admins" do
        get :index
        @users.each do |user|
          response.should_not have_selector("a", :content => "Delete #{user.name}")
        end
      end

      it "should show 'delete' link for admins" do
        admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(admin)

        get :index
        @users.each do |user|
          response.should_not have_selector("a", :content => "Delete #{user.name}")
        end
      end
    end
  end

  describe "GET 'show'" do

    before(:each) do
      @user = Factory(:user)
    end

    it "should be successful" do
      get :show, :id => @user
      response.should be_success
    end

    it "should find the right user" do
      get :show, :id => @user
      assigns(:user).should == @user
    end

    it "should have the right title" do
      get :show, :id => @user
      response.should have_selector("title", :content => @user.name)
    end

    it "should include the user's name" do
      get :show, :id => @user
      response.should have_selector("h1", :content => @user.name)
    end

    it "should have a profile image" do
      get :show, :id => @user
      response.should have_selector("h1>img", :class => "gravatar")
    end

    it "should have zero micropost" do
      get :show, :id => @user
      response.should have_selector("td", :class => "sidebar round", :content => "Microposts 0")
    end

    describe "with 2 microposts" do

      before(:each) do
        @mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
        @mp2 = Factory(:micropost, :user => @user, :content => "Baz quux")
      end

      it "should display the correct number of microposts" do
        get :show, :id => @user
        response.should have_selector("td", :class => "sidebar round", :content => "Microposts 2")
      end

      it "should show the user's microposts" do
        get :show, :id => @user
        response.should have_selector("span.content", :content => @mp1.content)
        response.should have_selector("span.content", :content => @mp2.content)
      end

      it "should not be any pagination" do
        get :show, :id => @user
        response.should_not have_selector("div", :class => "pagination")
      end

      it "should not display a 'delete' link for the micropost of a user not signed_in" do
        get :show, :id => @user
        response.should_not have_selector("a", :content => "delete")
      end
    end

    describe "with 30 microposts" do
      before(:each) do
        @mp = []
        (0..29).each { |i| @mp << Factory(:micropost, :user => @user, :content => "Lorem ipsum #{i}") }
      end

      it "there should not be any pagination" do
        get :show, :id => @user
        response.should_not have_selector("div", :class => "pagination")
      end

      describe "plus one" do
        before(:each) do
          mp31 = Factory(:micropost, :user => @user, :content => "Lorem ipsum 31")
        end
          
        it "there should be a pagination" do
          get :show, :id => @user
          response.should have_selector("div", :class => "pagination")
        end      
          
        it "we should be in page one" do
          get :show, :id => @user
          response.should have_selector("em.current", :content => "1")
        end      
          
        it "in page one, the 'previous page' link should be deactivated" do
          get :show, :id => @user
          response.should have_selector("span", :class => "previous_page disabled")
        end      
          
        it "in page one, the 'next page' link should be activated" do
          get :show, :id => @user
          response.should have_selector("a", :class => "next_page")
        end      
          
        # it "clicking on 'next' should bring to page two" do
        #   get :show, :id => @user
        #   click_link "2"
        #   response.should have_selector("em.current", :content => "2")
        # end      
      end
    end

    describe "for a signed-up user" do
      before(:each) do
        test_sign_in(@user)
        @mp1 = Factory(:micropost, :user => @user, :content => "Foo bar")
      end

      it "should display a 'delete' link for the micropost" do
        get :show, :id => @user
        response.should have_selector("a", :content => "delete")
      end
    end
  end

  describe "GET 'new'" do
    it "should be successful" do
      get 'new'
      response.should be_success
    end
  
    it "should have the right title" do
      get 'new'
      response.should have_selector("title", :content => "Sign up")
    end

    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end

    it "should have a name field" do
      get :new
      response.should have_selector("input[name='user[name]'][type='text']")
    end

    it "should have an email field" do
      get :new
      response.should have_selector("input[name='user[email]'][type='text']")
    end

    it "should have a password field" do
      get :new
      response.should have_selector("input[name='user[password]'][type='password']")
    end

    it "should have a password confirmation field" do
      get :new
      response.should have_selector("input[name='user[password_confirmation]'][type='password']")
    end

    it "should not be accessible to signed in users" do
      @user = test_sign_in(Factory(:user))
      get :new
      response.should redirect_to(root_path)
    end
  end


  describe "POST 'create'" do

    describe "failure" do

      before(:each) do
        @attr = { :name => "", :email => "", :password => "",
                  :password_confirmation => "" }
      end

      it "should not create a user" do
        lambda do
          post :create, :user => @attr
        end.should_not change(User, :count)
      end

      it "should have the right title" do
        post :create, :user => @attr
        response.should have_selector("title", :content => "Sign up")
      end

      it "should render the 'new' page" do
        post :create, :user => @attr
        response.should render_template('new')
      end

      it "should not be accessible to signed in users" do
        @user = test_sign_in(Factory(:user))
        post :create, :user => @attr
        response.should redirect_to(root_path)
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New User", :email => "user@example.com",
          :password => "foobar", :password_confirmation => "foobar" }
      end

      it "should create a user" do
        lambda do
          post :create, :user => @attr
        end.should change(User, :count).by(1)
      end

      it "should redirect to the user show page" do
        post :create, :user => @attr
        response.should redirect_to(user_path(assigns(:user)))
      end    

      it "should have a welcome message" do
        post :create, :user => @attr
        flash[:success].should =~ /welcome to the sample app/i
      end

      it "should sign the user in" do
        post :create, :user => @attr
        controller.should be_signed_in
      end
    end
  end

  describe "GET 'edit'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    it "should be successful" do
      get :edit, :id => @user
      response.should be_success
    end

    it "should have the right title" do
      get :edit, :id => @user
      response.should have_selector("title", :content => "Edit user")
    end

    it "should have a link to change the Gravatar" do
      get :edit, :id => @user
      gravatar_url = "http://gravatar.com/emails"
      response.should have_selector("a", :href => gravatar_url,
                                         :content => "change")
    end
  end

  describe "PUT 'update'" do

    before(:each) do
      @user = Factory(:user)
      test_sign_in(@user)
    end

    describe "failure" do

      before(:each) do
        @attr = { :email => "", :name => "", :password => "",
          :password_confirmation => "" }
      end

      it "should render the 'edit' page" do
        put :update, :id => @user, :user => @attr
        response.should render_template('edit')
      end

      it "should have the right title" do
        put :update, :id => @user, :user => @attr
        response.should have_selector("title", :content => "Edit user")
      end
    end

    describe "success" do

      before(:each) do
        @attr = { :name => "New Name", :email => "user@example.org",
          :password => "barbaz", :password_confirmation => "barbaz" }
      end

      it "should change the user's attributes" do
        put :update, :id => @user, :user => @attr
        # Reload the user from database.
        @user.reload
        @user.name.should  == @attr[:name]
        @user.email.should == @attr[:email]
      end

      it "should redirect to the user show page" do
        put :update, :id => @user, :user => @attr
        response.should redirect_to(user_path(@user))
      end

      it "should have a flash message" do
        put :update, :id => @user, :user => @attr
        flash[:success].should =~ /updated/
      end
    end
  end

  describe "authentication of edit/update pages" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "for non-signed-in users" do

      it "should deny access to 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(signin_path)
      end

      it "should deny access to 'update'" do
        put :update, :id => @user, :user => {}
        response.should redirect_to(signin_path)
      end
    end

    describe "for signed-in users" do

      before(:each) do
        wrong_user = Factory(:user, :email => "user@example.net")
        test_sign_in(wrong_user)
      end

      it "should require matching users for 'edit'" do
        get :edit, :id => @user
        response.should redirect_to(root_path)
      end

      it "should require matching users for 'update'" do
        # Why ", :user => {}"[?]
        put :update, :id => @user, :user => {}
        response.should redirect_to(root_path)
      end
    end
  end

  describe "DELETE 'destroy'" do

    before(:each) do
      @user = Factory(:user)
    end

    describe "as a non-signed-in user" do
      it "should deny access" do
        delete :destroy, :id => @user
        response.should redirect_to(signin_path)
      end
    end

    describe "as a non-admin user" do
      it "should protect the page" do
        test_sign_in(@user)
        delete :destroy, :id => @user
        response.should redirect_to(root_path)
      end
    end

    describe "as an admin user" do

      before(:each) do
        @admin = Factory(:user, :email => "admin@example.com", :admin => true)
        test_sign_in(@admin)
      end

      it "shouldn't be able to destroy himself" do
        lambda do
          delete :destroy, :id => @admin
        end.should_not change(User, :count)
      end

      it "should destroy the user" do
        lambda do
          delete :destroy, :id => @user
        end.should change(User, :count).by(-1)
      end

      it "should redirect to the users page" do
        delete :destroy, :id => @user
        response.should redirect_to(users_path)
      end
    end
  end

  describe "follow pages" do

    describe "when not signed in" do

      it "should protect 'following'" do
        get :following, :id => 1
        response.should redirect_to(signin_path)
      end

      it "should protect 'followers'" do
        get :followers, :id => 1
        response.should redirect_to(signin_path)
      end
    end

    describe "when signed in" do

      before(:each) do
        @user = test_sign_in(Factory(:user))
        @other_user = Factory(:user, :email => Factory.next(:email))
        @user.follow!(@other_user)
      end

      it "should show user following" do
        get :following, :id => @user
        response.should have_selector("a", :href => user_path(@other_user),
                                           :content => @other_user.name)
      end

      it "should show user followers" do
        get :followers, :id => @other_user
        response.should have_selector("a", :href => user_path(@user),
                                           :content => @user.name)
      end
    end
  end
end
