import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sharing"
export default class extends Controller {
  static targets = ["link"]
  static values = {
    message: String,
    subject: String,
    routeUrl: String,
  };

  connect() {
    console.log("Hello from sharing controller")
  }

  send_email () {
    window.location.href = `mailto:Mate?subject=${this.subjectValue}&body=${encodeURIComponent(this.messageValue)}`;
  }

  send_whatsapp () {
    window.location.href = `https://wa.me/?text=${encodeURIComponent(this.messageValue)}`;
  }

  send_sms () {
    if(navigator.userAgent.match(/Android/i)) {
      window.open(`sms://Mate/?body=${encodeURIComponent(this.messageValue)}`)
    }
    else if(navigator.userAgent.match(/iPhone/i)) {
      window.open(`sms://Mate/&body=${encodeURIComponent(this.messageValue)}`)
     }
  }
}
