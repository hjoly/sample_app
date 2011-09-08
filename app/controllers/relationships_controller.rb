class RelationshipsController < ApplicationController
  before_filter :authenticate

  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      # In the case of an Ajax request, Rails calls a javaScript Embedded ruby: create.js.erb
      format.js
    end
  end

  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_to do |format|
      format.html { redirect_to @user }
      # In the case of an Ajax request, Rails calls a javaScript Embedded ruby: destroy.js.erb      
      format.js
    end
  end
end
