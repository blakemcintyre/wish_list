class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  private

  def set_side_bar_lists
    return @side_bar_lists if defined?(@side_bar_lists)

    scope = List.joins(:permissions)
    @side_bar_lists = scope
      .where(list_permissions: { user_id: current_user.id, claimable: true })
      .or(scope.where.not(list_permissions: { user_id: current_user.id }))
      .order(:name)
  end
end
