let form = document.querySelector('#code-break');
const CODESIZE = form.dataset.codeSize;
const MIN = form.dataset.min;
const MAX = form.dataset.max;

function convertGuess(guess) {
  digits = guess.split('').map(chr => parseInt(chr))
  return digits
};

// digits must either be passed in or be defined in scope
function validateInput(string) {
  if (string.length != CODESIZE) {
    return false
  }

  validity = true
  let digits = convertGuess(string)
  digits.forEach((n, i) => {
    if (n < MIN || n > MAX || Number.isNaN(n)) {
      validity = false
    }
  })
  return validity
}

$(function() {
  $("form#code-break").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();

    let data = $('form#code-break').serialize()
    let input = data.split('=')[1]

    if (validateInput(input)) {
      $("#invalid").css("visibility", "hidden")

      let digits = convertGuess(input)
      form = $(this)

      var request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method"),
        data: $("input#guess")
      })

      request.done(function(data, textStatus, jqXHR) {
        let guessStatus = data.slice(0, 1)
        data = data.slice(1, 8)

        // if (jqXHR.status === 204) {
        if (guessStatus == '1' || guessStatus == '2') {
          window.location.href = "/play/code_breaker";
        } else if (jqXHR.status === 200) {
          $("#clues").append(
            `<li>${input}: ${data}</li>`
          )

          // $("#input").val(""); TRYING TO CLEAR INPUT FIELD
        }
      })
    } else {
      $("#invalid").css("visibility", "visible") // FLASH MESSAGE
    }
  })
});
