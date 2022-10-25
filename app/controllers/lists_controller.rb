class ListsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_side_bar_lists
  before_action :set_list, only: %i(edit update destroy remove_claimed)
  respond_to :html, :json

  def index
    @lists = list_scope.includes(permissions: [:user])
  end

  def new
    @list = List.new
    @permissions = [@list.permissions.build(user: current_user)]
    @users_without_permissions = User.where.not(id: current_user.id).order(:name)
  end

  def create
    @list = List.new(list_params)

    if @list.save
      redirect_to lists_path
    else
      render action: :create
    end
  end

  def edit
    @permissions = @list.permissions.includes(:user).order('users.name')
    @users_without_permissions = User.where.not(id: @permissions.pluck(:user_id)).order(:name)
  end

  def update
    if @list.update(list_params)
      flash.notice = 'List updated'
      redirect_to lists_path
    else
      edit
      render action: :edit
    end
  end

  def destroy
    @list.destroy
    flash.notice = 'List deleted'

    redirect_to lists_path
  end

  def remove_claimed
    ClaimedRemover.new(@list).process
    flash.notice = 'Claimed items removed'

    redirect_to list_items_path(@list)
  end

  private

  def list_params
    permission_attributes = params.delete(:permission_attributes).values.each_with_object([]) do |attrs, collection|
      next if attrs[:user_id].to_i.zero? && !attrs.key?(:id)

      collection << attrs
    end

    params.require(:list).permit(:name).tap do |attrs|
      attrs[:permissions_attributes] = permission_attributes
    end
  end

  def set_list
    @list = list_scope.find(params[:id])
  end

  def list_scope
    current_user.lists
  end
end
