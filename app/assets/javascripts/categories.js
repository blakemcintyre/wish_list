$(function() {
  $("#category_list_id").change((event) => {
    const listId = event.target.options[event.target.selectedIndex].value;

    $.get(
      `/lists/${listId}/categories.json?parent_only=true`,
      (categories) => {
        const parentCategorySelect = document.getElementById("category_parent_category_id");
        const id = parseInt($("#category_id").val());

        // Clear current
        while(parentCategorySelect.length) {
          parentCategorySelect.remove(0);
        }

        // No parent option
        parentCategorySelect.add(document.createElement("option"));

        // Add fetched
        categories.forEach(category => {
          if (category.id === id) return;

          const element = document.createElement("option");
          element.text = category.name;
          element.value = category.id;
          parentCategorySelect.add(element);
        })
      }
    );
  })
})
