enum NotificationType {Physiological, Environmental}

class Notification {
  NotificationType type;
  int priority;
  int timestamp;

  String runningForm;
  String footStrikePattern;
  
  String terrainType;
  String weatherCondition;
  
  String message;
  
  public Notification(JSONObject json) {
    String typeString = json.getString("type");
    
    this.type = NotificationType.valueOf(typeString);
    this.priority = json.getInt("priority");
    this.timestamp = json.getInt("timestamp");
    this.message = json.getString("message");
    
    switch (typeString) {
      case "Physiological":
        this.runningForm = json.getString("runningForm");
        this.footStrikePattern = json.getString("footStrikePattern");
        break;
      case "Environmental":
        this.terrainType = json.getString("terrainType");
        this.weatherCondition = json.getString("weatherCondition");
        break;
    }
  }
  
  public NotificationType getType() { return type; }
  public int getPriority() { return priority; }
  public int getTime() { return timestamp; }
  
  public String getForm() { return runningForm;}
  public String getFootStrike() { return footStrikePattern;}
  
  public String getTerrainType() {return terrainType;}
  public String getWeatherCondition() {return weatherCondition;}
  
  public String getMessage() { return message;}
}
  
