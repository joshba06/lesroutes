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
    window.location.href = `mailto:''?subject=${this.subjectValue}&body=${encodeURIComponent(this.messageValue)}`;
  }

  send_sms () {
    if(navigator.userAgent.match(/Android/i)) {
      window.open(`sms://1900/?body=${encodeURIComponent(this.messageValue)}, '_blank'`)
    }
    else if(navigator.userAgent.match(/iPhone/i)) {
      window.open(`sms://1900/&body=${encodeURIComponent(this.messageValue)},'_blank`)
     }
  }
  copy_link (event) {
    event.stopPropagation();
    event.preventDefault();

    console.log(`Copied link: ${this.routeUrlValue}`)
    const clipboardText = this.routeUrlValue

    // Copy the text inside the text field
    navigator.clipboard.writeText(clipboardText);

    // clipboardText.setSelectionRange(0, 99999); // For mobile devices

    // Copy the text inside the text field
    navigator.clipboard.writeText(clipboardText);

    this.linkTarget.disabled = true;
    this.linkTarget.innerText = "Copied"

    // Alert the copied text
    alert("Copied the text: " + clipboardText);


  }
}
