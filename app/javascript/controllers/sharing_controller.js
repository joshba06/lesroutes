import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="sharing"
export default class extends Controller {
  static targets = ["link"]
  static values = {
    routeUrl: String,
  };

  connect() {
    this.subject = "LesRoutes - Route Link"
    const link = this.routeUrlValue.replace(/\s/g, "%20").replace(/\|/g, "%7C").replace(/,/, "%2C")
    this.body = `Hey mate, check out this route:\n\n${link}\n\nI found it on a free website called lesroutes.co.uk that lets you create and manage routes for Google Maps.`
    console.log(this.body)
  }

  send_email () {
    window.location.href = "mailto:?subject=" + encodeURIComponent(this.subject) + "&body=" + encodeURIComponent(this.body);

  }

  send_whatsapp () {
    window.location.href = `https://wa.me/?text=${encodeURIComponent(this.body)}`;
  }

  send_sms () {
    if(navigator.userAgent.match(/Android/i)) {
      window.open(`sms://1234/?body=${encodeURIComponent(this.body)}`)
    }
    else if(navigator.userAgent.match(/iPhone/i)) {
      window.open(`sms://1234/&body=${encodeURIComponent(this.body)}`)
     }
  }
}
