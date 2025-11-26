module OnboardingHelper
  def step_title(step)
    titles = {
      1 => "Restaurant Information",
      2 => "Add Menu Items",
      3 => "Generate QR Code",
      4 => "Choose Subscription",
      5 => "You're All Set!"
    }
    titles[step] || "Step #{step}"
  end

  def step_description(step)
    descriptions = {
      1 => "Tell us about your restaurant",
      2 => "Add your menu items (you can add more later)",
      3 => "Download your QR code to display",
      4 => "Select a plan to unlock features (optional)",
      5 => "Your restaurant is ready to go!"
    }
    descriptions[step] || ""
  end
end
