class ItemsGrouper
  attr_reader :unclaimed_sub_categories, :unclaimed_categories, :claimed_sub_categories, :claimed_categories

  def initialize(items_owner, current_user)
    @items_owner = items_owner
    @current_user = current_user
    build_unclaimed
    build_claimed
  end

  def items_by_category
    @items_by_category ||= begin
      Item.select("
          items.*,
          COALESCE(SUM(item_claims.quantity) FILTER (WHERE item_claims.user_id = #{@current_user.id}), 0) AS user_claimed_quantity,
          items.quantity - SUM(COALESCE(item_claims.quantity, 0)) AS quantity_remaining
        ")
        .left_outer_joins(:item_claims)
        .where(user_id: @items_owner)
        .unacknowledged
        .undeleted
        .group(:id)
        .order(:category_id, :name)
        .group_by { |item| [item.category_id, tag(item)] }
    end
  end

  def recently_deleted_items
    @recently_deleted_items ||= @items_owner.items.includes(:category).recently_deleted
  end

  def empty?
    unclaimed_categories.empty? && claimed_categories.empty?
  end

  private

  def build_unclaimed
    @unclaimed_categories, @unclaimed_sub_categories = split_parent_and_sub_categories(:unclaimed)
  end

  def build_claimed
    @claimed_categories, @claimed_sub_categories = split_parent_and_sub_categories(:claimed)
  end

  def split_parent_and_sub_categories(claimed_grouping_key)
    all_categories = fetch_categories(claimed_grouping_key)
    sub_categories = group_sub_categories_by_parent(all_categories)
    categories = filter_out_sub_categories(all_categories)
    categories = append_missing_parent_categories(categories, sub_categories)
    categories.sort! { |a, b| a.name <=> b.name }
    [categories, sub_categories]
  end

  def fetch_categories(claimed_grouping_key)
    @items_owner
      .categories
      .includes(:items)
      .references(:items)
      .merge(Item.where(id: claimed_grouping.fetch(claimed_grouping_key, [])))
      .order(:name, "items.name")
  end

  def claimed_grouping
    @claimed_grouping ||= Item.claimed_grouping(@items_owner.id, @current_user.id)
  end

  def group_sub_categories_by_parent(categories)
    categories.select do |category|
      category.parent_category_id.present?
    end.group_by(&:parent_category_id)
  end

  def filter_out_sub_categories(categories)
    categories.reject { |category| category.parent_category_id.present? }
  end

  # Ensure that parent categories that have no direct items are listed
  def append_missing_parent_categories(categories, sub_categories)
    sub_categories.each do |parent_category_id, sub_cats|
      next if categories.include?(sub_cats.first.parent_category)
      categories.push(sub_cats.first.parent_category)
    end

    categories
  end

  def tag(item)
    if item.quantity.nil? || (item.user_claimed_quantity.zero? && item.quantity_remaining.positive?)
      :unclaimed
    else
      :claimed
    end
  end
end
