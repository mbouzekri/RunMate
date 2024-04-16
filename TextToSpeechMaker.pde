import com.sun.speech.freetts.FreeTTS;
import com.sun.speech.freetts.Voice;
import com.sun.speech.freetts.VoiceManager;

class TextToSpeechMaker {
  final String TTS_FILE_DIRECTORY_NAME = "tts_samples";
  final String TTS_FILE_PREFIX = "tts";
  
  File ttsDir;
  boolean isSetup = false;
  
  int fileID = 0;
  FreeTTS freeTTS;
  
  private Voice voice;
    
  public TextToSpeechMaker() {
    System.setProperty("freetts.voices", "com.sun.speech.freetts.en.us.cmu_us_kal.KevinVoiceDirectory");
    VoiceManager voiceManager = VoiceManager.getInstance();
    voice = voiceManager.getVoice("kevin16");
    
    findTTSDirectory();
    cleanTTSDirectory();
    
    freeTTS = new FreeTTS(voice);
    freeTTS.setMultiAudio(true);
    freeTTS.setAudioFile(getTTSFilePath() + "/" + TTS_FILE_PREFIX + ".wav");
    
    freeTTS.startup();
    voice.allocate();
  }
  
  public String createTTSWavFile(String input) {
    String filePath = TTS_FILE_DIRECTORY_NAME + "/" + TTS_FILE_PREFIX + Integer.toString(fileID) + ".wav";
    fileID++;
    voice.speak(input);
    return filePath; //you will need to use dataPath(filePath) if you need the full path to this file, see Example
  }
  void cleanup() {
    voice.deallocate();
    freeTTS.shutdown();
  }
  
  String getTTSFilePath() {
    return dataPath(TTS_FILE_DIRECTORY_NAME);
  }
  
  //finds the tts file directory under the data path and creates it if it does not exist
  void findTTSDirectory() {
    File dataDir = new File(dataPath(""));
    if (!dataDir.exists()) {
      try {
        dataDir.mkdir();
      }
      catch(SecurityException se) {
        println("Data directory not present, and could not be automatically created.");
      }
    }
    
    ttsDir = new File(getTTSFilePath());
    boolean directoryExists = ttsDir.exists();
    if (!directoryExists) {
      try {
        ttsDir.mkdir();
        directoryExists = true;
      }
      catch(SecurityException se) {
        
        println("Error creating tts file directory '" + TTS_FILE_DIRECTORY_NAME + "' in the data directory.");
      }
    }
  }
  
  void cleanTTSDirectory() {
    //delete existing files
    if (ttsDir.exists()) {
      for (File file: ttsDir.listFiles()) {
        if (!file.isDirectory())
          file.delete();
      }
    }
  }
}
