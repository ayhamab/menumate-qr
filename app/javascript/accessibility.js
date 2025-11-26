// Accessibility enhancements for MenuMate QR

// Announce dynamic content changes to screen readers
export function announceToScreenReader(message, priority = 'polite') {
  const liveRegion = document.getElementById('aria-live-region');
  if (liveRegion) {
    liveRegion.setAttribute('aria-live', priority);
    liveRegion.textContent = message;
    
    // Clear after announcement
    setTimeout(() => {
      liveRegion.textContent = '';
    }, 1000);
  }
}

// Enhanced keyboard navigation
document.addEventListener('DOMContentLoaded', function() {
  // Skip link focus management
  const skipLinks = document.querySelectorAll('a[href^="#"]');
  skipLinks.forEach(link => {
    link.addEventListener('click', function(e) {
      const targetId = this.getAttribute('href').substring(1);
      const target = document.getElementById(targetId);
      if (target) {
        e.preventDefault();
        target.setAttribute('tabindex', '-1');
        target.focus();
        target.scrollIntoView({ behavior: 'smooth', block: 'start' });
      }
    });
  });

  // Enhanced form field announcements
  const formFields = document.querySelectorAll('input, select, textarea');
  formFields.forEach(field => {
    // Announce errors
    field.addEventListener('invalid', function() {
      const errorMessage = this.getAttribute('aria-describedby');
      if (errorMessage) {
        const errorElement = document.getElementById(errorMessage);
        if (errorElement) {
          announceToScreenReader(errorElement.textContent, 'assertive');
        }
      }
    });

    // Announce value changes for screen readers
    if (field.type === 'range' || field.type === 'number') {
      field.addEventListener('input', function() {
        const label = this.getAttribute('aria-label') || this.getAttribute('name');
        announceToScreenReader(`${label}: ${this.value}`, 'polite');
      });
    }
  });

  // Enhanced button announcements
  const buttons = document.querySelectorAll('button[data-action]');
  buttons.forEach(button => {
    button.addEventListener('click', function() {
      const actionText = this.getAttribute('aria-label') || this.textContent.trim();
      if (actionText) {
        announceToScreenReader(`${actionText} activated`, 'polite');
      }
    });
  });

  // Modal and dialog accessibility
  const modals = document.querySelectorAll('[role="dialog"]');
  modals.forEach(modal => {
    modal.addEventListener('keydown', function(e) {
      if (e.key === 'Escape') {
        const closeButton = modal.querySelector('[aria-label*="close" i], [aria-label*="Close" i]');
        if (closeButton) {
          closeButton.click();
        }
      }
    });
  });

  // Enhanced focus management for dynamic content
  const observer = new MutationObserver(function(mutations) {
    mutations.forEach(function(mutation) {
      if (mutation.addedNodes.length) {
        mutation.addedNodes.forEach(function(node) {
          if (node.nodeType === 1) { // Element node
            // Focus first focusable element in new content
            const focusable = node.querySelector('button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])');
            if (focusable && node.hasAttribute('data-autofocus')) {
              setTimeout(() => focusable.focus(), 100);
            }
          }
        });
      }
    });
  });

  observer.observe(document.body, {
    childList: true,
    subtree: true
  });

  // Reduced motion support
  if (window.matchMedia('(prefers-reduced-motion: reduce)').matches) {
    document.documentElement.style.setProperty('--transition-duration', '0.01ms');
  }
});

// Export for use in Stimulus controllers
window.announceToScreenReader = announceToScreenReader;

