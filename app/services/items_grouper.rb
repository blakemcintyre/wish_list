class ItemsGrouper
  attr_reader :unclaimed_sub_categories, :unclaimed_categories, :claimed_sub_categories, :claimed_categories, :items_by_category

  def initialize(items_owner, current_user)
    @items_owner = items_owner
    @current_user = current_user
    @claimed_categories = SortedSet.new
    @unclaimed_categories = SortedSet.new
    @claimed_sub_categories = Hash.new { |h, k| h[k] = SortedSet.new }
    @unclaimed_sub_categories = Hash.new { |h, k| h[k] = SortedSet.new }

    build_items_and_categories
  end

  def recently_deleted_items
    @recently_deleted_items ||= @items_owner.items.includes(:category).recently_deleted
  end

  def empty?
    unclaimed_categories.empty? && claimed_categories.empty?
  end

  private

  def build_items_and_categories
    @items_by_category = items_query.each_with_object(Hash.new { |h, k| h[k] = [] }) do |item, by_category|
      if item.all_claimed_quantity.positive?
        by_category[[item.category_id, :claimed]] << item
        add_claimed_category(item.category_id)
      end

      if item.user_claimed_quantity.zero? && (item.quantity.nil? || item.quantity_remaining&.positive?)
        by_category[[item.category_id, :unclaimed]] << item
        add_unclaimed_category(item.category_id)
      end
    end
  end

  def items_query
    Item.select("
        items.*,
        COALESCE(SUM(item_claims.quantity) FILTER (WHERE item_claims.user_id = #{@current_user.id}), 0) AS user_claimed_quantity,
        COALESCE(SUM(item_claims.quantity), 0) AS all_claimed_quantity,
        items.quantity - SUM(COALESCE(item_claims.quantity, 0)) AS quantity_remaining,
        ARRAY_AGG(item_claims.notes) AS claim_notes
      ")
      .left_outer_joins(:item_claims)
      .where(user_id: @items_owner)
      .undeleted
      .group(:id)
      .order(:category_id, :name)
  end

  def add_claimed_category(category_id)
    add_category_grouping(category_id, @claimed_categories, @claimed_sub_categories)
  end

  def add_unclaimed_category(category_id)
    add_category_grouping(category_id, @unclaimed_categories, @unclaimed_sub_categories)
  end

  def add_category_grouping(category_id, primary_categories, sub_categories)
    category = categories[category_id]

    if category.parent_category_id.blank?
      primary_categories << category
    else
      sub_categories[category.parent_category_id] << category
      primary_categories << category.parent_category
    end
  end

  def categories
    @categories ||= Category
      .joins(:items)
      .includes(:parent_category)
      .merge(Item.undeleted)
      .index_by(&:id)
  end
end
