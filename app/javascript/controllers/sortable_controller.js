import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]
  static values = { url: String }

  connect() {
    this.setupSortable()
  }

  setupSortable() {
    let draggedElement = null
    let placeholder = null

    this.itemTargets.forEach((item) => {
      item.draggable = true
      
      item.addEventListener('dragstart', (e) => {
        draggedElement = item
        item.classList.add('opacity-50', 'bg-indigo-50')
        e.dataTransfer.effectAllowed = 'move'
        e.dataTransfer.setData('text/html', item.outerHTML)
        
        // Create placeholder
        placeholder = document.createElement('div')
        placeholder.className = 'bg-indigo-100 border-2 border-dashed border-indigo-300 rounded-lg h-20 mb-4'
        item.parentNode.insertBefore(placeholder, item.nextSibling)
      })

      item.addEventListener('dragend', (e) => {
        item.classList.remove('opacity-50', 'bg-indigo-50')
        if (placeholder && placeholder.parentNode) {
          placeholder.parentNode.removeChild(placeholder)
        }
        draggedElement = null
        placeholder = null
      })

      item.addEventListener('dragover', (e) => {
        e.preventDefault()
        e.dataTransfer.dropEffect = 'move'
        
        if (draggedElement && item !== draggedElement) {
          const rect = item.getBoundingClientRect()
          const next = (e.clientY - rect.top) < (rect.height / 2)
          
          if (next) {
            this.element.insertBefore(draggedElement, item)
          } else {
            this.element.insertBefore(draggedElement, item.nextSibling)
          }
        }
      })

      item.addEventListener('drop', (e) => {
        e.preventDefault()
        if (draggedElement && item !== draggedElement) {
          this.saveOrder()
        }
      })
    })
  }

  saveOrder() {
    const items = Array.from(this.element.querySelectorAll('[data-item-id]'))
    const positions = items.map(item => item.dataset.itemId)
    
    const token = document.querySelector('meta[name="csrf-token"]')?.content
    
    fetch(this.urlValue, {
      method: 'PATCH',
      headers: {
        'Content-Type': 'application/json',
        'X-CSRF-Token': token,
        'Accept': 'application/json'
      },
      body: JSON.stringify({ positions: positions })
    })
    .then(response => response.json())
    .then(data => {
      if (data.status === 'success') {
        this.showSuccessMessage()
      } else {
        this.showErrorMessage()
      }
    })
    .catch(error => {
      console.error('Error:', error)
      this.showErrorMessage()
    })
  }

  showSuccessMessage() {
    const message = document.createElement('div')
    message.className = 'fixed top-4 right-4 bg-green-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 transition-all'
    message.textContent = '✓ Order saved successfully!'
    document.body.appendChild(message)
    
    setTimeout(() => {
      message.style.opacity = '0'
      setTimeout(() => message.remove(), 300)
    }, 2000)
  }

  showErrorMessage() {
    const message = document.createElement('div')
    message.className = 'fixed top-4 right-4 bg-red-500 text-white px-6 py-3 rounded-lg shadow-lg z-50 transition-all'
    message.textContent = '✗ Error saving order. Please try again.'
    document.body.appendChild(message)
    
    setTimeout(() => {
      message.style.opacity = '0'
      setTimeout(() => message.remove(), 300)
    }, 3000)
  }
}

