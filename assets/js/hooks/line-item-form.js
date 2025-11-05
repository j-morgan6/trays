const LineItemForm = {
  mounted() {
    this.handleClick = (e) => {
      e.preventDefault()

      // Find the input fields within the same container
      const container = this.el.closest('.grid')
      const descriptionInput = container.querySelector('input[name="line_item[description]"]')
      const quantityInput = container.querySelector('input[name="line_item[quantity]"]')
      const amountInput = container.querySelector('input[name="line_item[amount]"]')

      // Get the current DOM values
      const params = {
        description: descriptionInput?.value || '',
        quantity: quantityInput?.value || '',
        amount: amountInput?.value || ''
      }

      // Push event to the server with the actual form values
      this.pushEvent("add_temp_line_item_from_inputs", params)
    }

    this.el.addEventListener("click", this.handleClick)
  },

  destroyed() {
    this.el.removeEventListener("click", this.handleClick)
  }
}

export default LineItemForm
