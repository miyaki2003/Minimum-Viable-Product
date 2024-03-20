import $ from 'jquery';
document.addEventListener("DOMContentLoaded", function() {

  const liffAppElement = document.getElementById('liff-app');
  if (liffAppElement) {
    const liffId = "2003779201-OwqpG72P";
    initializeLiff(liffId);
  }
});

function initializeLiff(liffId) {
  liff.init({
      liffId: liffId
  }).then(() => {
      if (!liff.isLoggedIn()) {
          liff.login();
      }
  }).catch((err) => {
      console.log('LIFF Initialization failed ', err);
  });
}

$(document).on('submit', 'form', function(e) {
  e.preventDefault();

  const title = $('input[name="title"]').val();
  const time = $('input[name="time"]').val();
  const notificationTime = $('input[name="notification_time"]').val();
  const message = `タイトル: ${title}\n時間: ${time}\n通知時間: ${notificationTime} 分前`;

  if (liff.isInClient()) {
      sendText(message);
  } else {
      alert('LIFF外からのメッセージ送信はできません');
  }
});

function sendText(text) {
  liff.sendMessages([{
      'type': 'text',
      'text': text
  }]).then(() => {
      liff.closeWindow();
  }).catch((error) => {
      console.error('Failed to send message ' + error);
  });
}