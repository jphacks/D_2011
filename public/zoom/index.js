var mn = '99020754787';
var pwd = '035030';
var email = 'i@mizu.coffee';
const userName = 'aika';

(async function () {
  ZoomMtg.preLoadWasm();
  ZoomMtg.prepareJssdk();

  const signature = await generateSignature(mn);
  await initMeeting();
  await joinMeeting(mn, signature);

  ZoomMtg.getAttendeeslist({
    success: function (res) {
      console.log('success getAttendeeslist', res);
    },
  });
  ZoomMtg.getCurrentUser({
    success: function (res) {
      console.log('success getCurrentUser', res.result.currentUser);
    },
  });
})();

function generateSignature(meetingNumber) {
  return new Promise((resolve, reject) => {
    ZoomMtg.generateSignature({
      meetingNumber,
      apiKey: API_KEY,
      apiSecret: API_SECRET,
      role: 0,
      success: (res) => resolve(res.result),
      error: (res) => reject(res),
    });
  });
}

function initMeeting() {
  return new Promise((resolve, reject) => {
    ZoomMtg.init({
      leaveUrl: '/zoom/index.html',
      success: (res) => resolve(res),
      error: (res) => reject(res),
    });
  });
}

async function joinMeeting(meetingNumber, signature) {
  return new Promise((resolve, reject) => {
    ZoomMtg.join({
      meetingNumber,
      userName,
      signature,
      apiKey: API_KEY,
      userEmail: email,
      passWord: pwd,
      success: (res) => resolve(res),
      error: (res) => reject(res),
    });
  });
}
