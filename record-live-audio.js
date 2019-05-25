// This example uses MediaRecorder to record from a live audio stream,
// and uses the resulting blob as a source for an audio element.
//
// The relevant functions in use are:
//
// navigator.mediaDevices.getUserMedia -> to get audio stream from microphone
// MediaRecorder (constructor) -> create MediaRecorder instance for a stream
// MediaRecorder.ondataavailable -> event to listen to when the recording is ready
// MediaRecorder.start -> start recording
// MediaRecorder.stop -> stop recording (this will generate a blob of data)
// URL.createObjectURL -> to create a URL from a blob, which we can use as audio src

var recordButton, stopButton, recorder,audioBlob;

function validateParameters () {
      return true;
    }
  
function saveToDB () {
   var firebaseConfig = {
       apiKey: 'AIzaSyCgiteS_RLLeOh52Fyo-NtHNaPmvvWRiak',
       authDomain: 'test-254a6.firebaseapp.com',
       projectId: 'test-254a6',
       storageBucket: 'gs://test-254a6.appspot.com/'
    };

    // Initialize Firebase
firebase.initializeApp(firebaseConfig);
var storage = firebase.storage();
var storageRef = storage.ref();
var audio_filename = "audio_"+new Date().getTime();
var audioRef = storageRef.child('audios/'+audio_filename);
var db = firebase.firestore();
document.getElementById("add_snippet_button").onclick = function(e){ 
if (validateParameters ()) {
    audioRef.put(audioBlob).then(function(snapshot) {
    
  console.log('Uploaded a blob or file!');

   audioRef.getDownloadURL().then(function(url) {

  audio_filename = url;
  let card_title = document.getElementById("snippet_title").value;
    let card_description = document.getElementById("snippet_desc").value;
    let  my_snippet = {
      card_title:card_title,
      card_description: card_description,
      audio_file:audio_filename,
      delay: 0,
      sort_order:1
    }
    console.log (my_snippet);
    db.collection("lessons").add(my_snippet).then(function(docRef) {
    console.log("Document written with ID: ", docRef.id);
    alert ("Thank you for teaching us. please contact me on whatsapp 9820011185 to receive your money.");
})
.catch(function(error) {
    console.error("Error adding document: ", error);
});
    document.getElementById("snippet_title").value = "";
    document.getElementById("snippet_desc").value = "";


    
    });
});


  
  }
   }
}

window.onload = function () {
 
  recordButton = document.getElementById('record');
  stopButton = document.getElementById('stop');
  saveToDB ();
  // get audio stream from user's mic
  navigator.mediaDevices.getUserMedia({
    audio: true
  })
  .then(function (stream) {
    recordButton.disabled = false;
    recordButton.addEventListener('click', startRecording);
    stopButton.addEventListener('click', stopRecording);
    recorder = new MediaRecorder(stream);

    // listen to dataavailable, which gets triggered whenever we have
    // an audio blob available
    recorder.addEventListener('dataavailable', onRecordingReady);
  });
};

function startRecording() {
  recordButton.disabled = true;
  stopButton.disabled = false;

  recorder.start();
}

function stopRecording() {
  recordButton.disabled = false;
  stopButton.disabled = true;

  // Stopping the recorder will eventually trigger the `dataavailable` event and we can complete the recording process
  recorder.stop();
}

function onRecordingReady(e) {
  var audio = document.getElementById('audio');
  audioBlob = e.data;
  // e.data contains a blob representing the recording
  audio.src = URL.createObjectURL(e.data);
  audio.play();
}