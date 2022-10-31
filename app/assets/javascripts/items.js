$(function() {
  $("#item_list_id").change((event) => {
    const listId = event.target.options[event.target.selectedIndex].value;

    $.get(
      `/lists/${listId}/categories.json`,
      (categories) => {
        const categorySelect = document.getElementById("item_category_id");

        // Clear current
        while(categorySelect.length) {
          categorySelect.remove(0);
        }

        // Add fetched
        categories.forEach(category => {
          const element = document.createElement("option");
          element.text = category.name;
          element.value = category.id;
          categorySelect.add(element);
        })
      }
    );
  })
})
