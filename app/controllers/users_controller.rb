class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user,   :only => [:edit, :update]
  before_filter :admin_user,     :only => :destroy
  before_filter :signed_in_user, :only => [:new, :create] # Only on my version.

  def index
    @users = User.paginate(:page => params[:page])
    @title = "All users"
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end

  def new
    @user = User.new
    @title = "Sign up"
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      sign_in @user
      redirect_to @user, :flash => { :success => "Welcome to the Sample App!" }
    else
      @title = "Sign up"
      @user.password = ""
      @user.password_confirmation = ""
      render 'new'
    end
  end

  def edit
    # @user is initialized from the correct_user via before filter.
    @title = "Edit user" 
  end

  def update
    # @user is initialized from the correct_user via before filter.
    if @user.update_attributes(params[:user])
      redirect_to @user, :flash => { :success => "Profile updated." }
    else 
      @title = "Edit user"
      render 'edit'
    end 
  end

  def destroy
    user = User.find(params[:id])
    unless current_user?(user)
      user.destroy
      flash[:success] = "User destroyed."
    end
    redirect_to users_path
  end

  def following
    show_follow(:following)
  end

  def followers
    show_follow(:followers)
  end

  private

    def correct_user
      @user = User.find(params[:id])
      redirect_to(root_path) unless current_user?(@user)
    end

    def admin_user
      redirect_to(root_path) unless current_user.admin?
    end

    def signed_in_user
      redirect_to(root_path) unless !signed_in?
    end

    def show_follow(action)
      @title = action.to_s.capitalize
      @user = User.find(params[:id])
      # Object#send :method, args => musician.play(violin) <=> musician.send( :play, violin)
      @users = @user.send(action).paginate(:page => params[:page])
      render 'show_follow'
    end
end
