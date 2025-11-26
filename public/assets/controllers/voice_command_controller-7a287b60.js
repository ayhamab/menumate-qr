import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "status", "items", "feedback"]
  static values = {
    listening: Boolean,
    supported: Boolean
  }

  connect() {
    // Check if browser supports Web Speech API
    this.supportedValue = 'webkitSpeechRecognition' in window || 'SpeechRecognition' in window
    
    if (!this.supportedValue) {
      this.showError("Voice commands are not supported in your browser. Please use Chrome, Edge, or Safari.")
      return
    }

    // Initialize Speech Recognition
    const SpeechRecognition = window.SpeechRecognition || window.webkitSpeechRecognition
    this.recognition = new SpeechRecognition()
    this.recognition.continuous = false
    this.recognition.interimResults = false
    this.recognition.lang = 'en-US'

    // Dietary tag mappings
    this.dietaryMappings = {
      'vegan': ['vegan', 'no animal products', 'plant based'],
      'vegetarian': ['vegetarian', 'no meat', 'no fish'],
      'gluten-free': ['gluten free', 'no gluten', 'gluten-free'],
      'dairy-free': ['dairy free', 'no dairy', 'lactose free', 'no milk'],
      'nut-free': ['nut free', 'no nuts', 'peanut free'],
      'halal': ['halal', 'halal food'],
      'kosher': ['kosher', 'kosher food'],
      'low-carb': ['low carb', 'low carbohydrate', 'low carbs'],
      'keto': ['keto', 'ketogenic', 'keto diet'],
      'paleo': ['paleo', 'paleolithic'],
      'organic': ['organic', 'organic food'],
      'spicy': ['spicy', 'hot', 'spice'],
      'sugar-free': ['sugar free', 'no sugar', 'sugar-free'],
      'low-fat': ['low fat', 'low-fat', 'reduced fat'],
      'high-protein': ['high protein', 'protein rich', 'high-protein']
    }

    // Command patterns
    this.commandPatterns = {
      filter: ['show me', 'filter', 'find', 'show', 'display', 'only', 'just'],
      clear: ['clear', 'reset', 'show all', 'remove filter', 'all items'],
      help: ['help', 'what can I say', 'commands', 'options']
    }

    this.recognition.onresult = (event) => {
      const transcript = event.results[0][0].transcript.toLowerCase().trim()
      this.processVoiceCommand(transcript)
    }

    this.recognition.onerror = (event) => {
      console.error('Speech recognition error:', event.error)
      this.handleRecognitionError(event.error)
    }

    this.recognition.onend = () => {
      this.listeningValue = false
      this.updateButtonState()
    }
  }

  toggleListening() {
    if (!this.supportedValue) {
      this.showError("Voice commands not supported")
      return
    }

    if (this.listeningValue) {
      this.stopListening()
    } else {
      this.startListening()
    }
  }

  startListening() {
    try {
      this.listeningValue = true
      this.updateButtonState()
      this.showStatus("Listening... Say a dietary preference")
      this.recognition.start()
    } catch (error) {
      console.error('Error starting recognition:', error)
      this.showError("Could not start voice recognition. Please check microphone permissions.")
      this.listeningValue = false
      this.updateButtonState()
    }
  }

  stopListening() {
    if (this.recognition) {
      this.recognition.stop()
    }
    this.listeningValue = false
    this.updateButtonState()
    this.hideStatus()
  }

  processVoiceCommand(transcript) {
    console.log('Voice command:', transcript)
    
    // Show what was heard
    this.showFeedback(`Heard: "${transcript}"`)

    // Check for clear/reset commands
    if (this.matchesCommand(transcript, this.commandPatterns.clear)) {
      this.clearFilters()
      return
    }

    // Check for help commands
    if (this.matchesCommand(transcript, this.commandPatterns.help)) {
      this.showHelp()
      return
    }

    // Extract dietary tag from command
    const dietaryTag = this.extractDietaryTag(transcript)
    
    if (dietaryTag) {
      this.applyDietaryFilter(dietaryTag)
    } else {
      this.showError(`Could not understand: "${transcript}". Try saying "vegan", "gluten-free", "vegetarian", etc.`)
    }
  }

  matchesCommand(transcript, patterns) {
    return patterns.some(pattern => transcript.includes(pattern))
  }

  extractDietaryTag(transcript) {
    // Remove filter command words
    let cleaned = transcript
    this.commandPatterns.filter.forEach(cmd => {
      cleaned = cleaned.replace(new RegExp(cmd, 'gi'), '').trim()
    })

    // Find matching dietary tag
    for (const [tag, keywords] of Object.entries(this.dietaryMappings)) {
      if (keywords.some(keyword => cleaned.includes(keyword) || transcript.includes(keyword))) {
        return tag
      }
    }

    // Direct tag match
    for (const tag of Object.keys(this.dietaryMappings)) {
      if (transcript.includes(tag.replace('-', ' ')) || transcript.includes(tag)) {
        return tag
      }
    }

    return null
  }

  applyDietaryFilter(tag) {
    // Dispatch custom event for menu filter controller
    const event = new CustomEvent('voice-filter', {
      detail: { dietaryTag: tag },
      bubbles: true
    })
    document.dispatchEvent(event)

    // Find and filter menu items directly
    const menuItems = document.querySelectorAll('[data-menu-filter-target="item"]')
    let visibleCount = 0

    menuItems.forEach(item => {
      const tags = JSON.parse(item.dataset.tags || '[]')
      const hasTag = tags.some(t => t.toLowerCase() === tag.toLowerCase())
      
      if (hasTag) {
        item.style.display = ''
        item.classList.remove('hidden')
        visibleCount++
      } else {
        item.style.display = 'none'
        item.classList.add('hidden')
      }
    })

    // Update count display
    const countElement = document.querySelector('[data-menu-filter-target="count"]')
    if (countElement) {
      countElement.textContent = `${visibleCount} ${visibleCount === 1 ? 'item' : 'items'}`
    }

    // Update status
    if (visibleCount > 0) {
      this.showSuccess(`Showing ${visibleCount} ${tag.replace('-', ' ')} item${visibleCount !== 1 ? 's' : ''}`)
    } else {
      this.showError(`No ${tag.replace('-', ' ')} items found`)
    }
    
    // Announce to screen readers
    this.announceToScreenReader(`Filtered menu to show ${visibleCount} ${tag.replace('-', ' ')} item${visibleCount !== 1 ? 's' : ''}`)
  }

  clearFilters() {
    // Dispatch clear event
    const event = new CustomEvent('voice-clear', {
      bubbles: true
    })
    document.dispatchEvent(event)

    // Clear visual filters
    const menuItems = document.querySelectorAll('[data-menu-filter-target="item"]')
    menuItems.forEach(item => {
      item.style.display = ''
      item.classList.remove('hidden')
    })

    // Update count display
    const countElement = document.querySelector('[data-menu-filter-target="count"]')
    if (countElement) {
      const totalCount = menuItems.length
      countElement.textContent = `${totalCount} ${totalCount === 1 ? 'item' : 'items'}`
    }

    // Reset filter buttons
    const filterButtons = document.querySelectorAll('[data-menu-filter-target="button"]')
    filterButtons.forEach(button => {
      button.classList.remove("bg-indigo-600", "text-white", "border-indigo-500", "shadow-lg")
      button.classList.add("bg-white", "text-gray-700", "border-gray-200", "hover:bg-gray-50")
    })

    this.showSuccess("Showing all items")
    this.announceToScreenReader("Filters cleared, showing all menu items")
  }

  showHelp() {
    const tags = Object.keys(this.dietaryMappings).join(', ')
    const message = `You can say: ${tags}, or "clear" to show all items`
    this.showInfo(message)
    this.announceToScreenReader(message)
  }

  updateButtonState() {
    if (this.hasButtonTarget) {
      const button = this.buttonTarget
      if (this.listeningValue) {
        button.classList.add('listening')
        button.setAttribute('aria-pressed', 'true')
        button.innerHTML = `
          <svg class="w-5 h-5 animate-pulse" fill="currentColor" viewBox="0 0 24 24">
            <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm-1-13h2v6h-2zm0 8h2v2h-2z"/>
          </svg>
          <span>Listening...</span>
        `
      } else {
        button.classList.remove('listening')
        button.setAttribute('aria-pressed', 'false')
        button.innerHTML = `
          <svg class="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M19 11a7 7 0 01-7 7m0 0a7 7 0 01-7-7m7 7v4m0 0H8m4 0h4m-4-8a3 3 0 01-3-3V5a3 3 0 116 0v6a3 3 0 01-3 3z"></path>
          </svg>
          <span>Voice Filter</span>
        `
      }
    }
  }

  showStatus(message) {
    if (this.hasStatusTarget) {
      this.statusTarget.textContent = message
      this.statusTarget.classList.remove('hidden')
    }
  }

  hideStatus() {
    if (this.hasStatusTarget) {
      this.statusTarget.classList.add('hidden')
    }
  }

  showFeedback(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      this.feedbackTarget.classList.remove('hidden', 'bg-red-100', 'text-red-800', 'bg-green-100', 'text-green-800', 'bg-blue-100', 'text-blue-800')
      this.feedbackTarget.classList.add('bg-gray-100', 'text-gray-800')
      
      setTimeout(() => {
        this.feedbackTarget.classList.add('hidden')
      }, 3000)
    }
  }

  showSuccess(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      this.feedbackTarget.classList.remove('hidden', 'bg-red-100', 'text-red-800', 'bg-gray-100', 'text-gray-800', 'bg-blue-100', 'text-blue-800')
      this.feedbackTarget.classList.add('bg-green-100', 'text-green-800')
      
      setTimeout(() => {
        this.feedbackTarget.classList.add('hidden')
      }, 3000)
    }
    this.showStatus(message)
  }

  showError(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      this.feedbackTarget.classList.remove('hidden', 'bg-green-100', 'text-green-800', 'bg-gray-100', 'text-gray-800', 'bg-blue-100', 'text-blue-800')
      this.feedbackTarget.classList.add('bg-red-100', 'text-red-800')
      
      setTimeout(() => {
        this.feedbackTarget.classList.add('hidden')
      }, 4000)
    }
    this.showStatus(message)
  }

  showInfo(message) {
    if (this.hasFeedbackTarget) {
      this.feedbackTarget.textContent = message
      this.feedbackTarget.classList.remove('hidden', 'bg-red-100', 'text-red-800', 'bg-green-100', 'text-green-800', 'bg-gray-100', 'text-gray-800')
      this.feedbackTarget.classList.add('bg-blue-100', 'text-blue-800')
      
      setTimeout(() => {
        this.feedbackTarget.classList.add('hidden')
      }, 5000)
    }
    this.showStatus(message)
  }

  handleRecognitionError(error) {
    let message = "Voice recognition error"
    
    switch(error) {
      case 'no-speech':
        message = "No speech detected. Please try again."
        break
      case 'audio-capture':
        message = "No microphone found. Please check your microphone."
        break
      case 'not-allowed':
        message = "Microphone permission denied. Please enable microphone access."
        break
      case 'network':
        message = "Network error. Please check your connection."
        break
      default:
        message = `Error: ${error}`
    }
    
    this.showError(message)
    this.listeningValue = false
    this.updateButtonState()
  }

  announceToScreenReader(message) {
    const announcement = document.createElement('div')
    announcement.setAttribute('role', 'status')
    announcement.setAttribute('aria-live', 'polite')
    announcement.setAttribute('aria-atomic', 'true')
    announcement.className = 'sr-only'
    announcement.textContent = message
    document.body.appendChild(announcement)
    
    setTimeout(() => {
      document.body.removeChild(announcement)
    }, 1000)
  }

  disconnect() {
    this.stopListening()
  }
}

