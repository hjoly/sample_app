class RelationshipsController < ApplicationController
  before_filter :authenticate

  respond_to :html, :js

  # To see how it gets called, see app/views/users/_follow.html.erb 
  # and "RelationshipsController POST 'create' should create a relationship" 
  # in spec/controlller/relationships_controller_spec.rb
  def create
    @user = User.find(params[:relationship][:followed_id])
    current_user.follow!(@user)
    respond_with @user
    # respond_to do |format|
    #   format.html { redirect_to @user }
    #   # In the case of an Ajax request, Rails calls a javaScript Embedded ruby: create.js.erb
    #   format.js
    # end
  end

  # To see how it gets called, see app/views/users/_unfollow.html.erb 
  # and "RelationshipsController DELETE 'destroy' should destroy a relationship"
  # in spec/controlller/relationships_controller_spec.rb
  def destroy
    @user = Relationship.find(params[:id]).followed
    current_user.unfollow!(@user)
    respond_with @user
    # respond_to do |format|
    #   format.html { redirect_to @user }
    #   # In the case of an Ajax request, Rails calls a javaScript Embedded ruby: destroy.js.erb      
    #   format.js
    # end
  end
end
