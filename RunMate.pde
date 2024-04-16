import beads.*;
import org.jaudiolibs.beads.*;
import controlP5.*;
import guru.ttslib.*;

ControlP5 p5;
Gain globalGain;
BiquadFilter lpFilter;

TextToSpeechMaker ttsMaker;
NotificationServer notificationServer;
MyNotificationListener myNotificationListener;

PFont bigFont;

PImage heartRateImg;
PImage exertionLevelImg;
PImage backGroundImg;
PImage feedbackImg;
PImage playPauseImg;

int heartBPM = 75;
int exertionLevel;
int bloodPressure;
int cadenceSteps;

int lastChangeTime = 1000;

int lastFeedback = 3500;
int lastPushed = 0;
int intervalFeedback = 7200;

long lastEventTime = 0;

int interval = 2000;

int temp = 0;

int priority; 
String eventDataJSON = "notification.json";
ArrayList<Notification> notifications;


SamplePlayer heartBeatSound;
SamplePlayer backgroundMusic;
SamplePlayer currentTTS = null;

int workoutIntensity = 0;
int workoutState = 0;
int updateState = 0;

boolean lastRandom = false;

long currentTime = 0;

public static PriorityQueue<PriorityItem> pq;

Reverb rb;

void setup() {
  size(600, 400);
  p5 = new ControlP5(this);
  ac = new AudioContext();
  globalGain = new Gain(ac, 2, 0.5f);
  
  pq = new PriorityQueue<>();
 
 lpFilter = new BiquadFilter(ac, BiquadFilter.Type.LP, 10000, 0.707);
  
  ttsMaker = new TextToSpeechMaker();
  notificationServer = new NotificationServer();
  bigFont = createFont("Arial", 13);
  
  heartRateImg = loadImage("./Images/HeartRate.png");
  heartRateImg.resize(100, 0);
  exertionLevelImg = loadImage("./Images/ExertionLevel.png");
  exertionLevelImg.resize(75, 0);
  feedbackImg = loadImage("./Images/Feedback.png");
  feedbackImg.resize(90, 0);
  playPauseImg = loadImage("./Images/PlayPause.png");
  playPauseImg.resize(90, 0);
  backGroundImg = loadImage("./Images/Background.png");
  
  
  p5.addButton("minimalExertion")
    .setPosition(170, 200)
    .setSize(100, 20)
    .setLabel("Light")
    .activateBy(ControlP5.RELEASE);
  
  p5.addButton("moderateExertion")
  .setPosition(170, 230)
  .setSize(100, 20)
  .setLabel("Moderate")
  .activateBy(ControlP5.RELEASE);
  
   p5.addButton("hardExertion")
    .setPosition(170, 260) 
    .setSize(100, 20)
    .setLabel("Hard")
    .activateBy(ControlP5.RELEASE);
  
  
  p5.addButton("startEventStream")
    .setPosition(430, 200)
    .setSize(100, 20)
    .setLabel("Start")
    .activateBy(ControlP5.RELEASE);
  
  p5.addButton("pauseEventStream")
  .setPosition(430, 230)
  .setSize(100, 20)
  .setLabel("Pause")
  .activateBy(ControlP5.RELEASE);
  
 p5.addButton("stopEventStream")
  .setPosition(430, 260) 
  .setSize(100, 20)
  .setLabel("Stop")
  .activateBy(ControlP5.RELEASE);
  
  p5.addButton("AllUpdates")
    .setPosition(300, 200)
    .setSize(100, 20)
    .setLabel("All")
    .activateBy(ControlP5.RELEASE);
  
  p5.addButton("PhysiologicalUpdates")
  .setPosition(300, 230)
  .setSize(100, 20)
  .setLabel("Physiological")
  .activateBy(ControlP5.RELEASE);
  
 p5.addButton("EnvironmentalUpdates")
  .setPosition(300, 260) 
  .setSize(100, 20)
  .setLabel("Environmental")
  .activateBy(ControlP5.RELEASE);
   
   
  p5.addSlider("VolumeControl")
  .setPosition(50, 350)
  .setSize(450, 30)
  .setRange(0, 100)
  .setValue(50)
  .setLabel("Volume")
  .getCaptionLabel()
  .setFont(bigFont)
  .setColor(color(0)); 
  
  p5.addSlider("LPFControl")
  .setPosition(50, 310)
  .setSize(450, 30)
  .setRange(100, 10000) 
  .setValue(5000) 
  .setLabel("LPF")
  .getCaptionLabel()
  .setFont(bigFont)
  .setColor(color(0));
  
  
  notificationServer = new NotificationServer();
  
  myNotificationListener = new MyNotificationListener();
  notificationServer.addListener(myNotificationListener);
  
  
  heartBeatSound = getSamplePlayer("HeartBeat.wav");
  heartBeatSound.pause(true);
  
  backgroundMusic = getSamplePlayer("BackgroundMusic.wav");
  backgroundMusic.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);

  ttsPlayback("Welcome to RunMate.");
  
  lpFilter.addInput(backgroundMusic);
  lpFilter.addInput(heartBeatSound);
  globalGain.addInput(lpFilter); 
  ac.out.addInput(globalGain);
  ac.start();
  
}

