const email = "aika.tgch@gmail.com";
const userName = "aika";

let isJoined = false
let attendeesList = null
let currentUser = null
let status = false;

async function initialize(mn, pwd) {
  ZoomMtg.preLoadWasm();
  ZoomMtg.prepareJssdk();

  const signature = await generateSignature(mn);
  await initMeeting();
  ZoomMtg.inMeetingServiceListener('onMeetingStatus', function (data) {
    status = data.meetingStatus == 2 || status
    if(data.meetingStatus == 3) window.location.href = "http://example.com"
  });
  await joinMeeting(mn, signature, pwd);

  isJoined = true;
}

function isCoHost() {
  let flag = false
  for(e of document.querySelectorAll('.footer-button__button-label')) {
    if(e.innerText.match(/Manage Participants/)) flag = true
  }
  return flag
}

function getStatus() {
  return status
}

function updateAttendeesList() {
  attendeesList = null
  ZoomMtg.getAttendeeslist({
    success: function (res) {
      attendeesList = res.result.attendeesList
    },
  });
}

function getAttendeesList() {
  return attendeesList
}

function updateCurrentUser() {
  currentUser = null
  ZoomMtg.getCurrentUser({
    success: function (res) {
      currentUser = res.result
    },
  });
}

function getCurrentUser() {
  return currentUser
}

function mute(userId, mute) {
  ZoomMtg.mute({userId, mute});
}

function muteAll(mute) {
  ZoomMtg.muteAll({muteAll: mute});
}

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
      leaveUrl: "http://example.com/",
      success: (res) => resolve(res),
      error: (res) => reject(res),
    });
  });
}

async function joinMeeting(meetingNumber, signature, pwd) {
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
