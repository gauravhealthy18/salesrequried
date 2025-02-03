document.addEventListener('DOMContentLoaded', function() {
  const uploadForm = document.getElementById('upload-form');
  const sendButton = document.getElementById('send-report');

  uploadForm.addEventListener('submit', function(e) {
    e.preventDefault();
  });

  sendButton.addEventListener('click', function() {
    const email = document.getElementById('recipient-email').value;
    const formData = new FormData(uploadForm);
    formData.append('email', email);

    fetch('/stock/upload', {
      method: 'POST',
      body: formData
    })
    .then(response => response.json())
    .then(data => {
      if (data.success) {
        bootstrap.Modal.getInstance(document.getElementById('emailModal')).hide();
        alert('Report sent successfully to ' + email);
      }
    });
  });
});
