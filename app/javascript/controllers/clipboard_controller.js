import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input"];
  static values = {
    feedbackText: String
  }

  connect() {
    console.log("clipboard controller hellow");
  }

  copy(event) {
    console.log("Just copied this:")
    console.log(this.inputTarget.value)
    // console.log(event)
    // this.inputTarget.select();
    navigator.clipboard.writeText(this.inputTarget.value);

    // document.execCommand('copy');
    event.currentTarget.disabled = true;
    event.currentTarget.innerText = this.feedbackTextValue;
  }
}