void draw() {
  image(backGroundImg, 0, 0);
  image(heartRateImg, 29, 97);
  image(exertionLevelImg, 175, 66);
  image(playPauseImg, 430, 71);
  image(feedbackImg, 303, 58);
  
  fill(0);
  textSize(32);
  if (heartBPM < 100)text(heartBPM, 62, 153);
  else text(heartBPM, 54, 153);
  
  textSize(18);
  text("Updates:", 315, 190);
  text("Workout:", 445, 190);
  text("Intensity:", 185, 190);
  
  textSize(15);
  text("Exertion Level: " + exertionLevel, 25, 215);
  text("Blood Pressure: " + bloodPressure, 25, 245);
  text("Steps Cadence: " + cadenceSteps, 25, 275);
  
  if (millis() - lastChangeTime > interval) {
    heartBPM = updateHeartBPM();
    exertionLevel = updateExertionLevel();
    bloodPressure = updateBloodPressure();
    cadenceSteps = updateStepsCadence();
    lastChangeTime = millis();
  }
  
  while (pq.size() != 0 && millis() - lastFeedback > intervalFeedback) {
    PriorityItem notif = pq.poll();
    if (notif.getPriority() == 0 && updateState == 2) return;
    ttsPlayback(notif.getValue());
    lastFeedback = millis();
  }
  
  if (workoutState == 1) currentTime = millis();
  if ((currentTime - lastEventTime) >= 170000 && workoutState == 1) {
    pq = new PriorityQueue<>();
    notificationServer.stopEventStream();
    notificationServer.loadEventStream(eventDataJSON);
    lastEventTime = currentTime;
  }
  
  if(((workoutIntensity == 1 && heartBPM == 95) || (workoutIntensity == 2 && heartBPM == 121)
      || (workoutIntensity == 3 && heartBPM == 146)) && millis() - lastFeedback > intervalFeedback) {
    pq.add(new PriorityItem(0, "Pick Up the Pace You Can Do More, Your current hearbeat is :" + heartBPM));
  } else if (((workoutIntensity == 1 && heartBPM == 100) || (workoutIntensity == 2 && heartBPM == 126)
      || (workoutIntensity == 3 && heartBPM == 151)) && millis() - lastFeedback > intervalFeedback) {
    pq.add(new PriorityItem(0, "Perfect Pace Keep It Up, Your current cadence is :" + cadenceSteps));
  } else if (((workoutIntensity == 1  && heartBPM == 106) || (workoutIntensity == 2 && heartBPM == 132)
      || (workoutIntensity == 3 && heartBPM == 167)) && millis() - lastFeedback > intervalFeedback) {
    pq.add(new PriorityItem(0, "Slow Down You are Pushing Too Hard, Your current blood pressure is :" + bloodPressure));
  }
}

public void minimalExertion() {
  ttsPlayback("Light Intensity Chosen");
  workoutIntensity = 1;
}

public void moderateExertion() {
  ttsPlayback("Moderate Intensity Chosen");
  workoutIntensity = 2;
}

public void hardExertion() {
  ttsPlayback("Hard Intensity Chosen");
  workoutIntensity = 3;
}

public void VolumeControl(float value) {
  float gainValue = value / 100.0;
  globalGain.setGain(gainValue);  
}

void LPFControl(float frequency) {
  lpFilter.setFrequency(frequency);
}


void startEventStream(int value) {
  if(workoutIntensity == 0) {
    ttsPlayback("Please choose an intensity before starting your workout");
    return;
  }
  if (workoutState == 0) {
    workoutState = 1;
    lastFeedback = millis();
    ttsPlayback("Workout Started");
    heartBeatSound.setLoopType(SamplePlayer.LoopType.LOOP_FORWARDS);
    backgroundMusic.pause(true);
    heartBeatSound.start();
    notificationServer.loadEventStream(eventDataJSON);
  }
}

void pauseEventStream(int value) {
  if (workoutState == 1) {
    ttsPlayback("Workout Paused");
    backgroundMusic.pause(false);
    heartBeatSound.pause(true);
    notificationServer.pauseEventStream();
    workoutIntensity = 0;
    workoutState = 0;
  }
}

void stopEventStream(int value) {
  if (workoutState == 1) {
    ttsPlayback("Workout Ended");
    heartBeatSound.pause(true);
    backgroundMusic.pause(false);
    notificationServer.stopEventStream();
    workoutIntensity = 0;
    workoutState = 0;
    temp = 0;
  }
}

void AllUpdates() {
  updateState = 0;
  ttsPlayback("All Updates Activated"); 
}

void PhysiologicalUpdates() {
  updateState = 1;
  ttsPlayback("Physiological Updates Only"); 
}

void EnvironmentalUpdates() {
 updateState = 2;
 ttsPlayback("Environmental Updates Only"); 
}

void ttsPlayback(String inputSpeech) {
    if (inputSpeech == null) return;
    if (currentTTS != null && !currentTTS.isPaused()) {
        currentTTS.pause(true);
        ttsMaker.cleanTTSDirectory();
        currentTTS = null;
    }

    String ttsFilePath = ttsMaker.createTTSWavFile(inputSpeech);
    if (ttsFilePath != null) {
      SamplePlayer sp = getSamplePlayer(ttsFilePath, true);
    
      Envelope ttsEnvelope = new Envelope(ac, 0);
      
      Gain ttsGain = new Gain(ac, 2, ttsEnvelope);
      ttsGain.addInput(sp);
      ttsEnvelope.addSegment(0.6f, 200);
      ttsEnvelope.addSegment(0.6f, 2000);
      ttsEnvelope.addSegment(0, 50);
      currentTTS = sp; 
      globalGain.addInput(sp);
      sp.setToLoopStart();
      sp.start();
    }
}
