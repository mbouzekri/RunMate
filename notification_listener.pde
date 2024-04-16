import java.util.PriorityQueue;

interface NotificationListener {
  void notificationReceived(Notification notification);
}

class MyNotificationListener implements NotificationListener { 
  public MyNotificationListener() {}
  
  public void notificationReceived(Notification notification) { 
    if (updateState == 0) {
      pq.add(new PriorityItem(notification.getPriority(),  notification.getMessage()));
    } else if (updateState == 1 && notification.getType() == NotificationType.Physiological) {
      pq.add(new PriorityItem(notification.getPriority(),  notification.getMessage()));
    } else if (updateState == 2 && notification.getType() == NotificationType.Environmental) {
      pq.add(new PriorityItem(notification.getPriority(),  notification.getMessage()));
    }
  }
}
