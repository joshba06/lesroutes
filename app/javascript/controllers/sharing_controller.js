import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sharing"
export default class extends Controller {
  static targets = ["link"]
  static values = {
    routeUrl: String,
  };

  connect() {
    this.subject = "LesRoutes - Route Link"
    this.message = `Hey mate, check out this route:\n\n${this.routeUrlValue}\n\nI found it on a free website called lesroutes.co.uk that lets you create and manage routes for Google Maps.`
  }

  send_email () {
    window.location.href = `mailto:"Mate"?subject=${this.subject}&body=${encodeURIComponent(this.message)}`;
  }

  send_whatsapp () {
    window.location.href = `https://wa.me/?text=${encodeURIComponent(this.message)}`;
  }

  send_sms () {
    if(navigator.userAgent.match(/Android/i)) {
      window.open(`sms://1234/?body=${encodeURIComponent(this.message)}`)
    }
    else if(navigator.userAgent.match(/iPhone/i)) {
      window.open(`sms://1234/&body=${encodeURIComponent(this.message)}`)
     }
  }
}
