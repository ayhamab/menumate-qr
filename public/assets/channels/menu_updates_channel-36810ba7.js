import consumer from "channels/consumer"
import { Turbo } from "@hotwired/turbo-rails"

document.addEventListener("DOMContentLoaded", () => {
  const restaurantId = document.body.dataset.restaurantId || 
                       document.querySelector("[data-restaurant-id]")?.dataset.restaurantId
  
  if (restaurantId) {
    consumer.subscriptions.create(
      { channel: "MenuUpdatesChannel", restaurant_id: restaurantId },
      {
        connected() {
          console.log("Connected to MenuUpdatesChannel for restaurant", restaurantId)
        },

        disconnected() {
          console.log("Disconnected from MenuUpdatesChannel")
        },

        received(data) {
          console.log("Received menu update:", data)
          
          if (data.action === "refresh_menu") {
            // Reload the menu page to show updated content
            if (window.location.pathname.includes('/menu')) {
              Turbo.visit(window.location.href, { action: "replace" })
            }
          } else if (data.action && data.target) {
            // Handle Turbo Stream actions for admin view
            const target = document.getElementById(data.target)
            if (target) {
              switch(data.action) {
                case "append":
                  if (data.html) {
                    const container = document.getElementById("menu_items_container") || 
                                     document.querySelector("[data-sortable-target='element']")
                    if (container) {
                      container.insertAdjacentHTML("beforeend", data.html)
                    }
                  }
                  break
                case "replace":
                  if (data.html) {
                    target.outerHTML = data.html
                  }
                  break
                case "remove":
                  target.remove()
                  break
              }
            }
          }
        }
      }
    )
  }
})
