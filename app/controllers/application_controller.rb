class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def set_side_bar_lists
    @side_bar_lists ||= List.select("lists.*, SUM(1) FILTER (WHERE list_permissions.user_id = #{current_user.id}) AS current_user_edit")
                            .left_joins(:permissions)
                            .where.not(id: ListPermission.select(:list_id).where(user: current_user, claimable: false))
                            .group(:id)
                            .order(:name)
  end
end
