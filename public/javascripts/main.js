let form = document.querySelector('#code-break');
const CODESIZE = form.dataset.codeSize;
const MIN = form.dataset.min;
const MAX = form.dataset.max;

function convertGuess(guess) {
  digits = guess.split('').map(chr => parseInt(chr))
  return digits
};

// digits must either be passed in or be defined in scope
function validateRange(digits) {
  if (digits.length != CODESIZE) {
    return false
  };

  validity = true
  digits.forEach((item, i) => {
    if (item < MIN || item > MAX) {
      validity = false
    };
  });

  return validity
}

$(function() {
  $("form#code-break").submit(function(event) {
    event.preventDefault();
    event.stopPropagation();

    let data = $('form#code-break').serialize()
    let input = data.match(/\d+/)[0]
    let digits = convertGuess(input)

    if (validateRange(digits)) {
      console.log("ran")

      form = $(this)
      console.log(form)

      var request = $.ajax({
        url: form.attr("action"),
        method: form.attr("method"),
        data: $("input#guess")
      })

      request.done(function(data, textStatus, jqXHR) {
        if (jqXHR.status === 204) {

        } else if (jqXHR.status === 200) {

        }
      })
    } else {
      console.log("Invalid input") // PUT FLASH MESSAGE HERE
    }
  })
});
