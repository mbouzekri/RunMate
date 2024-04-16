AudioContext ac;

Sample getSample(String fileName) {
 return SampleManager.sample(dataPath(fileName)); 
}

SamplePlayer getSamplePlayer(String fileName, Boolean killOnEnd) {
  SamplePlayer player = null;
  try {
    player = new SamplePlayer(ac, getSample(fileName));
    player.setKillOnEnd(killOnEnd);
    player.setName(fileName);
  }
  catch(Exception e) {
    println("Exception while attempting to load sample: " + fileName);
    e.printStackTrace();
    exit();
  }
  
  return player;
}

SamplePlayer getSamplePlayer(String fileName) {
  return getSamplePlayer(fileName, false);
}


int updateHeartBPM() {
  if (workoutIntensity == 1 && workoutState == 1) return int(random(95, 107));
  else if (workoutIntensity == 2 && workoutState == 1) return int(random(121, 133));
  else if (workoutIntensity == 3 && workoutState == 1) return int(random(146, 168));
  
  return int(random(75, 83));
}

int updateExertionLevel() {
  if (workoutIntensity == 1 && workoutState == 1) return int(random(1, 4));
  else if (workoutIntensity == 2 && workoutState == 1) return int(random(4, 8));
  else if (workoutIntensity == 3 && workoutState == 1) return int(random(8, 11));
  
  return 0;
}

int updateBloodPressure() {
  if (workoutIntensity == 1 && workoutState == 1) return int(random(131, 155));
  else if (workoutIntensity == 2 && workoutState == 1) return int(random(161, 187));
  else if (workoutIntensity == 3 && workoutState == 1) return int(random(193, 205));
  
  return int(random(107, 115));
}

int updateStepsCadence() {
  if (workoutIntensity == 1 && workoutState == 1) return int(random(71, 93));
  else if (workoutIntensity == 2 && workoutState == 1) return int(random(97, 132));
  else if (workoutIntensity == 3 && workoutState == 1) return int(random(135, 167));
  
  return 0;
}
